var $region_id = $('select#customer_region_id');
var $council = $('input#customer_council');
var $name = $('input#customer_name');
var $stuff;

function render_similar_customer(similar_customer) {
  var $a = $('<a></a>');
  $a.attr('href', '/customers/' + similar_customer.id);
  $a.text(similar_customer.name + ', ' + similar_customer.council + ', ' + similar_customer.region);
  return $a;
}

var channel = new Channeler();

channel.add_listener('check.send', function() {
  show_stuff('<p><img src="/images/loading-similar.gif" alt="" /> Checking for existing Customers with that name...</p>', 'querying');
});

channel.add_listener('check.success', function(type, response, data) {
  if (data && data.length) {
    var $p = $('<p>Similar Customers already exist. Don\'t create a new one if you want:</p>');
    var $ul = $('<ul></ul>');
    $.each(data, function() {
      var $li = $('<li></li>');
      $li.append(render_similar_customer(this));
      $ul.append($li);
    });
    var $data = $('<div></div>');
    $data.append($p);
    $data.append($ul);
    show_stuff($data, 'match');
  } else {
    show_stuff('<p>Good! This Customer does not exist already.</p>', 'no-match');
  }
});

function show_stuff($contents, html_class) {
  if (!$stuff) {
    $stuff = $('<div class="similar"></div>');
    $council.after($stuff);
  }

  $stuff.empty();
  $stuff.append($contents);
  $stuff.attr('class', 'similar ' + html_class);
}

function check_for_similar_customers() {
  var region_id = $region_id.val();
  var council = $council.val();
  var name = $name.val();

  if (!name) {
    channel.abort_channel('check');
    show_stuff('', 'empty');
    return;
  }

  var params = {
    'customer[region_id]': region_id,
    'customer[council]': council,
    'customer[name]': name
  };

  var url = $region_id.closest('form').attr('action') + '/similar';
  channel.channel('check', {
    url: url,
    dataType: 'json',
    data: params
  });
}

$.each([$region_id, $council, $name], function() {
  $(this).change(function() {
    check_for_similar_customers();
  });
});
