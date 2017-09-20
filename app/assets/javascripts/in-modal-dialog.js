$(document).on('keyup', function(ev) {
  if (ev.which === 27) {
    $('.modal-wrapper').remove()
  }
})

$(document).on('click', 'a.in-modal-dialog', function(ev) {
  ev.preventDefault()

  var $a = $(ev.currentTarget)
  var href = $a.attr('href')

  var $modal = $([
    '<div class="modal-wrapper">',
      '<div class="modal-background"></div>',
      '<div class="modal-outer">',
        '<div class="modal">',
          '<div class="modal-header">',
            '<h3>Edit</h3>',
            '<a class="modal-dismiss" href="#">&times;</a>',
          '</div>',
          '<div class="modal-body"><div class="loading"><i class="fa fa-spin fa-spinner"></i> Loading...</div></div>',
        '</div>',
      '</div>',
    '</div>'
  ].join(''))
    .appendTo('body')
    .on('click', '.modal', function(ev) { ev.stopPropagation() }) // do not remove the modal when clicking around
    .on('click', 'a.modal-dismiss, .modal-outer', function(ev) { ev.preventDefault(); $modal.remove() })
    .on('submit', 'form', function(ev) {
      ev.preventDefault()
      var $form = $(ev.currentTarget)
      var url = $form.attr('action')
      var method = $form.find('[name="_method"]').attr('value') || $form.attr('method') || 'GET'
      var data = $form.serialize()

      $.ajax({
        type: method,
        url: url,
        data: data,
        dataType: 'json',
        success: render_response,
        error: function(xhr, status, error) {
          console.log("Error", status, error)
          alert("Error saving: ", error)
        },
        complete: function()  { $modal.remove() }
      })
    })

  function render_response(response) {
    if (response.tr_html) {
      render_response_tr_html(response.tr_html)
    } else if (response.hasOwnProperty('li_html')) {
      render_response_li_html(response.li_html, response.old_sms_numbers_li_html)
    } else {
      render_response_a(response.text, response.url)
    }
  }

  function render_response_tr_html(tr_html) {
    $a.closest('tr').before(tr_html)
  }

  function render_response_li_html(li_html, old_sms_numbers_li_html) {
    var $li = $a.closest('li') // <li> containing the link the user clicked

    if (li_html) {
      // The link was to add an SMS number, and now we have it
      $li.before(li_html)
    } else {
      // The link was to remove an SMS number, and now it's gone
      // If we're to add it to li.old-sms-numbers, do so....
      if (old_sms_numbers_li_html) {
        $li.closest('tbody').find('ul[data-attribute=old_sms_numbers]').children(':last').before(old_sms_numbers_li_html)
      }
      $li.remove()
    }
  }

  function render_response_a(text, url) {
    $a.text(text).attr('href', url)
  }

  $modal.find('.modal-body').load(href + ' div.main form', null, function() {
    $modal.find('input[type=number]:eq(0), input[type=tel]:eq(0)').select().focus()
  })
})
