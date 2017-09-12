module QueryBuilder
  def self.apply_string_to_search(string, search)
    parser = SyntaxParser.new
    tree = parser.parse(string)
    walker = Searcher.new(search, tree)
    walker.process
  end
end
