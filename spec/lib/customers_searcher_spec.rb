require File.dirname(__FILE__) + '/../spec_helper'

describe(CustomersSearcher) do
  before(:each) do
    @mock_search = mock('search')
  end

  it 'should do nothing with empty search' do
    # Because mock_search has no methods, if anything is called this will fail
    aqsts(@mock_search, '')
  end

  it 'should receive "keywords"' do
    @mock_search.should_receive(:keywords).with('foobar')
    aqsts(@mock_search, 'foobar')
  end

  it 'should filter by field' do
    @mock_search.should_receive(:with).with(:name, 'foobar')
    aqsts(@mock_search, 'name:foobar')
  end

  it 'should filter by field with double-quotes' do
    @mock_search.should_receive(:with).with(:name, 'foobar')
    aqsts(@mock_search, 'name:"foobar"')
  end

  it 'should filter by field with single-quotes' do
    @mock_search.should_receive(:with).with(:name, 'foobar')
    aqsts(@mock_search, "name:'foobar'")
  end

  it 'should filter by field with spaces in the quotes' do
    @mock_search.should_receive(:with).with(:name, 'foo bar')
    aqsts(@mock_search, 'name:"foo bar"')
  end

  it 'should filter by field with double-quotes with a single-quote inside' do
    @mock_search.should_receive(:with).with(:name, 'foo"bar')
    aqsts(@mock_search, "name:'foo\"bar'")
  end

  private

  def aqsts(search_object, s)
    CustomersSearcher.apply_query_string_to_search(search_object, s)
  end
end
