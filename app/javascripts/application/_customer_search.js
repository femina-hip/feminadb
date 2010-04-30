$('form.search').find('input[type=reset]').click(function(e) {
  e.preventDefault();

  var $form = $(this).closest('form');

  $form.find('input[type=text]').val('');
  $form.submit();
});
