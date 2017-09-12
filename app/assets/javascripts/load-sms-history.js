$(function() {
  $(document).on('click', 'a.load-sms-messages', (ev) => {
    ev.preventDefault()
    $a = $(ev.currentTarget)
    $container = $a.closest('div')

    href = $a.attr('href')
    $a.remove() // So we can add it back if there's an error

    $container.empty().append('<div class="loading"><i class="fa fa-spinner fa-spin"></i> Loading SMS messages…</div>')
    $container.load(href, (_, status, xhr) => {
      if (status === 'error') {
        console.warn(`Error loading ${href}`, xhr)
        $container.empty()
          .append(`<div class='error'>There was an error loading SMS messages: ${xhr.status} ${xhr.statusText}.</div>`)
          .append($a)
      } else {
        $hideA = $('<a href="#" class="hide-sms-history">Hide SMS history</a>')
        $container.prepend($hideA)
        $hideA.on('click', (ev) => {
          ev.preventDefault()
          $container.empty().append($a)
        })
      }
    })
  })
})
