$ ->
  $('#file_input_file').change () ->
    $(this).addClass('is-focused')
    reader = new FileReader()
    image = $(this)[0].files[0]

    EXIF.getData(image, () ->
      if !this or !this.exifdata or !this.exifdata.GPSLatitude
        $('#image-upload-toast')[0].MaterialSnackbar.showSnackbar({ message: "Sorry, the image you uploaded does not contain location data" });
        return

      GPSLatitude = this.exifdata.GPSLatitude
      GPSLongitude = this.exifdata.GPSLongitude
      lat = GPSLatitude[0] + (GPSLatitude[1]/60)+(GPSLatitude[2]/(60*60))
      lng = GPSLongitude[0] + (GPSLongitude[1]/60)+(GPSLongitude[2]/(60*60))
      lat = ((this.exifdata.GPSLatitudeRef == 'N') and lat) or (lat*-1)
      lng = ((this.exifdata.GPSLongitudeRef == 'E') and lng) or (lng*-1)
      
      $('.longitude').val(lng)
      $('.latitude').val(lat)  
      
      geo = new google.maps.Geocoder()
      geo.geocode({ location: { lat: lat, lng: lng } }, (results, status) =>
        if results and results[0] and results[0].formatted_address
          $('.address').typeahead('val', results[0].formatted_address).trigger('input')
          $('.place_id').val(results[0].place_id)
      )

      
      reader.readAsDataURL(image);
      reader.onload = (e) ->
        data_url = e.target.result;

        $('.sample').show()
        $('.sample img').attr('src',  data_url)
    ) 
