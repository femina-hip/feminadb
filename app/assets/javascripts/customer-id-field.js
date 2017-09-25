$.fn.customer_id_field = function() {
  const option_template = _.template([
    '<div class="customer-id-option">',
      '<span class="name"><%- name %></span>',
      '<span class="type"><%- type.name %></span>',
      '<span class="address">',
        '<span class="region"><%- region %></span><span class="council"><%- council %></span>',
      '</span>',
    '</div>'
  ].join(''))

  function one_customer_id_field(_, el) {
    $(el).selectize({
      valueField: 'id',
      highlight: false,
      openOnFocus: true,
      searchField: [],
      create: false,
      render: {
        item: option_template,
        option: option_template
      },
      loadThrottle: 150, // Selectize default is a painful 300
      score: function() { return function() { return 1 } }, // all ajax results are matches
      load: function(query, callback) {
        if (!query.length) return callback()
        var _this = this

        $.ajax({
          url: '/customers/autocomplete?q=' + encodeURIComponent(query),
          error: function(xhr) {
            console.warn("Query error", xhr)
            callback()
          },
          success: function(data) {
            _this.clearOptions() // https://github.com/selectize/selectize.js/issues/1053
            callback(data)
          }
        })
      }
    })
  }

  $(this).each(one_customer_id_field)
}

$('.customer-id-field').customer_id_field()
