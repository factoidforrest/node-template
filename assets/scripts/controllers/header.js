
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:HeaderCtrl
 * @description
 * # HeaderCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
    .controller('HeaderCtrl',["$scope", "UserService", "ENV", function ($scope, userService, ENV) {

        $scope.apiRoot = ENV.apiRoot;

        userService.getProfile().then(function(profile) {
            console.log(profile);
            $scope.profile = profile;
        });

    }]);
