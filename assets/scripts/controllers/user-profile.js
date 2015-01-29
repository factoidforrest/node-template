
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:userProfileCtrl
 * @description
 * # userProfileCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
    .controller('UserProfileCtrl',['$scope', 'UserService', 'ENV', function ($scope, userService, ENV) {

        $scope.apiRoot = ENV.apiRoot;

        userService.getProfile().then(function(profile) {
            $scope.profile = profile;
            console.log('the user profile is', profile)
        });

        $scope.updateProfile = function() {
            console.log('the user profile is2', $scope.profile);
            UserService.updateUserProfile($scope.profile);
        };

    }]);
