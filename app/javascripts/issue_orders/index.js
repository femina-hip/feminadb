$NS().find('td.qty form').each(function() {
	var $form = $(this);

	var $basic_inputs = $form.find('div.basic input');
	var $details = $form.find('div.details');

	var values_string = function() {
		return $form.find('input').map(function() { return $(this).val(); }).toArray().join(';');
	};

	var initial_values_string = values_string();

	var show_details = function() {
		$form.addClass('editing');
		if ($details.css('display') != 'block') {
			$details.css({display:'block', opacity:0});
			$details.animate({opacity:1}, {queue:false});
		}
	};

	var hide_details = function() {
		$form.removeClass('editing');
		$details.hide();
	};

	var show_details_iff_editing = function() {
		var current_values_string = values_string();
		if (current_values_string != initial_values_string) {
			show_details();
		} else {
			hide_details();
		}
	};

	$basic_inputs.bind('cut paste keyup keypress', show_details_iff_editing);

	$form.submit(function(e) {
		e.preventDefault();
		initial_values_string = values_string();
		$form.addClass('submitting');
		var $submit = $form.find('input[type=submit]');
		var $reset = $form.find('input[type=reset]');
		var original_submit_val = $submit.val();
		var original_reset_val = $reset.val();
		$submit.add($reset).attr('disabled', true);
		$submit.add($reset).val('Saving...');

		$.ajax({
			type: 'POST',
			url: $form.attr('action'),
			data: $form.serialize(),
			dataType: 'json',
			success: function() {
				$submit.add($reset).removeAttr('disabled');
				$submit.val(original_submit_val);
				$reset.val(original_reset_val);
			},
			failure: function() {
				$submit.val('Error');
				$form.addClass('error');
				alert("Your update wasn't saved because FeminaDB is not working perfectly. Please Refresh and try again.");
			},
			complete: function() {
				$form.removeClass('submitting');
				show_details_iff_editing();
			}
		});
	});

	$form.bind('reset', hide_details);
});
