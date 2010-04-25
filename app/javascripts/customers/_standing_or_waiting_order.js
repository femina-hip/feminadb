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
  var $a = $(e.target);

  var $td = $a.closest('td');

  var elems = fetch_elems($td);

  if (!elems.$forms_div.is(':visible')) {
    if (elems.$both_divs.length == 2) {
      // Creating new ones: if they're both hidden, show just the h3's
      elems.$both_forms.hide();
    }

    elems.$forms_div.show();
  } else {
    elems.$forms_div.hide();
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

  var $td = $form.closest('td');

  var elems = fetch_elems($td);

  elems.$forms_div.hide();
}

function on_form_submit(e) {
  e.preventDefault();

  var $form = $(e.target);

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
      elems.$forms_div.show();
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
