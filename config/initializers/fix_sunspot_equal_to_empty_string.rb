module Sunspot
  module Query
    module Restriction
      class EqualTo
        def to_positive_boolean_phrase
          if @value == ''
            "#{Util.escape(@field.indexed_name)}:[* TO \"\"]"
          elsif !@value.nil?
            super
          else
            "#{Util.escape(@field.indexed_name)}:[* TO *]"
          end
        end
      end
    end
  end
end
