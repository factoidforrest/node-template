#define ["goog!maps,3"] , ->
define ['layer', 'api', 'leaflet', 'leaflet_locate', 'leaflet_geoip'] , (Layer, API) ->

	class Map

		constructor: ()->
			self = this
			console.log("map initializing")

			window.map = @map = map = L.map('map').setView([51.505, -0.09], 11)
			#L.GeoIP.centerMapOnPosition(map)
			lc = L.control.locate(locateOptions).addTo(map)
			lc.locate()
			L.tileLayer('http://{s}.tiles.mapbox.com/v3/light24bulbs.k6c8a0kc/{z}/{x}/{y}.png', {
				attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
				maxZoom: 18
			}).addTo(map);

			#make a function which does this and pass in a few layers
			@storesLayer = L.layerGroup()
			@stores = new Layer {layerGroup: @storesLayer}
			@storesLayer.addTo(@map)

			#listeners
			map.on('moveend', @populate)
		

		#move the core logic here to another class called API
		populate: (e) =>
			bounds = @map.getBounds()
			API.getLocations(@stores, bounds)



	#CLASS ENDS
			





	#locate plugin has some serious options, get passed in above

	locateOptions = {
		position: "topleft" # set the location of the control
		drawCircle: true # controls whether a circle is drawn that shows the uncertainty about the location
		follow: true # follow the user's location
		setView: true # automatically sets the map view to the user's location, enabled if `follow` is true
		keepCurrentZoomLevel: true # keep the current map zoom level when displaying the user's location. (if `false`, use maxZoom)
		maxZoom: 12
		stopFollowingOnDrag: true # stop following when the map is dragged if `follow` is true (deprecated, see below)
		remainActive: true # if true locate control remains active on click even if the user's location is in view.
		markerClass: L.circleMarker # L.circleMarker or L.marker
		circleStyle: {} # change the style of the circle around the user's location
		markerStyle: {}
		followCircleStyle: {} # set difference for the style of the circle around the user's location while following
		followMarkerStyle: {}
		icon: "fa fa-map-marker" # class for icon, fa-location-arrow or fa-map-marker
		iconLoading: "fa fa-spinner fa-spin" # class for loading icon
		circlePadding: [ # padding around accuracy circle, value is passed to setBounds
			0
			0
		]
		metric: true # use metric or imperial units
		onLocationError: (err) -> # define an error callback function
			alert err.message
			return

		onLocationOutsideMapBounds: (context) -> # called when outside map boundaries
			alert context.options.strings.outsideMapBoundsMsg
			return

		showPopup: true # display a popup when the user click on the inner marker
		strings:
			title: "Show me where I am" # title of the locate control
			popup: "You are within {distance} {unit} from this point" # text to appear if user clicks on circle
			outsideMapBoundsMsg: "You seem located outside the boundaries of the map" # default message for onLocationOutsideMapBounds

		locateOptions: {} # define location options e.g enableHighAccuracy: true or maxZoom: 10
	 }

	return Map
