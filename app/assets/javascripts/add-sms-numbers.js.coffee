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

    maybe_delete_old_sms_number = (sms_number) ->
      added_attribute = $form.closest('ul.sms-numbers').attr('data-attribute')
      if added_attribute != 'old_sms_numbers'
        $("ul.sms-numbers[data-attribute=old_sms_numbers] li[data-sms-number='#{sms_number}']").remove()

    set_loading()

    $.ajax
      method: 'post'
      url: $form.attr('action')
      data: { sms_number: $input.val() }
      dataType: 'html'
      success: (html) ->
        $li = $form.parent()
        $li.before(html)
        maybe_delete_old_sms_number($input.val())
        unset_loading()
        $input.val('')
      error: (xhr) ->
        console.warn(xhr)
        alert("FeminaDB failed to communicate with Telerivet. Error: #{xhr.responseText}")
        unset_loading()
