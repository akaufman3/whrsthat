$ =>	
	$('.new-event').click () =>
		window.document.location = '/events/new'

	$('.submit-invite').click () ->
		$('form.new_event_user').submit()
		return false

	$('#event_user_number').attr('type', 'tel')

	$('.demo-card-event .delete').click () ->
		button = $(this)
		ev = $(this).parents('.event')
		$.ajax({
			method: 'delete',
			url: '/events/'+$(ev).attr('data-id')
		})
		.done(() ->
			$(ev).fadeOut()
		)
		return false

	$('.invitation .delete').click () ->
		button = $(this)
		inv = $(this).parents('.invitation')
		$.ajax({
			method: 'delete',
			url: '/events/'+$('meta[name="event-id"]').attr('content')+'/'+$(inv).attr('data-id')
		})
		.done(() ->
			$(inv).remove()
		)
		return false

	$('#event_user_number').keyup((e) =>
		num = $('#event_user_number').val()
		if num.indexOf('+') is -1
			num = "+1#{num}"
			$('#event_user_number').val(num)
	)

	$('#event_switch').change () ->
		if $('#event_switch').is(':checked')
			$('.Events').hide()
			$('.Invitations').show()
			$('.status').text("you've been invited to")
		else
			$('.Events').show()
			$('.Invitations').hide()
			$('.status').text("you've created")
	$('#event_switch').click()

	$('#event_time_at').datetimepicker()

	if $('input.address').length
		window.addressPicker = addressPicker = new AddressPicker({
			map: {
				id: '#new_map'
			}
		})

		$('.address').typeahead(null, {
	    displayKey: 'description',
	    source: addressPicker.ttAdapter()
	  })

		$('.address').bind('typeahead:selected', addressPicker.updateMap);
		$('.address').bind('typeahead:cursorchanged', addressPicker.updateMap);
		$('.address').bind('typeahead:change', addressPicker.updateMap);

		$(addressPicker).on('addresspicker:selected', (event, result) =>
			debugger
			$('.longitude').val(result.lng())
			$('.latitude').val(result.lat())
			$('.place_id').val(result.placeResult.place_id)
			
		)