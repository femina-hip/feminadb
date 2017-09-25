$('form.edit_survey_response').each(function() {
  var $form = $(this)
  var $customer_id = $form.find('select[name="survey_response[customer_id]"]')
  var $a_customer = $form.find('button.a-customer')
  var $no_customer = $form.find('button.no-customer')

  function refreshCustomerSubmitDisabled() {
    $a_customer[0].disabled = !$customer_id.val()
  }
  $customer_id.on('change', refreshCustomerSubmitDisabled)
  refreshCustomerSubmitDisabled()

  $no_customer.on('click', function() {
    $customer_id.val('')
  })
})
