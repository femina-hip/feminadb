var $pane;
var $a;
var $forms_div;

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
  $forms_div.hide();

  $a = undefined;
  $forms_div = undefined;
}

function fetch_elems($td) {
  var ret = {};

  ret.$standing_order_div = $td.find('div.standing-order-form');
  ret.$standing_order_h3 = ret.$standing_order_div.children('h3');
  ret.$standing_order_form = ret.$standing_order_h3.siblings();

  ret.$waiting_order_div = $td.find('div.waiting-order-form');
  ret.$waiting_order_h3 = ret.$waiting_order_div.children('h3');
  ret.$waiting_order_form = ret.$waiting_order_h3.siblings();

  ret.$forms_div = $td.find('div.forms');
  ret.$both_divs = ret.$standing_order_div.add(ret.$waiting_order_div);
  ret.$both_h3s = ret.$standing_order_h3.add(ret.$waiting_order_h3);
  ret.$both_forms = ret.$standing_order_form.add(ret.$waiting_order_form);

  return ret;
}

function on_a_click(e) {
  e.preventDefault();
  $a = $(e.target);

  var $td = $a.closest('td');

  var elems = fetch_elems($td);

  $forms_div = elems.$forms_div;

  if (!$forms_div.is(':visible')) {
    if (elems.$both_divs.length == 2) {
      // Creating new ones: if they're both hidden, show just the h3's
      elems.$both_forms.hide();
    }

    $forms_div.show();
    show_pane();
  } else {
    hide_pane();
  }
}

function on_h3_click(e) {
  e.preventDefault();
  var $h3 = $(e.target);

  if (!$h3.siblings().is(':visible')) {
    var $td = $h3.closest('td');

    var elems = fetch_elems($td);

    elems.$both_forms.hide();
    $h3.siblings().show();
  }
}

function on_form_reset(e) {
  var $form = $(e.target);

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
  if ($submit.hasClass('convert')) {
    if (!confirm('Are you sure you want this to become a Standing Order?')) {
      return;
    }
  }

  var $td = $form.closest('td');

  var elems = fetch_elems($td);

  elems.$forms_div.append('<div class="submitting"><p><img src="/images/loading.gif" alt="" />Saving...</p></div>');

  var channeler = new Channeler();

  channeler.add_listener('save.success', function(type, textStatus, data) {
    $td.empty();
    $td.append(data.td_html);
    $td.children().hide();
    $td.children().fadeIn();

    var elems = fetch_elems($td);

    if (elems.$forms_div.find('div.errorExplanation').length > 0) {
      if (elems.$both_divs.length == 2) {
        elems.$both_forms.hide();
        elems.$forms_div.find('div.errorExplanation').closest('form').show();
      }
      $forms_div = elems.$forms_div;
      $forms_div.show();
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

$('table.customers td.standing-orders a').live('click', on_a_click);
$('table.customers td.standing-orders h3').live('click', on_h3_click);
var $forms = $('table.customers td.standing-orders form');
$forms.live('reset', on_form_reset);
$forms.live('submit', on_form_submit);
