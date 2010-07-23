var $form = $('form.search');

$form.find('input[type=reset]').click(function(e) {
  e.preventDefault();

  var $form = $(this).closest('form');

  $form.find('input[type=text]').val('');
  $form.submit();
});

$form.find('div.explanation a').click(function(e) {
  e.preventDefault();

  var $content = $('div.explanation div.content');
  if ($content.is(':visible')) {
    $content.hide();
  } else {
    $content.show();
  }
});
