$('table.customer-standing-orders', 'table.customer-waiting-orders', 'customer.orders').find('thead.title').each(function() {
  var $thead = $(this);
  var $siblings = $thead.siblings();

  $siblings.hide();

  var $a = $('<a class="show-hide">Show</a>');
  $thead.find('th').append(' ');
  $thead.find('th').append($a);

  $a.click(function() {
    $siblings.slideToggle(function() {
      if ($siblings.is(':visible')) {
        $a.text('Hide');
      } else {
        $a.text('Show');
      }
    });
  });
});
