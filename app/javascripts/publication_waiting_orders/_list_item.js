$NS().find('a.details').click(function(e) {
  e.preventDefault();

  var $a = $(e.target);
  var $tr = $a.closest('tr').next();

  if ($tr.is(':visible')) {
    $tr.hide();
  } else {
    $tr.show();
  }
});
