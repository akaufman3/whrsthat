$(() => {
	$('dialog.phone .submit').click(function () {
		$.ajax({
			method: 'put',
			url: `/users/${$('meta[name="user-id"]').attr('content')}`,
			data: {
				authenticity_token: $('meta[name="csrf-token"]').attr('content'),
				phone: $('#user_phone').val()
			}
		}).done(() => {
			window.document.location.reload()
		})
	});

	$('dialog.phone .close').click(function () {
		$(() => { $('dialog.phone')[0].close(); })
	});
});