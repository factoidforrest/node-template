
var giftCardService = angular.module('mobileGiftCardWebApp');

giftCardService
    .factory('TestCardService', ['$http','$q', 'ENV', function($http, $q, ENV){
        'use strict';
        var service = {};

        service.getList = function() {
            var deferred = $q.defer();
            $http.get(ENV.apiRoot + 'TCCTestCard').success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        service.getCard = function(cardId) {
            var deferred = $q.defer();
            $http.get(ENV.apiRoot + 'TCCTestCard/' + cardId).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        service.activateCard = function(cardId, amount) {
            var deferred = $q.defer();
            $http.get(ENV.apiRoot + 'TCCTestCard/' + cardId + '/activate/' + amount).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        service.redeemCard = function(cardId, amount) {
            var deferred = $q.defer();
            $http.get(ENV.apiRoot + 'TCCTestCard/' + cardId + '/redeem/' + amount).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        service.echoMessage = function(message) {
            var deferred = $q.defer();
            $http.post(ENV.apiRoot + 'echoMessage', message).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };


        return service;
    }])
    .value('version', '0.1');
