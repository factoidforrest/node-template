

/**
 * @ngdoc overview
 * @name mobileGiftCardWebApp
 * @description
 * # mobileGiftCardWebApp
 *
 * Main module of the application.
 */
angular
  .module('mobileGiftCardWebApp', [
    'config',
    'btford.socket-io',
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap'
  ])
  .config(function ($routeProvider, $httpProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .when('/register', {
        templateUrl: 'views/register.html',
        controller: 'RegisterCtrl'
      })
      .when('/about', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl'
      })
      .when('/add-cards', {
            templateUrl: 'views/add-cards.html',
            controller: 'AddCardsCtrl'

        })
      .when('/cards', {
            templateUrl: 'views/cards.html',
            controller: 'CardsCtrl'
      })
      .when('/user-profile', {
            templateUrl: 'views/user-profile.html',
            controller: 'UserProfileCtrl'
        })
      .when('/tcc-cards', {
            templateUrl: 'views/tcc-cards.html',
            controller: 'TccCardListController'
        })
      .when('/tcc-cards/:cardId', {
            templateUrl: 'views/tcc-card-detail.html',
            controller: 'TccCardDetailCtrl'
        })
      .when('/echo', {
            templateUrl: 'views/echo.html',
            controller: 'EchoCtrl'
        })
      .when('/GiftCardGift/:giftCardGiftId', {
            templateUrl: 'views/gift-card-gift.html',
            controller: 'GiftCardGiftCtrl'
        })
      .when('/buy-card', {
            templateUrl: 'views/buy-card.html',
            controller: 'BuyCardCtrl'
        })
      .otherwise({
        redirectTo: '/'
      });
        $httpProvider.defaults.withCredentials = true;
    }).run(['$rootScope', '$location', function($rootScope, $location) {
        $rootScope.$on('NotLoggedIn', function() {
            $location.path("/#");
        });
    }]).
    factory('mySocket', function (socketFactory, ENV) {
        var myIoSocket = io.connect(ENV.apiRoot);

        mySocket = socketFactory({
            ioSocket: myIoSocket
        });

        return mySocket;

    });
