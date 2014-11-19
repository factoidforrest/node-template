
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the mobileGiftCardWebApp
 */

angular.module('mobileGiftCardWebApp')
    .controller('TccCardDetailCtrl', ['$scope', '$modal', '$routeParams', 'TestCardService', function ($scope, $modal, $routeParams, testCardService) {

    'use strict';


    var reloadData = function() {
        testCardService.getCard($routeParams.cardId).then(function(data) {
            $scope.card = data;
        });
    };

    $scope.didClickActivate = function() {
        testCardService.activateCard($scope.card.id, $scope.activationAmount).then(function(){
            reloadData();
        });
    };

    $scope.didClickRedeem = function() {
        testCardService.redeemCard($scope.card.id, $scope.redemptionAmount).then(function(){
            reloadData();
        });
    };

    reloadData();

}]);

