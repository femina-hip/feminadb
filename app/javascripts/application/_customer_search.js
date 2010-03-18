$('#customer_search_refine_submit').click(function(e) {
  e.preventDefault();
  refine_search();
});

$('#customer_search_refine_q').keypress(function(e) {
  if (e.keyCode == 13) {
    e.preventDefault(); // don't hit the big "Search" button
    refine_search(); // which will submit
  }
});

$('#customer_search_reset').click(function(e) {
  $('#customer_search_q').val('');
  // do default action of submitting form
});

function refine_search() {
  var $q = $('#customer_search_q');
  var $refine_term = $('#customer_search_refine_term');
  var $refine_q = $('#customer_search_refine_q');

  var term = $refine_term.val();
  var refine_q = $refine_q.val();
  var refine_q_match = refine_q.match(/ *(.*?) *$/);
  var r = refine_q_match[1];

  if (r) {
    var q = $q.val();
    if (r.indexOf(' ') != -1) {
      if (r.indexOf('"') == -1) {
        r = '"' + r + '"';
      }
    }
    $q.val(q + (q ? ' ' : '') + (term ? (term + ':') : '') + r);
    $q.parents('form').submit();
  }
}
