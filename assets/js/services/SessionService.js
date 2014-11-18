
angular.module('mobileGiftCardWebApp')
    .factory('SessionService', ['$http','$q', function($http, $q){
        'use strict';
        var service = {};
        var session = {};

        service.setPayload = function(newPayload) {
            session.payload = newPayload;
        };

        service.getPayload = function() {
            var copy = session.payload;
            delete session.payload;
            return copy;
        };

        return service;
    }])
    .value('version', '0.1');
