$ ->
  $(document).on 'submit', 'form.new-sms-number', (ev) ->
    ev.preventDefault()
    $form = $(ev.currentTarget)

    url = $form.attr('action')
    sms_number = $form.find('input[name=sms_number]').val()

    $form.prop('disabled', true)

    $.ajax
      method: 'post'
      url: url
      data: { sms_number: sms_number }
      dataType: 'html'
      success: (html) ->
        $li = $form.parent()
        $li.before(html)
        $form.prop('disabled', false)
      error: (xhr) ->
        console.warn(xhr)
        alert("FeminaDB failed to communicate with Telerivet. Error: #{xhr.responseText}")
        $form.prop('disabled', false)
