function fetch_elems($td) {
  var ret = {};

  ret.$form_div = $td.find('form').parent();

  return ret;
}

function on_a_click(e) {
  e.preventDefault();
  var $a = $(e.target);

  var $td = $a.closest('td');

  var elems = fetch_elems($td);

  if (!elems.$form_div.is(':visible')) {
    elems.$form_div.show();
  } else {
    elems.$form_div.hide();
  }
}

function on_form_reset(e) {
  var $form = $(e.target);

  var $td = $form.closest('td');

  var elems = fetch_elems($td);

  elems.$form_div.hide();
}

function on_form_submit(e) {
  e.preventDefault();

  var $form = $(e.target);

  var $td = $form.closest('td');

  var elems = fetch_elems($td);

  elems.$form_div.append('<div class="submitting"><p><img src="/images/loading.gif" alt="" />Saving...</p></div>');

  var channeler = new Channeler();

  channeler.add_listener('save.success', function(type, textStatus, data) {
    $td.empty();
    $td.append(data.td_html);
    $td.children().hide();
    $td.children().fadeIn();
  });

  channeler.channel('save', {
    url: $form.attr('action'),
    data: $form.serialize(),
    type: 'post'
  });
}

$('table.issue-orders td.qty a').live('click', on_a_click);
var $forms = $('table.issue-orders td.qty form');
$forms.live('reset', on_form_reset);
$forms.live('submit', on_form_submit);
