
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
    $scope.formData = {};

    $scope.login = function () {
    	console.log('submit called with formdata')
    	console.log($scope.formData)
    	$http({
	        method  : 'POST',
	        url     : 'auth/local',
	        data    : $.param($scope.formData),  // pass in data as strings
	        headers : { 'Content-Type': 'application/x-www-form-urlencoded' }  // set the headers so angular passes info as form data (not request payload)
	    })
      .success(function(data) {
        console.log('server responded with data: ', data);

        if (!data.success) {
        	// if not successful, bind errors to error variables

            $scope.error = data.error
        } else {
        	// if successful, bind success message to message
        	console.log('auth success')
        	//should be using angular hash ($location.hash(cards)) for this but it's acting funny
          window.location.hash = "#/cards"
        }
      }).error(function(data){
      	console.log("server error: ", data);
      	$scope.error = 'Error contacting server.  Please check your connection.';
      });
    }
  }]);
