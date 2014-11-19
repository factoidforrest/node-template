

/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:AddCardsCtrl
 * @description
 * # AddCardsCtrl
 * Controller of the mobileGiftCardWebApp
 */
angular.module('mobileGiftCardWebApp')
    .controller('EchoCtrl',function ($scope, mySocket, TestCardService) {

        'use strict';
        $scope.previousExamples = [];

        $scope.didClickSendMessage = function() {
            TestCardService.echoMessage($scope.message).then(function(){
                $scope.previousExamples.push("created " + JSON.stringify($scope.message));
            });
        };

        mySocket.on('connect', function() {

            mySocket.on('response', function(payload) {
                $scope.previousExamples.push("received " + JSON.stringify(payload));
            });

        });




    });
