function strip(s) {
  return s.replace(/^\s*|\s*$/g, '');
}

function s_to_float(s) {
  var stripped = strip(s).replace(/[^\d\.]/g, '');
  return parseFloat(stripped);
}

function normalize_s(s) {
  return strip(s).replace(/ /g, '-').toLowerCase();
}

function parse_region(text) {
  return normalize_s(text);
}

function parse_district(text) {
  return normalize_s(text);
}

function parse_num(text) {
  return s_to_float(text);
}

function make_key(region, district) {
  return region + '|' + district;
}

function get_table_data() {
  var $table = $('#report');
  var ret = {};

  $table.find('tbody tr').each(function() {
    var $tr = $(this);
    var region = normalize_s($tr.children('td:eq(0)').text());
    var district = normalize_s($tr.children('td:eq(1)').text());
    var n = s_to_float($tr.children('td:eq(2)').text());

    var key = make_key(region, district);

    ret[key] = n;
  });

  return ret;
}

function n_to_color(n, min_n, max_n) {
  var x;
  if (max_n == min_n) {
    x = 0;
  } else {
    x = (n - min_n) / (max_n - min_n);
  }

  var letters = Math.floor(255 - (255 * x)).toString(16);

  return "ff" + letters + letters; // shades of red
}

function get_min_and_max_n(data) {
  min = Number.MAX_VALUE;
  max = Number.MIN_VALUE;

  for (var key in data) {
    var n = data[key];
    if (n < min) {
      min = n;
    }
    if (n > max) {
      max = n;
    }
  }

  return [min, max];
}

function get_key_from_svg_path(svg_path, failed_paths) {
  var class_name = svg_path.getAttribute('class');
  if (!/\bmi-region\b/.test(class_name)) return undefined;
  var region_match = class_name.match(/ADM1-([-\w]*)/);
  var district_match = class_name.match(/ADM2-([-\w]*)\b/);

  if (!region_match || !district_match) {
    failed_paths.push(class_name);
    return undefined;
  }

  var region = parse_region(region_match[1]);
  var district = parse_district(district_match[1]);

  return make_key(region, district);
}

function apply_data_to_svg(data, svg) {
  var min = 0;
  var max = get_min_and_max_n(data)[1];

  var failed_paths = [];

  $(svg).find('path').each(function() {
    var svg_path = this;
    var key = get_key_from_svg_path(svg_path, failed_paths);
    var num = data[key] || 0;
    delete data[key];
    var color = n_to_color(num, min, max);

    failed_paths.push(key);
    console.log([key, num, color]);

    svg_path.setAttribute('style', 'fill:#' + color + ';stroke-width:.015;stroke:black;');
  });

  var failed_data = [];
  for (var failed_key in data) {
    failed_data.push(failed_key);
  }

  if (failed_paths.length || failed_data.length) {
    console.log('Failed paths:\n\n' + failed_paths.join('\n\n') + '\n\nFailed data:\n\n' + failed_data.join(';'));
  }
}

$NS().find('iframe').load(function() {
  var data = get_table_data();
  var svg = $(this).contents()[0];
  if (!data || !svg) return;
  apply_data_to_svg(data, svg);
});
