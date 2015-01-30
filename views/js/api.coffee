
define [], ()->
	methods = 
		getLocations: (collection, bounds)-> 
			collection.get('locations').fetch({ 
				data: {
					box : { 			
						topLat: bounds._northEast.lat
						bottomLat: bounds._southWest.lat
						rightLng: bounds._northEast.lng
						leftLng: bounds._southWest.lng
					}
				},
				type: 'POST',
				processData: true
			})
		
	
	return methods