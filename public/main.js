requirejs.config({
  waitSeconds: 15,
  paths: {
    jquery: ["components/jquery/dist/jquery.min"],
    bootstrap: ["components/bootstrap/dist/js/bootstrap.min"],
    async: ["components/requirejs-plugins/src/async"],
    leaflet: ["components/leaflet/dist/leaflet"],
    leaflet_locate: ["components/leaflet.locatecontrol/dist/L.Control.Locate.min"],
    leaflet_geoip: ["libs/leaflet-geoip"],
    underscore: ['components/underscore/underscore'],
    backbone: ["components/backbone/backbone"],
    layer: ["models/layer"]
  },
  shim: {
    bootstrap: ["jquery"],
    leaflet_locate: ['leaflet'],
    leaflet_geoip: ['leaflet']
  }
});

require(["jquery", "bootstrap", "map"], function($, bs, Map) {
  return window.mapAPI = new Map();
});
