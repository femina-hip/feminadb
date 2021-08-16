$.fn.debounce_button = function() {
  $(this)
    .prop('disabled', true)
    .prepend('<div class="debouncing"><div class="spinner"><div></div></div></div>')
}

$(document).on('submit', 'form', function(ev) {
  $('button.debounced', ev.currentTarget).debounce_button()
})
