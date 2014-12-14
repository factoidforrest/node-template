
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
  .controller('MainCtrl',["$location", "$http", "$scope", "$rootScope", "UserService", "ENV", function ($location, $http, $scope, $rootScope, userService, ENV) {
        'use strict';
        $scope.apiRoot = ENV.apiRoot;

  }]);
