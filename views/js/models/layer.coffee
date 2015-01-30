define ['backbone', 'leaflet'], (Backbone, leaflet) ->

	Location = Backbone.Model.extend({
		initialize: () ->
			console.log('initializing location model: ')
			console.log( this)
			@set({'marker': new LocationMarker {model: this}})
			@on 'remove', ()->
				console.log('removed model')
		#promptColor: function() {
		#  this.set({color: "a thing"});
		#}
	})

	LocationCollection = Backbone.Collection.extend({
		model : Location,
		url : 'locations',
		initialize: ()-> 
			console.log('initializing collection')
			console.log(this)
			return


		create: (attributes, options) -> 
			#pass the collection's layer onto the marker so it knows where to render
			#return Backbone.Collection.prototype.create.call(
			#	this,
			#	_.extend({layerGroup: this.layerGroup}, attributes),
			#	options
			#)


	

	})

	
	Layer = Backbone.Model.extend({
		initialize: ()->
			locations = new LocationCollection

			locations.layer = this
			this.set({locations: locations})
			console.log('created layer model')
			console.log(this)

		})



	LocationMarker = Backbone.View.extend
		tagName: "???"
		className: "???"
		events:
			
			"click .icon": "open"
			"click .button.edit": "openEditDialog"
			"click .button.delete": "destroy"
			

		initialize: ->
			@listenTo @model, "add", @render
			@listenTo @model, 'remove', @remove
			console.log('view intialized')
			
			return

		render: ->
			console.log('rendering marker')
			@marker = L.marker(
				this.model.get('coordinates'),
				{opacity: .1}
			).on('add', ->
				console.log('add event fired')
				#@setOpacity(1)
				)
			
			marker = @marker
			
			
			console.log('the marker is ', @marker)
			#$(@marker._icon).css('opacity')
			@model.collection.layer.get('layerGroup').addLayer(@marker)
			#seems to take a little time for the element to make its way into the dom, at which point the transition will
			#apply and we can set the opacity.  only a few ms are needed so this seems an ok workaround.  another option would be
			#to listen to an added event on the layer which presumably fires after the dom is loaded
			
			setTimeout( =>
				console.log('setting opacity')
				marker.setOpacity(1)
			, 3)
			

		remove: ->
			console.log('removing marker')
			@model.collection.layer.get('layerGroup').removeLayer(@marker)


	return Layer
