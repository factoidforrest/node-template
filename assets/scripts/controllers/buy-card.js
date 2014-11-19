

/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:AddCardsCtrl
 * @description
 * # AddCardsCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
    .controller('BuyCardCtrl', ['$scope', '$location', 'GiftCardService', function ($scope, $location, giftCardService) {
    'use strict';

    $scope.card = {};

    $scope.buy = function() {
      giftCardService.buy($scope.card).then(function(card) {
        $location.path("/cards");
      });
    }


  }]);
