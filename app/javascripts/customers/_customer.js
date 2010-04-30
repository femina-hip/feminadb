$('table.customer').find('thead.delivery-details, thead.contact-details').each(function() {
  var $thead = $(this);
  var $tbody = $(this).next();

  $tbody.hide();

  var $a = $('<a class="show-hide">Show</a>');
  $thead.find('th').append(' ');
  $thead.find('th').append($a);

  $a.click(function() {
    $tbody.slideToggle(function() {
      if ($tbody.is(':visible')) {
        $a.text('Hide');
      } else {
        $a.text('Show');
      }
    });
  });
});
