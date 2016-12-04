function strip(s) {
  return s.replace(/^\s*|\s*$/g, '');
}

function parse_number(s) {
  var stripped = strip(s).replace(/[^\d\.]/g, '');
  var value = parseFloat(stripped);
  if (value == Infinity || !!value == false || value < 0) {
    return 0; // We don't know what to do with NaN, Infinity or negatives
  } else {
    return value;
  }
}

function parse_string(s) {
  return strip(s).replace(/ /g, '-').toLowerCase();
}

function parse_region(text) {
  return parse_string(text);
}

function parse_council(text) {
  return parse_string(text);
}

function parse_num(text) {
  return s_to_float(text);
}

/*
 * The map has some weird council names, and so do we. Both have slight
 * mistakes. Not passing judgment, we'll make a "common key" which will be the
 * lowest common denominator. For instance, we only have one "unguja"; the map
 * only has one "dar-es-salaam"; so in the common key, there is only one
 * "unguja" and only one "dar-es-salaam".
 */
var MAP_KEY_TO_COMMON_KEY = {
  'kaskazini-pemba|micheweni-pemba': 'pemba|pemba',
  'kaskazini-pemba|wete-pemba': 'pemba|pemba',
  'kaskazini-unguja|zansibar-north': 'zanzibar|unguja',
  'kaskazini-unguja|zansibar-north-central': 'zanzibar|unguja',
  'kusini-pemba|chakechake': 'pemba|pemba',
  'kusini-pemba|mkoani': 'pemba|pemba',
  'kusini|zansibar-central': 'zanzibar|unguja',
  'kusini|zansibar-south': 'zanzibar|unguja',
  'mjini-magharibi|zansibar-town': 'zanzibar|unguja',
  'mjini-magharibi|zansibar-west': 'zanzibar|unguja',
  'morogoro|morogoro': 'morogoro|morogoro-urban',
  'shinyanga|shinyanga-rural': 'shinyanga|shinyanga',
  'shinyanga|shinyanga-urban': 'shinyanga|shinyanga'
};

var OUR_KEY_TO_COMMON_KEY = {
  'dar-es-salaam|': 'dar-es-salaam|dar-es-salaam',
  'dar-es-salaam|ilala': 'dar-es-salaam|dar-es-salaam',
  'dar-es-salaam|kinondoni': 'dar-es-salaam|dar-es-salaam',
  'dar-es-salaam|temeke': 'dar-es-salaam|dar-es-salaam',
  'dodoma|dodoma-rural': 'dodoma|dodoma',
  'dodoma|dodoma-urban': 'dodoma|dodoma',
  'dodoma|kongwa': 'dodoma|dodoma',
  'iringa|iringa-rural': 'iringa|iringa',
  'iringa|iringa-urban': 'iringa|iringa',
  'kagera|bukoba-rural': 'kagera|bukoba',
  'kagera|bukoba-urban': 'kagera|bukoba',
  'kilimanjaro|moshi': 'kilimanjaro|moshi-urban',
  'kigoma|kigoma-rural': 'kigoma|kigoma',
  'kigoma|kigoma-urban': 'kigoma|kigoma',
  'lindi|lindi-rural': 'lindi|lindi',
  'lindi|lindi-urban': 'lindi|lindi',
  'lindi|ruangwa': 'lindi|lindi',
  'mara|musoma-rural': 'mara|musoma',
  'mara|musoma-urban': 'mara|musoma',
  'mbeya|mbeya-rural': 'mbeya|mbeya',
  'mbeya|mbeya-urban': 'mbeya|mbeya',
  'morogoro|morogoro': 'morogoro|morogoro-urban',
  'mtwara|mtwara-rural': 'mtwara|mtwara',
  'mtwara|mtwara-urban': 'mtwara|mtrawa',
  'mtwara|tandahimba': 'mtwara|mtwara',
  'rukwa|sumbawanga-rural': 'rukwa|sumbawanga',
  'ruvuma|songea-rural': 'ruvuma|songea',
  'ruvuma|songea-urban': 'ruvuma|songea',
  'singida|singida-municipal': 'singida|singida',
  'singida|singida-rural': 'singida|singida',
  'singida|singida-urban': 'singida|singida',
};

function make_key(region, council, is_our_notation) {
  var key = region + '|' + council;
  if (is_our_notation) {
    return OUR_KEY_TO_COMMON_KEY[key] || key;
  } else {
    return MAP_KEY_TO_COMMON_KEY[key] || key;
  }
}

/*
 * Returns Object of { common_key: Number }
 */
function get_table_data() {
  var $table = $('#report');
  var ret = {};

  $table.find('tbody tr').each(function() {
    var $tr = $(this);
    var region = parse_region($tr.children('td:eq(0)').text());
    var council = parse_council($tr.children('td:eq(1)').text());
    var n = parse_number($tr.children('td:eq(2)').text());

    var key = make_key(region, council, true);

    // Sometimes two council merge in the map, so we'll add the numbers
    if (!ret[key]) ret[key] = 0;
    ret[key] += n;
  });

  return ret;
}

function path_class_to_key(class_name) {
  if (!/\bmi-region\b/.test(class_name)) return undefined;
  var region_match = class_name.match(/ADM1-([-\w]*)/);
  /* council must match "ADM2-(Moshi Rural) ..." (a bug in the map data) */
  var council = class_name.match(/ADM2-([- \w]*?) mi-TAN/);

  if (!region_match || !council) return undefined;

  var region = parse_region(region_match[1]);
  var council = parse_council(council[1]);

  var key = make_key(region, council, false);

  if (/-lake$/.test(key)) return '#0000ff'; // it's a lake

  return key;
}

$('iframe.svg-map').load(function() {
  var $iframe = $(this);
  var svg = $iframe.contents()[0];
  var data = get_table_data();

  map = new SvgMap(svg, data, path_class_to_key, {
    partitions: 5,
    include_zero_partition: true,
    style: "fill:#{color};stroke-width:.015;stroke:black;"
  });

  var legend_div = map.createLegendDiv();
  if (legend_div) {
    $iframe.after(legend_div);
  }
});
