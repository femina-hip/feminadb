module Tags
  def self.normalize_name(name)
    name = name[4..-1] if name =~ /^TAG[^A-Z0-9]/i
    name.upcase.gsub(/[^A-Z0-9]+/, '_')
  end
end
