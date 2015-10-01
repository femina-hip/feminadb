$ ->
  $(document).on 'reset', 'form.search', (ev) ->
    $form = $(ev.currentTarget)
    $form.find('input[name=q]').val('')
    $form[0].submit()
