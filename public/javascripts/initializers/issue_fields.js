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

  function reset_options_text($options) {
    $options.each(function() {
      var $option = $(this);
      publication = this._issue_field_publication;
      $option.removeData('_issue_field_publication');
      $option.text('[' + publication + '] ' + $option.text());
    });
  }

  return $(this).each(function() {
    var $select = $(this);
    var $all_options = $select.children();

    switch_options_text($all_options);
    var publications = find_publications($all_options);

    var $publication_select = $('<select class="publication_field"></select>');
    $.each(publications, function(i, publication) {
      var $option = $('<option></option>').text(publication);
      $publication_select.append($option);
    });
    var $selected_option = $select.children(':selected');
    if ($selected_option.length) {
      console.log($selected_option[0]._issue_field_publication);
      $publication_select.val($selected_option[0]._issue_field_publication);
    }
    $select.before($publication_select);

    $publication_select.change(function() {
      filter_issue_field($select, $publication_select, $all_options);
    });

    filter_issue_field($select, $publication_select, $all_options);

    $select.data('un_issue_field', function() {
      var value = $select.val();
      $publication_select.remove();
      $select.empty();
      reset_options_text($all_options);
      $select.append($all_options);
      $select.removeData('un_issue_field');
      $select.val(value);
    });
  });
};

$(function() {
  $('select.issue_field').issue_field();
});
