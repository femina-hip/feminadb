module Sunspot
  module Query
    module Connective
      class Abstract
        def to_boolean_phrase #:nodoc:
          unless @components.empty?
            phrase =
              if @components.length == 1
                @components.first.to_boolean_phrase
              else
                component_phrases = @components.map do |component|
                  component.to_boolean_phrase
                end
                component_phrases.compact!
                unless component_phrases.empty?
                  "(#{component_phrases.join(" #{connector} ")})"
                end
              end
            if negated?
              phrase && "-#{phrase}"
            else
              phrase
            end
          end
        end
      end
    end
  end
end
