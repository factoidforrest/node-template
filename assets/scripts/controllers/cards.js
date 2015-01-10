
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the mobileGiftCardWebApp
 */

var app = angular.module('mobileGiftCardWebApp');


app.controller('CardsCtrl', ['$scope', '$modal', 'GiftCardService', function ($scope, $modal, giftCardService) {

    'use strict';


    var reloadData = function() {
        giftCardService.getList().then(function(data) {
            $scope.pluralized_cards = data.length > 1 || data.length < 1 ? "cards" : "card";
            $scope.giftCards = data;
        });
        giftCardService.getAcceptList().then(function(data) {
            $scope.pluralized_cards_to_accept = data.length > 1 || data.length < 1 ? "cards" : "card";
            $scope.AcceptGiftCards = data;
        });
    };

    $scope.didTapImportCard = function() {
        var modalInstance = $modal.open({
            templateUrl: 'add-card.html',
            controller: CardsModalCtrl,
            size: 'sm'
        });

        modalInstance.result.then(function (newCard) {
            var giftCard = {
                card_number : newCard.card_number
            };

            giftCardService.add(giftCard).then(function() {
                reloadData();
            });

        }, function () {
        });
    };


  $scope.didTapGiftThisCard = function(card) {
        var modalInstance = $modal.open({
            templateUrl: 'gift-this-card.html',
            controller: CardGiftCtrl,
            size: 'sm'
        });

        modalInstance.result.then(function (gift) {

            giftCardService.gift(card, gift).then(function() {
                reloadData();
            });

        }, function () {
        });
    };

    $scope.didTapUnGiftThisCard = function(card) {
        giftCardService.ungift(card).then(function() {
            reloadData();
        });

    };

    $scope.didTapAcceptThisCard = function(card) {

        giftCardService.acceptgift(card).then(function() {
            reloadData();
        });

    };

    $scope.didTapRejectGiftCard = function(card) {
        giftCardService.rejectgift(card).then(function() {
            reloadData();
        });

    };


    reloadData();

}]);

var CardsModalCtrl = function ($scope, $modalInstance) {

    $scope.giftCard = {};

    $scope.ok = function () {
        $modalInstance.close($scope.giftCard);
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
};

var CardGiftCtrl = function ($scope, $modalInstance) {

    $scope.gift = {};

    $scope.ok = function () {
        $modalInstance.close($scope.gift);
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
};

