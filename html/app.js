(function() {
	
var app;
app = angular.module('AdiosNaco', ['ui.bootstrap']);

app.config(['$routeProvider', function ($routeProvider) {

    $routeProvider.when('/', {
        controller: 'gameController',
        templateUrl: '/app.html'
    })
    .otherwise({ redirectTo: '/' });

}]);


angular.module('AdiosNaco')
    .factory('gameRequestFactory', ['$http', function($http) {

    var urlBase = '/api/gameRequests';
    var dataFactory = {};

    dataFactory.getGameRequests = function () {
        return $http.get(urlBase);
    };

    dataFactory.getGameRequest = function (id) {
        return $http.get(urlBase + '/' + id);
    };

    dataFactory.insertGameRequest = function (playerName) {
        return $http.post(urlBase, playerName);
    };

    return dataFactory;
}]);


angular.module('AdiosNaco')
    .factory('gameFactory', ['$http', function($http) {

    var urlBase = '/api/games';
    var dataFactory = {};

    dataFactory.getGameRequests = function () {
        return $http.get(urlBase);
    };

    dataFactory.getGameRequest = function (id) {
        return $http.get(urlBase + '/' + id);
    };

    return dataFactory;
}]);


angular.module('AdiosNaco')
    .controller('gameController', ['$scope', 'dataFactory', 
        function ($scope, dataFactory) {
			
	$scope.status;
	$scope.gameRequests;
	$scope.game;
			
    getGameRequests();
	
	function getGameRequests() {
    	dataFactory.getGameRequests()
        	.success(function (gameRequests) {
            	$scope.gameRequests = gameRequests;
        	})
        	.error(function (error) {
            	$scope.status = 'Unable to load game requests: ' + error.message;
        	});
	} 
			
}).call(this);
