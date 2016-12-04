$.fn.customer_id_field = ->
  option_template = _.template('''
    <div class="customer-id-option">
      <span class="name"><%- name %></span>
      <abbr class="type" title="<%- type.description %>"><%- type.name %></abbr>
      <span class="address">
        <span class="council"><%- council %></span>, <span class="region"><%- region %></span>
      </span>
    </div>
  ''')

  $(this).selectize
    valueField: 'id'
    labelField: 'name'
    searchField: ''
    create: false
    render:
      option: (item) -> option_template(item)
    load: (query, callback) ->
      return callback() if (!query.length)

      $.ajax
        url: "/customers/autocomplete?q=#{encodeURIComponent(query)}"
        error: (xhr) ->
          console.warn("Query error", xhr)
          callback()
        success: (data) ->
          console.log(data)
          callback(data)

$ ->
  $('.customer-id-field').each ->
    $(this).customer_id_field()
