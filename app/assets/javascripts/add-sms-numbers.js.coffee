$ ->
  $(document).on 'submit', 'form.new-sms-number', (ev) ->
    ev.preventDefault()
    $form = $(ev.currentTarget)
    $input = $form.find('input[name=sms_number]')
    $button = $form.find('button')

    set_loading = ->
      $form.prop('disabled', true)
      $button.prepend('<span class="loading"><i class="fa fa-spinner fa-spin"></i></span>')

    unset_loading = ->
      $form.prop('disabled', false)
      $button.find('.loading').remove()

    set_loading()

    $.ajax
      method: 'post'
      url: $form.attr('action')
      data: { sms_number: $input.val() }
      dataType: 'html'
      success: (html) ->
        $li = $form.parent()
        $li.before(html)
        unset_loading()
        $input.val('')
      error: (xhr) ->
        console.warn(xhr)
        alert("FeminaDB failed to communicate with Telerivet. Error: #{xhr.responseText}")
        unset_loading()
