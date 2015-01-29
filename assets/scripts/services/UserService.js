


var UserService = angular.module('mobileGiftCardWebApp');

UserService.factory('UserService', ['$http', '$q', 'ENV', function ($http, $q, ENV) {
    'use strict';
    var service = {};
    service.profile = undefined;
    service.getProfile = function () {
        console.log('getting profile')
        var deferred = $q.defer();
        if (service.profile === undefined) {
            console.log('calling getprofile')
            $http.get(ENV.apiRoot + 'auth/profile/').success(function (data) {
                console.log('user retrieved')
                console.log(data);
                if(!data.hasOwnProperty('full_name')){
                   data.full_name = data.email;
                }
                service.profile = data;
                deferred.resolve(data);
            });
        } else {
            deferred.resolve(service.profile);
        }
        return deferred.promise;
    };

    service.updateUserProfile = function(profile) {
        var deferred = $q.defer();
        $http.post(ENV.apiRoot + 'user/update').success(function(data) {
            deferred.resolve(data);
        }).fail(function(error) {
            deferred.reject(error);
        });
        return deferred.promise;
    };

    return service;

}]).value('version', '0.1');
