$('body.customers-show ul.survey-responses .survey-response-meta')
  .css('cursor', 'pointer')
  .on('click', function() {
    $(this).closest('.survey-response').toggleClass('open')
  })
