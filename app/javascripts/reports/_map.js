function strip(s) {
  return s.replace(/^\s*|\s*$/g, '');
}

function s_to_number(s) {
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

/*
 * The map has some weird district names, and so do we. Both have slight
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

function make_key(region, district, is_our_notation) {
  var key = region + '|' + district;
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
    var region = normalize_s($tr.children('td:eq(0)').text());
    var district = normalize_s($tr.children('td:eq(1)').text());
    var n = s_to_number($tr.children('td:eq(2)').text());

    var key = make_key(region, district, true);

    // Sometimes two districts merge in the map, so we'll add the numbers
    if (!ret[key]) ret[key] = 0;
    ret[key] += n;
  });

  return ret;
}

function DataAnalysis(data, hints) {
  this.data = data;
  this.hints = hints;

  this._analyze();
}

$.extend(DataAnalysis.prototype, {
  _analyze: function() {
    if (this.data_as_list) return;

    this.data_as_list = [];

    for (var key in this.data) {
      this.data_as_list.push(this.data[key]);
    }

    this.data_as_list.sort(function(a, b) { return a - b; });

    this.min = this.data_as_list[0];
    this.max = this.data_as_list[this.data_as_list.length - 1];

    if (this.hints.num_partitions) {
      this._calculate_partitions();
    }
  },

  _calculate_partitions: function() {
    this.partitions = [];

    if (this.zero_partition) {
      this.partitions.push(0);
    }

    var interval = this.max / (this.hints.num_partitions + 1);

    for (var i = 0; i < this.hints.num_partitions; i++) {
      this.partitions.push(i * interval);
    }
  },

  _get_color_for_fraction: function(x) {
    if (x < 0) x = 0;
    if (x > 1) x = 1;

    var letters = Math.floor(255 - (255 * x)).toString(16);
    if (letters.length == 1) letters = '0' + letters;

    return "#ff" + letters + letters; // shades of red
  },

  get_color_for_data_point: function(num) {
    if (this.partitions) {
      var partition;

      for (partition = 0; partition < this.partitions.length; partition++) {
        if (this.partitions[partition] >= num) {
          break;
        }
      }
      if (partition > this.partitions.length) {
        partition = this.partitions.length - 1;
      }

      return this._get_color_for_fraction(partition / (this.partitions.length - 1));
    } else {
      if (this.max > 0) {
        return this._get_color_for_fraction(num / this.max);
      } else {
        return '#ffffff';
      }
    }
  }
});

function analyze_data(data, hints) {
  return new DataAnalysis(data, hints);
}

function get_key_from_svg_path(svg_path, failed_paths) {
  var class_name = svg_path.getAttribute('class');
  if (!/\bmi-region\b/.test(class_name)) return undefined;
  var region_match = class_name.match(/ADM1-([-\w]*)/);
  /* district must match "ADM2-(Moshi Rural) ..." (a bug in the map data) */
  var district_match = class_name.match(/ADM2-([- \w]*?) mi-TAN/);

  if (!region_match || !district_match) {
    failed_paths.push(class_name);
    return undefined;
  }

  var region = parse_region(region_match[1]);
  var district = parse_district(district_match[1]);

  return make_key(region, district, false);
}

function apply_data_to_svg(data, svg, analysis) {
  var failed_paths = [];
  var succeeded_paths = {};

  $(svg).find('path').each(function() {
    var svg_path = this;
    var key = get_key_from_svg_path(svg_path, failed_paths);

    var color;

    if (/-lake$/.test(key)) {
      color = '#0000ff'; // It's a lake
    } else {
      var num = data[key] || 0;
      succeeded_paths[key] = null;
      var color = analysis.get_color_for_data_point(num);

      if (data[key] === undefined) {
        failed_paths.push(key);
      }
    }

    svg_path.setAttribute('style', 'fill:' + color + ';stroke-width:.015;stroke:black;');
  });

  var failed_data = [];
  for (var failed_key in data) {
    if (succeeded_paths[failed_key] !== null) {
      failed_data.push(failed_key);
    }
  }

  if (failed_paths.length || failed_data.length) {
    //console.log('Failed paths:\n\n' + failed_paths.join('\n') + '\n\nFailed data:\n\n' + failed_data.join('\n'));
  }
}

function make_legend_li(color, num) {
  return $('<li style="list-style:none;clear:both;margin:0;padding:0;white-space:nowrap"><div style="float:left;width:1em;height:1em;padding:2px;margin-right:2px;background:' + color + ';"></div> up to <input type="text" value="' + num + '" style="width:4em;" /></li>');
}

function show_legend(data, analysis, svg) {
  var $legend = $('<form class="legend" action="" style="float:left;border:2px solid black;padding:12px;"></form>');

  var $ul = $('<ul></ul>');
  $.each(analysis.partitions, function() {
    var num = this;
    var color = analysis.get_color_for_data_point(num);
    $ul.append(make_legend_li(color, num));
  });

  $legend.append($ul);
  $NS().prepend($legend);

  $legend.submit(function(e) {
    e.preventDefault();
  });

  $legend.find('input').change(function() {
    var $input = $(this);
    var $li = $input.parent();
    var index = $li.prevAll().length;

    analysis.partitions[index] = parseFloat($input.val());
    apply_data_to_svg(data, svg, analysis);
  });
}

$NS().find('iframe').load(function() {
  var $hints = $NS().find('.hints');
  var hints = $hints.length ? eval('(' + $hints.text() + ')') : {};
  var data = get_table_data();
  var svg = $(this).contents()[0];
  var analysis = analyze_data(data, hints);

  if (!data || !svg) return;
  apply_data_to_svg(data, svg, analysis);

  if (analysis.partitions) {
    show_legend(data, analysis, svg);
  }
});
