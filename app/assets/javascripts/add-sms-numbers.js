$(document).on('submit', 'form.new-sms-number', function(ev) {
  ev.preventDefault()
  var $form = $(ev.currentTarget)
  var $input = $form.find('input[name=sms_number]')
  var $button = $form.find('button')

  function set_loading() {
    $form.prop('disabled', true)
    $button.prepend('<div class="loading"><div class="spinner"><div></div></div></div>')
  }

  function unset_loading() {
    $form.prop('disabled', false)
    $button.find('.loading').remove()
  }

  function maybe_delete_old_sms_number(sms_number) {
    var added_attribute = $form.closest('ul.sms-numbers').attr('data-attribute')
    if (added_attribute !== 'old_sms_numbers') {
      $("ul.sms-numbers[data-attribute=old_sms_numbers] li[data-sms-number='" + sms_number + "']").remove()
    }
  }

  set_loading()

  $.ajax({
    method: 'post',
    url: $form.attr('action'),
    data: { sms_number: $input.val() },
    dataType: 'html',
    success: function(html) {
      var $li = $form.parent()
      $li.before(html)
      maybe_delete_old_sms_number($input.val())
      unset_loading()
      $input.val('')
    },
    error: function(xhr) {
      console.warn(xhr)
      alert('FeminaDB failed to communicate with Telerivet. Error: ' + xhr.responseText)
      unset_loading()
    }
  })
})
