
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
  .controller('MainCtrl',["$location", "$http", "$scope", "$rootScope", "$route", "UserService", "ENV", function ( $location, $http, $scope, $rootScope, $route, userService, ENV) {
        'use strict';
    $scope.apiRoot = ENV.apiRoot;
    $scope.formData = {};
    console.log('the message is ,', $location.search().message)
    var messages = {
      pleaseconfirm: 'A confirmation email has been sent to your address.  Please click the link to continue.',
      confirmsuccess: 'You successfully confirmed your email.  You can now login.',
      confirmfail: 'Failed to confirm your email.  Maybe the link was incorrect or the token was expired or your email is already confirmed.'
      , deactivated: 'Your account has been deactivated by an administrator.'
    }

    var messageKey =  $location.search().message;
    if (messageKey) {
      $scope.message = messages[messageKey];
    }
    console.log('the scope message is ', $scope.message)

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
        	console.log('auth success, server responded: ', data)
        	//should be using angular hash ($location.hash(cards)) for this but it's acting funny
        	userService.profile = data.user;
        	$route.reload();
          window.location.hash = "#/cards"
      	
        
        }
      }).error(function(data){
      	console.log("server error: ", data);
      	$scope.error = 'Error contacting server.  Please check your connection.';
      });
    }
  }]);
