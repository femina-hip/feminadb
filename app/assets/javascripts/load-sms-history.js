$(document).on('click', 'a.load-sms-messages', function(ev) {
  ev.preventDefault()
  var $a = $(ev.currentTarget)
  var $container = $a.closest('div')

  var href = $a.attr('href')
  $a.remove() // So we can add it back if there's an error

  $container.empty().append('<div class="loading"><div class="spinner"><div></div></div> Loading SMS messages…</div>')
  $container.load(href, function(_, status, xhr) {
    if (status === 'error') {
      console.warn('Error loading ' + href, xhr)
      $container.empty()
        .append("<div class='error'>There was an error loading SMS messages: " + xhr.status + ' ' + xhr.statusText + '.</div>')
        .append($a)
    } else {
      var $hideA = $('<a href="#" class="hide-sms-history">Hide SMS history</a>')
      $container.prepend($hideA)
      $hideA.on('click', function(ev) {
        ev.preventDefault()
        $container.empty().append($a)
      })
    }
  })
})
