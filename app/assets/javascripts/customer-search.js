$(function() {
  $(document).on('reset', 'form.search', function(ev) {
    var $form = $(ev.currentTarget)
    $form.find('input[name=q]').val('')
    $form[0].submit()
  })
})
