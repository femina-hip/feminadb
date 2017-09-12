$.fn.customer_id_field = function() {
  const option_template = _.template([
    '<div class="customer-id-option">',
      '<span class="name"><%- name %></span>',
      '<abbr class="type" title="<%- type.description %>"><%- type.name %></abbr>',
      '<span class="address">',
        '<span class="council"><%- council %></span>, <span class="region"><%- region %></span>',
      '</span>',
    '</div>'
  ].join(''))

  function one_customer_id_field(_, el) {
    $(el).selectize({
      valueField: 'id',
      labelField: 'name',
      searchField: '',
      create: false,
      render: { option: option_template },
      load: function(query, callback) {
        if (!query.length) return callback()

        $.ajax({
          url: `/customers/autocomplete?q=${encodeURIComponent(query)}`,
          error: function(xhr) {
            console.warn("Query error", xhr)
            callback()
          },
          success: function(data) {
            callback(data)
          }
        })
      }
    })
  }

  $(this).each(one_customer_id_field)
}

$(function() {
  $('.customer-id-field').customer_id_field()
})
