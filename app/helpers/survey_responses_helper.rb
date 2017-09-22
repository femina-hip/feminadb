module SurveyResponsesHelper
  def render_survey_response_answer(answer)
    answer_html = case answer.type
    when :text then content_tag(:div, answer.json.split(/  /).map{|line| content_tag(:p, line)}.join.html_safe, class: 'text')
    when :list then content_tag(:p, answer.json.join(', '), class: 'list')
    when :key_value
      content_tag(:dl, answer.json.flat_map do |cell|
        [
          content_tag(:dt, cell['key']),
          content_tag(:dd, cell['value'])
        ]
      end.join('').html_safe, class: 'survey-answer-key-value')
    end

    [
      content_tag(:dt, answer.question_text),
      content_tag(:dd, answer_html)
    ].join('').html_safe
  end

  def render_survey_response_answers(answers)
    content_tag(
      :dl,
      answers.flat_map{ |answer| render_survey_response_answer(answer) }.join('').html_safe,
      class: 'survey-response-answers'
    )
  end
end
