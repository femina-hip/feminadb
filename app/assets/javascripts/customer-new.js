$('body.customers-new').each(function() {
  var $region_id = $('select#customer_region_id', this)
  var $name = $('input#customer_name', this)
  var $similar = $('<div class="similar"></div>').insertAfter($name)

  var $inputs = $region_id.add($name)

  function showNeedMoreParameters() {
    $similar.empty()
  }

  function showLoading() {
    $similar.empty().append('<p><div class="spinner"><div/></div></p>')
  }

  function showSimilarCustomers(data) {
    if (data.length > 0) {
      var template = _.template('<li><a class="customer" href="/customers/<%= id %>"><span class="customer-name"><%- name %></span><span class="customer-council"><%- council %></span></a></li>')


      $similar.empty()
        .append($('<p>Similar Customers already in the database:</p><ul>' + data.map(function(customer) { return template(customer) }).join('') + '</ul>'))
    } else {
      $similar.empty()
        .append('<p>There are no Customers similar to this one in the database.</p>')
    }
  }

  function showError(data) {
    $similar.empty()
    console.log('ERROR', data)
  }

  var currentXhr = null

  $inputs.on('change', function() {
    if (currentXhr) {
      currentXhr.abort()
      currentXhr = null
    }

    if (!($region_id.val() && $name.val())) {
      showNeedMoreParameters()
      return
    }

    showLoading()

    currentXhr = $.ajax({
      url: '/customers/similar',
      data: {
        'customer[region_id]': $region_id.val(),
        'customer[name]': $name.val()
      },
      success: function(data, __, xhr) {
        if (xhr !== currentXhr) return

        showSimilarCustomers(data)
        currentXhr = null
      },
      failure: function(xhr) {
        if (xhr !== currentXhr) return

        showError(data)
        currentXhr = null
      }
    })
  });
});
