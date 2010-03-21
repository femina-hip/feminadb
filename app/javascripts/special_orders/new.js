var $tbody = $NS().find('tbody#lines');

var $last_row = $tbody.children(':last');
var $issue_field = $last_row.find('select.issue_field');
if ($issue_field.data('un_issue_field')) {
  $issue_field.data('un_issue_field')();
}
var $template_row = $last_row.clone(true);
$issue_field.issue_field();
$last_row = $issue_field = undefined;

function mark_remove_link($a) {
  $a.click(function(e) {
    e.preventDefault();

    if ($(this).closest('tr').siblings().length > 0) { // leave one behind
      $(this).closest('tr').remove();
    }
    mangle_ids($a.closest('tbody'));
  });
}

function mangle_ids($tbody) {
  var i = 0;
  $tbody.children().each(function() {
    $(this).find(':input').each(function() {
      var $input = $(this);
      var name = $input.attr('name');
      var id = $input.attr('id');
      $input.attr('name', name.replace(/^lines\[\d+/, 'lines[' + i));
      $input.attr('id', id.replace(/^lines_\d+/, 'lines_' + i));
    });

    i++;
  });
}

mark_remove_link($tbody.find('a'));

var $add_link = $tbody.next().find('a');
$add_link.click(function(e) {
  e.preventDefault();

  var $new_row = $template_row.clone(true);
  $new_row.find('select.issue_field').issue_field();
  $tbody.append($new_row);
  mangle_ids($tbody);
  mark_remove_link($new_row.find('a'));
});
