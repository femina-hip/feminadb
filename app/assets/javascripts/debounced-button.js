$.fn.debounce_button = function() {
  $(this)
    .prop('disabled', true)
    .prepend('<span class="debouncing"><i class="fa fa-spinner fa-spin"></i></span>')
}

$(document).on('submit', 'form', function(ev) {
  $('button.debounced', ev.currentTarget).debounce_button()
})
