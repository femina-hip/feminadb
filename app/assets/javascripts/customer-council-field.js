$('form table.customer #customer_council').each(function() {
  var $council = $(this);
  var $region = $('form table.customer #customer_region_id');

  $.ajax({
    url: '/councils/by-region.json',
    dataType: 'json',
    success: init_corrector,
    error: function(err) { console.warn(err); }
  })

  var optionsTemplate = _.template('<option class="prompt">Valid <%- region %> Councils</option><% councils.forEach(function(council) { %><option><%- council %></option><% }); %>');

  function init_corrector(region_councils) {
    var $corrector = $('<div class="council-corrector"><span></span>Set to: <select></select></div>');
    var $status = $corrector.find('span');
    var $select = $corrector.find('select');

    $select.on('change', function(ev) {
      var council = $(ev.target).find('option:selected:not(.prompt)').text();
      if (council) {
        $council.val(council);
        render();
      }
    });

    $region.on('change', render);
    $council.on('input', render);

    function render() {
      var region = $region.find('option:selected').text() || '';
      var council = $council.val() || '';
      var councils = region_councils[region] || [];

      var valid = (councils.indexOf(council) !== -1);
      $status[0].className = valid ? 'valid' : 'invalid';
      // Unset: no message; valid: valid; invalid: invalid
      $status[0].textContent = council === '' ? '' : (valid ? 'Valid. ' : 'Invalid. ');
      $select[0].innerHTML = optionsTemplate({ region: region, councils: councils });
    }

    render(); // from page-load data
    $council.after($corrector);
  }
});
