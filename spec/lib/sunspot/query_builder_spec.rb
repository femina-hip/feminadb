require File.dirname(__FILE__) + '/../../spec_helper'

describe(Sunspot::QueryBuilder) do
  def self.t(description, query, normalized)
    it(description) { normalize(query).should == normalized }
  end

  t('handles a single word', 'foo', 'foo')
  t('handles AND', 'foo AND bar', 'foo AND bar')
  t('handles OR', 'foo OR bar', 'foo OR bar')
  t('handles NOT', 'foo NOT bar', 'foo AND -bar')
  t('handles -', 'foo -bar', 'foo AND -bar')
  t('handles !', 'foo !bar', 'foo AND -bar')
  t('handles a solitary -', 'foo - bar', 'foo AND - AND bar')
  t('handles a solitary !', 'foo ! bar', 'foo AND ! AND bar')

  private

  def normalize(query)
    parser = Sunspot::QueryBuilder::SyntaxParser.new
    tree = parser.parse(query)
    Sunspot::QueryBuilder::Printer.generate_normalized_string(tree)
  end
end
