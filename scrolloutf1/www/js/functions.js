jQuery(document).ready(function() {
	if (0 < $('#total_inputs').length) {
		var ELEMENTS = $('#total_inputs').val();
	}
	else {
		var ELEMENTS = 1;
	} 
	var _master = $('.master');
	$('.button_add').click(function () {
		var _new = $('.input:last', _master).clone();
		$('.remove', _new).remove();
		ELEMENTS++;
		var current_id = parseInt($('INPUT:first', _new).prop('class').replace('domain', ''));
		$('LABEL', _new).each(function (i){
			$(this).prop('for', $(this).prop('for').replace(current_id, ELEMENTS)).text($(this).text().replace(current_id, ELEMENTS));
		});
		$('INPUT', _new).each(function (i){
			$(this).prop('id', $(this).prop('id').replace(current_id, ELEMENTS)).prop('class', $(this).prop('class').replace(current_id, ELEMENTS)).text($(this).text().replace(current_id, ELEMENTS)).val('');
		});
		$('INPUT:last', _new).after('<a href="javascript: void(0);" class="remove"><b>[X]</b></a>');
		$('.button_add', _master).before(_new);
	});
	$('.remove').live('click', function (event) {
		event.preventDefault();
		if (confirm('Are you sure you want to permanently delete this record?')) {
			$(this).parent().remove();
		}
		return false;
	});
});
