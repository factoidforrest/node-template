
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:HeaderCtrl
 * @description
 * # HeaderCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
    .controller('HeaderCtrl',["$scope", "$route", "$http", "UserService", "ENV", function ($scope, $route, $http, userService, ENV) {

        $scope.apiRoot = ENV.apiRoot;

        userService.getProfile().then(function(profile) {
            $scope.profile = profile;
        });

        $scope.logout = function () {
		    	console.log('submit called with formdata')
		    	console.log($scope.formData)
		    	$http({
			        method  : 'POST',
			        url     : 'auth/logout'
			    })
		      .success(function(data) {
		        console.log('server responded with data: ', data);

		        if (!data.success) {
		        	// if not successful, bind errors to error variables
		        		console.log('got response with error, server responded with: ', data)
		            $scope.error = data.error
		        } else {
		        	// if successful, bind success message to message
		        	console.log('logout success, server responded: ', data)
		        	userService.profile = {};
		        	$scope.profile = {};
		          window.location.hash = "#/"
		        }
		      }).error(function(data){
		      	console.log("ajax error: ", data);
		      	$scope.error = 'Error contacting server.  Please check your connection.';
		      });
		    }



    }]);
