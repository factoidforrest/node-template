define(['backbone', 'leaflet'], function(Backbone, leaflet) {
  var Location, LocationCollection, LocationMarker;
  Location = Backbone.Model.extend({
    initialize: function() {
      var locationMarker;
      console.log('initializing: ');
      console.log(this);
      return locationMarker = new LocationMarker({
        model: this
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
  LocationMarker = Backbone.View.extend({
    tagName: "???",
    className: "???",
    events: {
      "click .icon": "open",
      "click .button.edit": "openEditDialog",
      "click .button.delete": "destroy"
    },
    initialize: function() {
      console.log(this);
      console.log(this.listenTO);
      console.log(this.model);
      console.log(this.render);
      this.listenTo(this.model, "add", this.render);
      console.log('view intialized');
      this.render;
    },
    render: function() {
      var marker;
      console.log('rendering marker');
      marker = L.marker([this.model.lat, this.model.lng]);
      return this.model.collection.layerGroup.addLayer(marker);
    }
  });
  return LocationCollection;
});
