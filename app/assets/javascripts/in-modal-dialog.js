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
        success: function(response) {
          $a.text(response.text)
          if (response.url) $a.attr('href', response.url)
        },
        error: function(xhr, status, error) {
          console.log("Error", status, error)
          alert("Error saving: ", error)
        },
        complete: function()  { $modal.remove() }
      })
    })

  $modal.find('.modal-body').load(href + ' div.main form', null, function() {
    $modal.find('input[type=number]:eq(0)').select().focus()
  })
})
