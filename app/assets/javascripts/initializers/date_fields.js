$('input.date_field').live('focus', function() {
  if (!this.has_datetime_picker_field) {
    this.has_datetime_picker_field = true;
    $(this).datetime_picker_field({
      calendar: {
        allow_deselect: true,
        previous_month_text: '<',
        next_month_text: '>'
      },
      parse_callback: function(s) { return Date.parse(s); },
      format_callback: function(d) { return d && d.toString('MMM d, yyyy') || ''; }
    });
    $(this).focus(); // to call up the calendar 
  }
});
