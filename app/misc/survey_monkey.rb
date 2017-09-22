# Handles SurveyMonkey data.
#
# We'd love to use the API, but it costs too much. We'll parse CSVs instead.
module SurveyMonkey
  ValidQuestionTypes = Set.new([ :text, :list, :key_value ])

  Answer = RubyImmutableStruct.new(:question_text, :type, :json) do
    def to_json; to_h.to_json; end

    def self.from_json(json)
      Answer.new(
        question_text: json['question_text'],
        type: json['type'].to_sym,
        json: json['json']
      )
    end
  end

  Column = RubyImmutableStruct.new(:name, :index)

  Question = RubyImmutableStruct.new(:text, :type, :columns)

  Response = RubyImmutableStruct.new(:respondent_id, :region_name, :start_date, :end_date, :answers) do
    def self.from_active_record(record)
      Response.new(
        respondent_id: record.sm_respondent_id,
        region_name: record.region_name,
        start_date: record.start_date,
        end_date: record.end_date,
        answers: JSON.parse(record.answers_json).map { |json| Answer.from_json(json) }
      )
    end
  end

  Survey = RubyImmutableStruct.new(:questions, :responses) do
    def self.parse_csv_date(s)
      DateTime.strptime(s + ' Z', '%m/%d/%Y %I:%M:%S %p %z')
    end

    def self.find_region_column_index(rows, region_names_set)
      # Go through each column. Calculate how many answers are region names.
      # The one with the most region-name answers is the region column
      best_index = nil
      best_score = 0
      for i in 0 .. rows.first.length
        score = 0
        rows.each { |row| score += 1 if region_names_set.include?(row[i]) }
        if score > best_score
          best_index = i
          best_score = score
        end
      end

      best_index
    end

    def self.parse_csv(csv, region_names_set)
      rows = CSV.parse(csv)
      row1 = rows.shift
      row2 = rows.shift

      if rows.empty?
        raise ArgumentError, 'There are no rows in your uploaded CSV'
      end

      # Parse the two header rows into "questions"
      respondent_id_index = nil
      start_date_index = nil
      end_date_index = nil
      questions = []
      last_question = nil
      column_state = :head
      row1.zip(row2).each_with_index do |values, i|
        val1, val2 = values

        case column_state
        when :head
          respondent_id_index = i if val1.downcase == 'respondent id'
          start_date_index = i if val1.downcase == 'start date'
          end_date_index = i if val1.downcase == 'end date'
          column_state = :end_of_head if val1.downcase == 'last name'
        when :end_of_head
          column_state = :questions if !row2[i + 1].blank?
        when :questions
          if !last_question.nil?
            if val1
              # Stop adding to the previous question
              last_question = nil
            else
              # Add this response to the previous question's columns
              last_question.columns << Column.new(val2, i)
              next
            end
          end

          question_type = (i + 1 < row1.length && row1[i + 1].blank?) ? :multi : :text
          question = Question.new(val1, question_type, [ Column.new(val2, i) ])
          questions << question
          last_question = question if question_type == :multi
        end
      end

      region_name_index = find_region_column_index(rows, region_names_set)

      responses = rows.map do |row|
        Response.new(
          respondent_id: row[respondent_id_index],
          region_name: row[region_name_index],
          start_date: parse_csv_date(row[start_date_index]),
          end_date: parse_csv_date(row[end_date_index]),
          answers: questions.map do |question|
            type, json = if question.type == :text
              [ :text, row[question.columns.first.index ] ]
            else
              # A multi-column answer is either a list (meaning the user clicked
              # checkboxes, and each CSV value is equal to its header or blank)
              # or a key_value (meaning there were sub-questions and
              # sub-answers).
              #
              # Detect which, and format JSON accordingly. (list => Array of
              # text; key_value => Array of {key,value}.
              is_list = true
              question.columns.each do |column|
                value = row[column.index]
                if !value.blank? && value != column.name
                  is_list = false
                  break
                end
              end

              if is_list
                [ :list, question.columns.map{ |c| row[c.index] }.reject(&:blank?) ]
              else
                [ :key_value, question.columns.map{ |c| { 'key' => c.name, 'value' => row[c.index] } } ]
              end
            end

            Answer.new(question_text: question.text, type: type, json: json)
          end
        )
      end

      Survey.new(questions: questions, responses: responses)
    end
  end
end
