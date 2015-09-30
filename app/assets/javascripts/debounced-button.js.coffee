$ ->
  $(document).on 'submit', 'form', (ev) ->
    $buttons = $('button.debounced', ev.currentTarget)
    $buttons
      .prop('disabled', true)
      .prepend('<span class="debouncing"><i class="fa fa-spinner fa-spin"></i></span>')
