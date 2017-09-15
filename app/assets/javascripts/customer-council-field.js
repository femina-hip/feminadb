$('form table.customer #customer_council').each(function() {
  var $council = $(this)
  var $region = $('form table.customer #customer_region_id')

  function refresh_visible_councils() {
    var region = $region.children(':selected').text()
    // Hide irrelevant optgroups. Leave the prompt, though.
    $council.children('optgroup').each(function() {
      var optgroup = this
      var visible = (optgroup.label === region)
      optgroup.disabled = !visible
      optgroup.style.display = visible ? null : 'none'

      if (!visible && $(optgroup).children(':selected').length > 0) {
        $council.val('')
      }
    })
  }

  $region.on('change', refresh_visible_councils)
  refresh_visible_councils()
})
