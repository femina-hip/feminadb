require File.dirname(__FILE__) + '/../../../spec_helper'

describe(Sunspot::QueryBuilder::Explainer) do
  def self.t(query, explanation)
    it("should explain *#{query}*") do
      explain(query).should == explanation
    end
  end

  t('', 'ALL()')
  t('foo', 'foo')
  t('foo bar', 'ALL(foo,bar)')
  t('foo OR bar', 'ANY(foo,bar)')
  t('foo AND bar OR baz', 'ALL(foo,ANY(bar,baz))')
  t('field:value', 'field|:|value')
  t('standing:fema:false', 'standing:fema|:|false')
  t('-blah', 'NOT(blah)')

  def explain(query)
    parser = Sunspot::QueryBuilder::SyntaxParser.new
    tree = parser.parse(query)
    explanation = Sunspot::QueryBuilder::Explainer.build_explanation(tree)
    collapse_explanation(explanation)
  end

  def collapse_explanation(explanation)
    if Array === explanation
      if Symbol === explanation.first
        conj = case explanation.first
        when :all then 'ALL'
        when :any then 'ANY'
        when :not then 'NOT'
        else
          raise Exception.new("Invalid array: #{explanation.inspect}")
        end
        subnodes = explanation[1..-1]
        "#{conj}(#{subnodes.collect{|e| collapse_explanation(e)}.join(',')})"
      else
        explanation.join('|')
      end
    else
      explanation
    end
  end
end
