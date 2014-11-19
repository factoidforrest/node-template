
var giftCardService = angular.module('mobileGiftCardWebApp');

giftCardService
    .factory('GiftCardService', ['$http','$q', '$rootScope', 'ENV', function($http, $q, $rootScope, ENV){
        'use strict';
        var service = {};

        service.getList = function() {
            var deferred = $q.defer();
            $http.get(ENV.apiRoot + 'GiftCard/').success(function(data) {
                deferred.resolve(data);
            }).error(function() {
                $rootScope.$emit("NotLoggedIn");
            });
            return deferred.promise;
        };

        service.getAcceptList = function() {
            var deferred = $q.defer();
            $http.get(ENV.apiRoot + 'GiftCard/waiting').success(function(data) {
                deferred.resolve(data);
            }).error(function() {
                $rootScope.$emit("NotLoggedIn");
            });
            return deferred.promise;
        };

        service.add = function(card) {
            var deferred = $q.defer();
            $http.post(ENV.apiRoot + 'GiftCard', card).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        service.gift = function(card, gift) {
            var deferred = $q.defer();
            $http.post(ENV.apiRoot + 'GiftCard/' + card.id + '/gift', gift).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        service.buy = function(card) {
            var deferred = $q.defer();
            $http.post(ENV.apiRoot + 'GiftCard/buy', card).success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };


        service.ungift = function(card) {
            var deferred = $q.defer();
            $http.post(ENV.apiRoot + 'GiftCard/' + card.id + '/ungift').success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        service.rejectgift = function(card) {
            var deferred = $q.defer();
            $http.post(ENV.apiRoot + 'GiftCard/' + card.giftCardId + '/rejectgift').success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };
        service.acceptgift = function(card) {
            var deferred = $q.defer();
            $http.post(ENV.apiRoot + 'GiftCard/' + card.id + '/acceptgift').success(function(data) {
                deferred.resolve(data);
            });
            return deferred.promise;
        };

        return service;
    }])
    .value('version', '0.1');
