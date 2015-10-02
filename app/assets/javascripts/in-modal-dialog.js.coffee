$(document).on 'keyup', (ev) ->
  if ev.which == 27
    $('.modal-wrapper').remove()

$(document).on 'click', 'a.in-modal-dialog', (ev) ->
  ev.preventDefault()

  $a = $(ev.currentTarget)
  href = $a.attr('href')

  $modal = $('''
    <div class="modal-wrapper">
      <div class="modal-background"></div>
      <div class="modal-outer">
        <div class="modal">
          <div class="modal-header">
            <h3>Edit</h3>
            <a class="modal-dismiss" href="#">&times;</a>
          </div>
          <div class="modal-body"><div class="loading"><i class="fa fa-spin fa-spinner"></i> Loading...</div></div>
        </div>
      </div>
    </div>
  ''')
    .appendTo('body')
    .on('click', '.modal', (ev) -> ev.stopPropagation()) # So we don't remove the modal when clicking around
    .on('click', 'a.modal-dismiss, .modal-outer', (ev) -> ev.preventDefault(); $modal.remove())
    .on 'submit', 'form', (ev) ->
      ev.preventDefault()
      $form = $(ev.currentTarget)
      url = $form.attr('action')
      method = $form.find('[name="_method"]').attr('value') || $form.attr('method') || 'GET'
      data = $form.serialize()

      $.ajax
        type: method
        url: url
        data: data
        dataType: 'json'
        success: (response) -> $a.text(response.text)
        error: (xhr, status, error) ->
          console.log("Error", status, error)
          alert("Error saving: ", error)
        complete: -> $modal.remove()

  $modal.find('.modal-body').load(href + ' div.main form')
