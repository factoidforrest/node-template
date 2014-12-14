
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
  .controller('MainCtrl',["$location", "$scope", "$rootScope", "UserService", "ENV", function ($location, $scope, $rootScope, userService, ENV) {
        'use strict';
        console.log('the hash is ', $location.hash())
        $scope.error = window.location.hash.error;
        $scope.apiRoot = ENV.apiRoot;

  }]);
