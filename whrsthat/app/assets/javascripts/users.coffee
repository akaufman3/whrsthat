# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$('input[type="password"]').addClass('mdl-textfield__input')

	$('.create').click () ->
		window.document.location = '/users/new'
		return false
		
	$('#user_phone').keyup((e) =>
		num = $('#user_phone').val()
		if num.indexOf('+') is -1
			num = "+1#{num}"
			$('#user_phone').val(num)
	)

