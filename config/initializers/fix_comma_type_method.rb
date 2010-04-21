module Comma
  class Extractor
    def type(*args)
      method_missing(:type, *args)
    end
  end
end
