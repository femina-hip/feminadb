$('body.customers-edit, body.customers-new').each(function() {
  var $input = $('select[name="customer[customer_type_id]"]', this)
  var $form = $input.closest('form')

  function refreshFormIsSchoolClass() {
    var isSchool = /^SS /.test($input[0].selectedOptions[0].textContent)
    $form.toggleClass('is-school', isSchool)
  }

  refreshFormIsSchoolClass()
  $input.on('change', refreshFormIsSchoolClass)
});
