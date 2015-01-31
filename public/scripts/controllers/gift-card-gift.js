
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the mobileGiftCardWebApp
 */

var app = angular.module('mobileGiftCardWebApp');


app.controller('GiftCardGiftCtrl', ['$scope', '$modal', '$routeParams', 'GiftCardGiftService', function ($scope, $modal, $routeParams, giftCardGiftService) {

    'use strict';


    var reloadData = function() {
      giftCardGiftService.getGift($routeParams.giftCardGiftId).then(function(giftCardGift) {
        $scope.gift = giftCardGift;
      });
    };

    $scope.didTapAccept = function() {
      console.log("Accept");
    };


    $scope.didTapReject = function() {
      console.log("Reject");
    };


    reloadData();

}]);
