jQuery ->
  ($ "tr[data-tooltip]").tooltip()

  mapOptions = {
    zoom: 8
    center: new google.maps.LatLng(43.68227,-79.408493)
    mapTypeId: google.maps.MapTypeId.HYBRID
  }
  map = new google.maps.Map( ($ "#mapCanvas").get(0), mapOptions)

  markers = {}

  ($ ".show-map").click ->
    address = ($ this).attr 'data-address'
    geocoded_address = ($ this).data 'geocoded_address'

    showMap = =>
      location = geocoded_address[0].geometry.location
      formatted_address = geocoded_address[0].formatted_address

      marker = markers[formatted_address] ||= new google.maps.Marker {
        position: location
        map: map
      }
      map.setZoom 18
      map.setCenter location

      title = ($ this).closest('tr').attr('data-original-title')
      ($ "#mapTitle").html formatted_address + " <br/><small>" + title + "</small>"

      ($ "#map-container").modal('show')

    unless geocoded_address
      geocoder = new google.maps.Geocoder
      geocoder.geocode { address: address }, (results, status)=>
        ($ this).data 'geocoded_address', results
        ($ this).data 'geocoded_status', status
        geocoded_address = results
        showMap()
    else
      showMap()
