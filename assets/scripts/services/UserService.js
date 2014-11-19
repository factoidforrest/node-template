


var app = angular.module('mobileGiftCardWebApp');

app.factory('UserService', ['$http', '$q', 'ENV', function ($http, $q, ENV) {
    'use strict';
    var service = {};
    var me = undefined;

    service.getProfile = function () {
        var deferred = $q.defer();
        if (me === undefined) {
            $http.get(ENV.apiRoot + 'auth/profile/').success(function (data) {
                console.log(data);
                me = data;
                deferred.resolve(me);
            });
        } else {
            deferred.resolve(me);
        }
        return deferred.promise;
    };

    return service;

}]).value('version', '0.1');
