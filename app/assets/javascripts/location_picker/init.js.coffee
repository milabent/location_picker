config =
  tileLayer: "http://otile{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png"
  subdomains: "1234"
  attribution: '<a href="http://www.openstreetmap.org/copyright" title="ODbL">CC by OSM</a>'
  maxZoom: 18
  latitude: 54.0857
  longitude: 12.1426
  geoLocationSearchPath: "/location_picker/locations.json"
  defaultZoom: 10
  markerZoom: 16


$ () ->
  $('*[data-picker=location]').each () ->
    new LocationSelector($(this))

uniqMapId = 0
addUniqIdToMapDiv = (mapDiv) ->
  uniqMapId++
  mapDiv.attr('id', "map-id-#{uniqMapId}") unless mapDiv.attr('id')
  mapDiv.attr('id')  

buildLatLng = (latitude, longitude) ->
  L.latLng(parseFloat(latitude), parseFloat(longitude))

class LocationSelector
  constructor: (@context) ->
    @fieldPrefix = @context.data('field-prefix') + "_"

    @loadPositionFromInput()
    @loadMap()
    @handleActions()

  handleActions: () =>
    infoPanel = $('.location-picker-loading', @context)
    errorPanel = $('.location-picker-address-error', @context)
    $('.location-picker-reset-button', @context).click () => @resetPosition()
    $('.location-picker-search-button', @context).click () =>
      infoPanel.stop(true).hide().fadeIn()

      street      = @inFormId("street").val()
      number      = @inFormId("house_number").val()
      postalCode  = @inFormId("postal_code").val()
      locality    = @inFormId("locality").val()

      locationSearch = new GeoLocationSearch(number, street, postalCode, locality)
      locationSearch.run((@position) =>
        @setMarkerPosition()
        @savePositionToInput()
        @setMarker(true)
        infoPanel.fadeOut()
      , () =>
        infoPanel.stop(true).hide()
        errorPanel.stop(true).hide().fadeIn ->
          window.setTimeout(
            () -> errorPanel.fadeOut(),
            3000
          )
      )

  loadMap: () =>
    mapId = addUniqIdToMapDiv(@context.find('.location-picker-map'))
    @map = new L.Map mapId,
      zoomControl: false
      attributionControl: false
      maxZoom: config.maxZoom
    @map.addLayer(L.tileLayer(config.tileLayer,
      attribution: config.attribution,
      subdomains: config.subdomains
    ))
    @map.addControl(L.control.attribution(prefix: false))
    @map.addControl(L.control.zoom(position: 'topright'))
    @map.setView(@position, @zoom)

    @marker = L.marker(@position,
      draggable: true
    ).on('dragend', () =>
      @position = @marker.getLatLng()
      @savePositionToInput()
    )

    if @markerSetBefore
      @setMarker(true)
    else
      @map.on 'click', (event) =>
        unless @map.hasLayer(@marker)
          @position = event.latlng
          @setMarkerPosition()
          @savePositionToInput()
          @setMarker(true)


  inFormId: (field) =>
    $("##{@fieldPrefix}#{field}", @form)

  loadPositionFromInput: () =>
    latitude = parseFloat(@inFormId('latitude').val())
    longitude = parseFloat(@inFormId('longitude').val())

    if isNaN(latitude) || isNaN(longitude)
      latitude = config.latitude
      longitude = config.longitude
      @markerSetBefore = false
      @zoom = config.defaultZoom
    else
      @markerSetBefore = true
      @zoom = config.markerZoom
    @position = buildLatLng(latitude, longitude)
    @originalPosition = @position

  isDefaultLocation: () =>
    !@markerSetBefore and @position.equals(buildLatLng(config.latitude, config.longitude))

  savePositionToInput: () =>
    if @isDefaultLocation()
      @inFormId('latitude').val("")
      @inFormId('longitude').val("")
    else
      @inFormId('latitude').val(@position.lat)
      @inFormId('longitude').val(@position.lng)

  setMarkerPosition: () =>
    @marker.setLatLng(@position)
    @map.panTo(@position)
    if @isDefaultLocation() 
      @map.setZoom(config.defaultZoom)
    else 
      @map.setZoom(config.markerZoom)

  setMarker: (onMap) =>
    if onMap
      @map.addLayer(@marker)
    else
      @map.removeLayer(@marker)

  resetPosition: () =>
    @position = @originalPosition
    @setMarkerPosition()
    @savePositionToInput()
    @setMarker(@markerSetBefore)

class GeoLocationSearch
  constructor: (@number, @street, @postalCode, @locality) ->

  run: (@successCallback, @failureCallback) =>
    $.ajax
      url: config.geoLocationSearchPath
      dataType: "json"
      timeout: 15000
      type: 'POST'
      data:
        geo_location_search:
          postal_code: @postalCode
          locality: @locality
          street: @street
          house_number: @number
      success: (data) =>
        unless data.result
          @failureCallback()
        else
          @successCallback(buildLatLng(data.latitude, data.longitude))
      fail: () =>
        @failureCallback()
