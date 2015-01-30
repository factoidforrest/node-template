define(['backbone', 'leaflet'], function(Backbone, leaflet) {
  var Layer, Location, LocationCollection, LocationMarker;
  Location = Backbone.Model.extend({
    initialize: function() {
      console.log('initializing location model: ');
      console.log(this);
      this.set({
        'marker': new LocationMarker({
          model: this
        })
      });
      return this.on('remove', function() {
        return console.log('removed model');
      });
    }
  });
  LocationCollection = Backbone.Collection.extend({
    model: Location,
    url: 'locations',
    initialize: function() {
      console.log('initializing collection');
      console.log(this);
    },
    create: function(attributes, options) {}
  });
  Layer = Backbone.Model.extend({
    initialize: function() {
      var locations;
      locations = new LocationCollection;
      locations.layer = this;
      this.set({
        locations: locations
      });
      console.log('created layer model');
      return console.log(this);
    }
  });
  LocationMarker = Backbone.View.extend({
    tagName: "???",
    className: "???",
    events: {
      "click .icon": "open",
      "click .button.edit": "openEditDialog",
      "click .button.delete": "destroy"
    },
    initialize: function() {
      this.listenTo(this.model, "add", this.render);
      this.listenTo(this.model, 'remove', this.remove);
      console.log('view intialized');
    },
    render: function() {
      var marker;
      console.log('rendering marker');
      this.marker = L.marker(this.model.get('coordinates'), {
        opacity: .1
      }).on('add', function() {
        return console.log('add event fired');
      });
      marker = this.marker;
      console.log('the marker is ', this.marker);
      this.model.collection.layer.get('layerGroup').addLayer(this.marker);
      return setTimeout((function(_this) {
        return function() {
          console.log('setting opacity');
          return marker.setOpacity(1);
        };
      })(this), 3);
    },
    remove: function() {
      console.log('removing marker');
      return this.model.collection.layer.get('layerGroup').removeLayer(this.marker);
    }
  });
  return Layer;
});
