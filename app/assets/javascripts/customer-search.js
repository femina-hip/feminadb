// When user clicks Reset, search for ""
$(document).on('reset', 'form.search', function(ev) {
  var $form = $(ev.currentTarget)
  $form.find('input[name=q]').val('')
  $form[0].submit()
})

// The rest of this file is devoted to sessionStorage, where we store search
// results. The goal: friendly workflow speed-ups for power users.

// Save search q+page+ids to sessionStorage when receiving search results
$('.customer-search-result').each(function() {
  var searchResult = {
    q: this.getAttribute('data-q') || '',
    page: this.getAttribute('data-page') || '1',
    customerIds: this.getAttribute('data-customer-ids').split(/ /g).map(function(id) { return parseFloat(id) })
  }
  sessionStorage.setItem('searchResult', JSON.stringify(searchResult));
});

// mangle all links to customers, to add back "q" and "page"
(function() {
  var lastSearchResultString = sessionStorage.getItem('searchResult')
  if (!lastSearchResultString) return
  var lastSearchResult = JSON.parse(lastSearchResultString)

  $('a[href$="/customers"]').each(function() {
    var href = this.getAttribute('href')
    var sep = '?'
    if (lastSearchResult.q) {
      href += sep + 'q=' + encodeURIComponent(lastSearchResult.q)
      sep = '&'
    }
    if (lastSearchResult.page != '1') {
      href += sep + 'page=' + encodeURIComponent(lastSearchResult.page)
      sep = '&'
    }
    this.setAttribute('href', href)
  });
})();

// add "previous" and "next" links to customer-show page
$('body.customers-show table.customer[data-id]').each(function() {
  var lastSearchResultString = sessionStorage.getItem('searchResult')
  if (!lastSearchResultString) return
  var lastSearchResult = JSON.parse(lastSearchResultString)

  var id = parseFloat(this.getAttribute('data-id'))
  var allIds = lastSearchResult.customerIds
  var pos = allIds.indexOf(id)
  if (pos === -1) return

  var $div = $('<div class="customer-ids-nav"><a class="previous">Previous Customer</a><a class="next">Next Customer</a></div>')
  if (pos > 0) {
    $div.find('.previous').attr('href', '/customers/' + allIds[pos - 1])
  }
  if (pos < allIds.length - 1) {
    $div.find('.next').attr('href', '/customers/' + allIds[pos + 1])
  }

  $(this).before($div)
})
