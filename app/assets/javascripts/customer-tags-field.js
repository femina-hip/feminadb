(function() {
  var tagsDataDiv = document.querySelector('.tags-data')
  if (!tagsDataDiv) return
  var tagsJson = tagsDataDiv.getAttribute('data-tags')
  if (!tagsJson) return

  var tags = JSON.parse(tagsJson) // Array of { id, name, color, light_or_dark }
    .sort(function(a, b) { return a.name.localeCompare(b.name) })

  function renderTag(tag, escape) {
    if (!tag) tag = { id: 0, name: '(Unknown tag)', color: '#000000', light_or_dark: 'dark' }
    return '<div class="selectize-tag" data-value="' + tag.id + '"><span class="tag tag-' + tag.light_or_dark + '" style="background-color: ' + tag.color + '">' + escape(tag.name) + '</span></div>'
  }

  $('.customer-tags-field').each(function() { makeTagSelect(this) })

  function makeTagSelect(div) {
    var customerId = parseFloat(div.getAttribute('data-customer-id'))

    // build tagIds, a sorted, comma-separated list of IDs. Only include valid
    // IDs.
    //
    // customers_tags has no order; when the user edits, we won't re-sort. The
    // next time the page loads, this code will run again and so the list will
    // be re-sorted for the user.
    var tagIdsSet = {}
    div.getAttribute('data-tag-ids')
      .split(/, */g)
      .filter(function(s) { return s.length > 0 })
      .forEach(function(s) { tagIdsSet[s] = null })
    var sortedTagIdsString = tags
      .filter(function(tag) { return tagIdsSet.hasOwnProperty(String(tag.id)) })
      .map(function(tag) { return tag.id })
      .join(',')

    var nAjaxCalls = 0

    function tagCustomer(tagId) {
      tagOrUntagCustomer('tag', tagId)
    }

    function untagCustomer(tagId) {
      tagOrUntagCustomer('untag', tagId)
    }

    function tagOrUntagCustomer(action, tagId) {
      nAjaxCalls++
      div.classList.add('saving')
      $.ajax({
        type: 'post',
        url: '/tags/' + tagId + '/' + action + '_customers',
        data: { customer_ids: String(customerId) },
        success: function() {},
        error: function(xhr, textStatus, errorThrown) {
          div.classList.add('error')
          console.warn("Error", xhr, textStatus, errorThrown)
        },
        complete: function() {
          nAjaxCalls--
          if (nAjaxCalls === 0) div.classList.remove('saving')
        }
      })
    }

    $('<input type="text" tabindex="-1" style="display:none" placeholder="Tags"/>')
      .val(sortedTagIdsString)
      .appendTo(div)
      .selectize({
        maxItems: null,
        hideSelected: true,
        options: tags,
        searchField: [ 'name' ],
        sortField: [ { field: 'name' }, { field: '$score' } ],
        valueField: 'id',
        render: {
          item: renderTag,
          option: renderTag
        },
        onItemAdd: tagCustomer,
        onItemRemove: untagCustomer
      })
  }
})()
