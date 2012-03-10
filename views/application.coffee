jQuery ->
  ($ "tr[data-tooltip]").tooltip({ placement: 'left' })

  ($ "a[rel=external]").click (e)->
    url = ($ this).attr 'href'
    e.preventDefault()
    window.open(url)

  ($ "img.thumb").each ->
    $self = ($ this)
    url = $self.attr('src')
    $content = ($ "<img src='#{url}' />")
    setupPopup = =>
      [width, height] = [$content.width(), $content.height()]
      clearTimeout $content.data 'loadTimeout'
      unless width > 0 && height > 0
        return $content.data 'loadTimeout', setTimeout(setupPopup, 200)

      $content.hide()
      $self.popover {
        placement: 'left'
        content: "<img src='#{url}' style='width#{width}px;height:#{height}px' />"
      }

    $content.load =>
      setupPopup()

    $content.appendTo ($ 'body')

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
