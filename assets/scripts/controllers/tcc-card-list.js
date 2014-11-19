
/**
 * @ngdoc function
 * @name mobileGiftCardWebApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the mobileGiftCardWebApp
 */

var app = angular.module('mobileGiftCardWebApp');


app.controller('TccCardListController', ['$scope', '$modal', 'TestCardService', function ($scope, $modal, testCardService) {

    'use strict';

    $scope.pager = {
        pageSize : 10,
        previous : false,
        next : false,
        current : 0,
        totalPages : function() {
            return $scope.allCards.length / this.pageSize;
        },
        setPage : function(pageNumber) {
            if (pageNumber <= this.totalPages()) {
                this.current = pageNumber;
                this.previous = (pageNumber > 1);
                this.next = (pageNumber < this.totalPages() - 1);
                $scope.currentCards = $scope.allCards.slice(this.current * this.pageSize, (this.current * this.pageSize) + this.pageSize);
            }
        },
        goNext : function() {
            if (this.current < this.totalPages()) {
                this.setPage(this.current + 1);
            }
        },
        goPrevious : function() {
            if (this.current > 1) {
                this.setPage(this.current - 1);
            }
        }
    };


    var reloadData = function() {
        testCardService.getList().then(function(data) {
            $scope.allCards = data;
            $scope.pager.setPage(1);
        });
    };

    $scope.didClickNext = function() {
        $scope.pager.goNext();
    };

    $scope.didClickPrevious = function() {
        $scope.pager.goPrevious();
    };


    reloadData();

}]);

