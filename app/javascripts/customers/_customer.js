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

$('form table.customer #customer_council').each(function() {
  var $council = $(this);
  var $region = $('form table.customer #customer_region');

  $.ajax({
    url: '/councils/by-region.json',
    dataType: 'json',
    success: init_corrector,
    error: function(err) { console.warn(err); }
  })

  var optionsTemplate = _.template('<option disabled>Valid <%- region %> Councils</option><% councils.forEach(function(council) { %><option><%- council %></option><% }); %>');

  function init_corrector(region_councils) {
    var $corrector = $('<div class="council-corrector"><span></span>Set to: <select></select></div>');
    var $status = $corrector.find('span');
    var $select = $corrector.find('select');

    $select.on('change', function(ev) {
      $council.val($(ev.target).val());
      render();
    });

    $council.on('input', render);

    function render() {
      var region = $region.val();
      var council = $council.val();
      var councils = region_councils[region];

      var valid = (councils.indexOf(council) !== -1);
      $status.className = valid ? 'valid' : 'invalid';
      // Unset: no message; valid: valid; invalid: invalid
      $status.textContent = council === '' ? '' : (valid ? 'Valid. ' : 'Invalid. ');
      $select.innerHTML = optionsTemplate({ region: region, councils: councils });
    }

    render(); // from page-load data
  }
});
