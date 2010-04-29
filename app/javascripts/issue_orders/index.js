var $pane;
var $a;
var $form_div;

function show_pane() {
  if (!$pane) {
    $pane = $('<div></div>');
    $('body').append($pane);
    $('body').css('position', 'relative');
    $pane.css({
      position: 'absolute',
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      'background-image': 'url(/images/fade.png)',
      'z-index': 0
    });

    $pane.click(hide_pane);
  }

  $pane.show();
  $a.css('z-index', 1);
}

function hide_pane() {
  $pane.hide();
  $a.css('z-index', 0);
  $form_div.hide();

  $a = undefined;
  $form_div = undefined;
}

function fetch_elems($td) {
  var ret = {};

  ret.$form_div = $td.find('form').parent();

  return ret;
}

function on_a_click(e) {
  e.preventDefault();
  $a = $(e.target);

  var $td = $a.closest('td');

  var elems = fetch_elems($td);

  $form_div = elems.$form_div;

  if (!$form_div.is(':visible')) {
    $form_div.show();
    show_pane();
  } else {
    hide_pane();
  }
}

function on_form_reset(e) {
  hide_pane();
}

function on_form_submit(e) {
  e.preventDefault();

  var $form = $(e.target);

  var $submit = $form.find('input[type=submit]');
  if ($submit.hasClass('delete')) {
    if (!confirm('Are you sure you want to delete?')) {
      return;
    }
  }

  var $td = $form.closest('td');

  var elems = fetch_elems($td);

  elems.$form_div.append('<div class="submitting"><p><img src="/images/loading.gif" alt="" />Saving...</p></div>');

  var channeler = new Channeler();

  channeler.add_listener('save.success', function(type, textStatus, data) {
    $td.empty();
    $td.append(data.td_html);
    $td.children().hide();
    $td.children().fadeIn();

    if ($td.find('div.errorExplanation').length) {
      elems = fetch_elems($td);
      $form_div = elems.$form_div;

      $form_div.show();
    } else {
      hide_pane();
    }
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
