$(function() {
  var $div = $('#nav div.quick-publications');
  var $li = $div.parent();

  $li.hover(function() {
    $div.show();
  }, function() {
    $div.hide();
  });
});
