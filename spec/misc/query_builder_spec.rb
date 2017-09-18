require File.dirname(__FILE__) + '/../spec_helper'

describe(::QueryBuilder) do
  def self.t(description, query, normalized)
    it(description) { expect(normalize(query)).to eq(normalized) }
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
    parser = ::QueryBuilder::SyntaxParser.new
    tree = parser.parse(query)
    ::QueryBuilder::Printer.generate_normalized_string(tree)
  end
end
