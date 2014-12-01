




angular.module('mobileGiftCardWebApp')
    .controller('RegisterCtrl',["$scope", "$http", "UserService", "ENV", function ($scope, $http, userService, ENV) {
  		$scope.formData = {};
      $scope.apiRoot = ENV.apiRoot;
      $scope.submit = function () {
      	console.log('submit called with formdata')
      	console.log($scope.formData)
      	$http({
		        method  : 'POST',
		        url     : 'auth/register',
		        data    : $.param($scope.formData),  // pass in data as strings
		        headers : { 'Content-Type': 'application/x-www-form-urlencoded' }  // set the headers so angular passing info as form data (not request payload)
		    })
        .success(function(data) {
          console.log('server responded with data: ', data);

          if (!data.success) {
          	// if not successful, bind errors to error variables
              $scope.errorUsername = data.errors.username;
              $scope.errorPassword = data.errors.password;
              $scope.errorConfirm = data.errors.passwordConfirmation;
              $scope.error = data.error
          } else {
          	// if successful, bind success message to message
            $scope.message = data.message;
          }
        }).error(function(data){
        	console.log("server error: ", data);
        	$scope.error = 'Server Error'
        });

		  };
      $scope.awesomeThings = [

	    ];
    }]);

