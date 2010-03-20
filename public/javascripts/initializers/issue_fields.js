$.fn.issue_field = function() {
  var REGEX = /^\[(.*?)\] (.*)$/;

  function filter_issue_field($select, $publication_select, $all_options) {
    var publication = $publication_select.val();
    $select.empty();
    $all_options.each(function() {
      var $option = $(this);
      var option_publication = $option.data('_report_form_publication');
      if (!option_publication) {
        var match = $option.text().match(REGEX);
        if (!match) return; // continue
        option_publication = match[1];
        $option.data('_report_form_publication', option_publication);
        $option.text(match[2]);
      }
      if (option_publication == publication) {
        $select.append($option);
      }
    });
  }

  return $(this).each(function() {
    var $select = $(this);
    var publications = [];
    var $all_options = $select.children();

    $all_options.each(function() {
      var match = $(this).text().match(REGEX);
      if (!match) return; // continue
      var publication = match[1];
      if (!publications.length || publication != publications[publications.length - 1]) {
        publications.push(publication);
      }
    });

    var $publication_select = $('<select class="publication_field"></select>');
    $.each(publications, function(i, publication) {
      var $option = $('<option></option>').text(publication);
      $publication_select.append($option);
    });
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
