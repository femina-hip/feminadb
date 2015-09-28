$.fn.issue_field = function() {
  var REGEX = /^\[(.*?)\] (.*)$/;

  function filter_issue_field($select, $publication_select, $all_options) {
    var value = $select.val();
    var publication = $publication_select.val();
    $select.empty();
    $all_options.each(function() {
      var $option = $(this);
      var option_publication = this._issue_field_publication;
      if (option_publication == publication) {
        $select.append($option);
      }
    });
    $select.val(value);

    if (!$select.children(':selected').length) {
      $select.val($select.children(':eq(0)').val());
    }
  }

  function switch_options_text($options) {
    $options.each(function() {
      var $option = $(this);
      var match = $option.text().match(REGEX);
      if (!match) return; // continue
      this._issue_field_publication = match[1];
      $option.text(match[2]);
    });
  }

  function find_publications($options) {
    var ret = [];
    $options.each(function() {
      var $option = $(this);
      publication = this._issue_field_publication;
      if (!ret.length || ret[ret.length - 1] != publication) {
        ret.push(publication);
      }
    });
    return ret;
  }

  function build_publication_select($select) {
    var $ret = $('<select class="publication_field"></select>');
    $select.children().each(function() {
      var $select_optgroup = $(this);

      var $optgroup = $('<optgroup></optgroup>').attr('label', $select_optgroup.attr('label'));

      var last_publication = undefined;

      $select_optgroup.children().each(function() {
        var $select_option = $(this);

        publication = this._issue_field_publication;
        if (last_publication != publication) {
          $optgroup.append($('<option></option>').text(publication));
          last_publication = publication;
        }
      });

      $ret.append($optgroup);
    });

    return $ret;
  }

  return $(this).each(function() {
    var $select = $(this);

    var $all_options = $select.find('option');
    switch_options_text($all_options);

    var $publication_select = build_publication_select($select);

    var $selected_option = $select.find('option:selected');
    if ($selected_option.length) {
      $publication_select.val($selected_option[0]._issue_field_publication);
    }

    $select.before($publication_select);

    $publication_select.change(function() {
      filter_issue_field($select, $publication_select, $all_options);
    });

    filter_issue_field($select, $publication_select, $all_options);
  });
};

$(function() {
  $('select.issue_field').issue_field();
});
