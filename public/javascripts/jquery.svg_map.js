/*
 * This big block defines window.SvgMap.
 *
 * It requires jQuery.
 */
(function($) {
  var VERBOSE = false;

  function SvgMapDataAnalysis(data, options) {
    this.data = data;
    this.options = options;

    this.data_as_list = [];
    for (var key in this.data) {
      this.data_as_list.push(this.data[key]);
    }
    this.data_as_list.sort(function(a, b) { return a - b; });

    this.min = 0;
    this.max = this.data_as_list[this.data_as_list.length - 1];

    if (this.options.partitions) {
      this._calculatePartitions();
    }
  }

  $.extend(SvgMapDataAnalysis.prototype, {
    _calculatePartitions: function() {
      /*
       * We don't know anything about the semantics of the data, so let's just
       * divide it into categories: if there's a 0 we'll put 0 into its own
       * category, otherwise we'll divide the data into this.options.partitions
       * equally-populated partitions.
       */
      this.partitions = [];

      var start = 0;
      var values = this.data_as_list;

      if (values[0] == 0 || this.options.include_zero_partition) {
        this.partitions.push(0);
        for (start = 0; values[start] == 0 && start < values.length; start++) {}
      }

      var nValues = values.length - start;
      var nBuckets = this.options.partitions - this.partitions.length;

      var interval = nValues / nBuckets;

      for (var i = 1; i <= nBuckets; i++) {
        var x = i * interval;
        var index = Math.round(x) - 1;
        this.partitions.push(values[index]);
      }
    },

    /* Returns an HTML color for 0 <= x <= 1 */
    _lookupColorForFraction: function(x) {
      if (x < 0) x = 0;
      if (x > 1) x = 1;

      var letters = Math.floor(255 - (255 * x)).toString(16);
      if (letters.length == 1) letters = '0' + letters;

      return "#ff" + letters + letters; // shades of red
    },

    /* Returns an HTML color for one of the points in our data */
    lookupColor: function(value) {
      if (this.partitions) {
        var partition;

        for (partition = 0; partition < this.partitions.length; partition++) {
          if (this.partitions[partition] >= value) {
            break;
          }
        }
        if (partition > this.partitions.length) {
          partition = this.partitions.length - 1;
        }

        var x = partition / (this.partitions.length - 1);
        return this._lookupColorForFraction(x);
      } else {
        if (this.max > 0) {
          return this._lookupColorForFraction(value / this.max);
        } else {
          return '#ffffff';
        }
      }
    }
  });

  function SvgMapWalker(svg, data, analysis, pathClassToKey, options) {
    this.svg = svg;
    this.data = data;
    this.analysis = analysis;
    this.pathClassToKey = pathClassToKey;

    this.options = $.extend({
      style: 'fill:#{color};stroke-width:.015;stroke:black;'
    }, options);
  }

  $.extend(SvgMapWalker.prototype, {
    _getKeyFromPath: function(path) {
      var class_name = path.getAttribute('class');
      return this.pathClassToKey(class_name);
    },

    _logUnusedKeys: function(path_keys, data_keys) {
      if (!VERBOSE) return;

      console.log("These keys were in the SVG file but not in the dataset:\n" + path_keys.join("\n"));
      console.log("These keys were in the dataset but not in the SVG:\n" + data_keys.join("\n"));
    },

    refresh: function() {
      var unused_path_keys = [];
      var unused_data_keys = [];
      var used_keys = {};

      var _this = this;
      $(this.svg).find('path').each(function() {
        var path = this;
        var key = _this._getKeyFromPath(path);

        var color;
        if (/^#[\da-f]{6}$/.test(key)) {
          // the key is a color; use that instead
          color = key;
        } else {
          if (_this.data[key] === undefined) {
            unused_path_keys.push(key);
          }
          used_keys[key] = true; // we color it even if it's invalid

          var value = _this.data[key] || 0;
          color = _this.analysis.lookupColor(value);
        }

        var style = _this.options.style.replace('#{color}', color);
        path.setAttribute('style', style);
      });

      for (var data_key in this.data) {
        if (!used_keys[data_key]) {
          unused_data_keys.push(data_key);
        }
      }

      this._logUnusedKeys(unused_path_keys, unused_data_keys);
    }
  });

  /*
   * Shows data on an SVG map.
   *
   * Parameters:
   * - svg: an <svg> element
   * - data: an Object mapping (String) "key" to (Number) value >= 0
   * - pathClassToKey: a function which accepts an SVG path element's "class"
   *                   attribute and returns a (String) "key"
   * - options: options...
   *   - "partitions": Integer greater than 1, saying how many different colors
   *                   will be drawn. If unset, will use 256 colors.
   *   - "style": style to set on path elements. "#{color}" will be replaced
   *              with the color SvgMap chooses. Default is
   *              "fill:#{color};stroke-width:.015;stroke:black;"
   */
  function SvgMap(svg, data, pathClassToKey, options) {
    this.svg = svg;
    this.pathClassToKey = pathClassToKey;
    this.options = options || {};

    this.setData(data);
  }

  $.extend(SvgMap.prototype, {
    setData: function(data) {
      this.data = data;
      this.analysis = new SvgMapDataAnalysis(data, this.options);
      this.walker = new SvgMapWalker(this.svg, this.data, this.analysis, this.pathClassToKey, this.options);

      this.walker.refresh();
    },

    _createLegendLi: function(value, color) {
      var $li = $('<li><div class="svg-map-swatch" style="background-color:' + color + ';"> </div> up to <input type="text" value="' + value + '" /></li>');
      return $li;
    },

    createLegendDiv: function() {
      if (!this.options.partitions) return undefined;
      var _this = this;

      var $legend = $('<form class="svg-map-legend" action=""></form>');
      var $ul = $('<ul></ul>');

      $.each(this.analysis.partitions, function() {
        var value = this;
        var color = _this.analysis.lookupColor(value);
        $ul.append(_this._createLegendLi(value, color));
      });

      $legend.append($ul);

      $legend.submit(function(e) { e.preventDefault(); });
      $legend.find('input').change(function() {
        var $input = $(this);
        var $li = $input.parent();
        var index = $li.prevAll().length;

        _this.analysis.partitions[index] = parseFloat($input.val());
        _this.walker.refresh();
      });

      return $legend[0];
    }
  });

  window.SvgMap = SvgMap;

})(jQuery);
