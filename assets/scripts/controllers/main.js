
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
  .controller('MainCtrl',["$scope", "$rootScope", "UserService", "ENV", function ($scope, $rootScope, userService, ENV) {
        'use strict';

        $scope.apiRoot = ENV.apiRoot;

  }]);
