
var giftCardService = angular.module('mobileGiftCardWebApp');

giftCardService
    .factory('GiftCardGiftService', ['$http','$q', '$rootScope', 'ENV', function($http, $q, $rootScope, ENV){
        'use strict';
        var service = {};

        service.getGift = function(giftId) {
            var deferred = $q.defer();
            $http.get(ENV.apiRoot + 'GiftCardGift/' + giftId).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };


        return service;
    }])
    .value('version', '0.1');
