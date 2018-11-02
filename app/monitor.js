const Gamedig = require('gamedig');

var emptyStartTime = Date.now()
var timeoutObject = null;

setInterval(function () {
	checkServerPopulation();
}, 1 * 10 * 1000); // Check every 1 min

function shutdownServer() {
	console.log("Shutting down server.");
}

function checkServerPopulation() {
    Gamedig.query({
		type: 'minecraftping',
		host: 'slothcraft.co.uk'
	}).then((state) => {
		console.log("Number of players: " + state.players.length);

		if (state.players.length == 0) {
			if (timeoutObject == null) {
				console.log("Server is empty, starting countdown");
				timeoutObject = setTimeout(function() {
					console.log("Shutting down server.");
				}, 10 * 60 * 1000);
			} else {
				console.log(".")
			}
		} else {
			if (timeoutObject != null) {
				console.log("Server has users, cancelling countdown");
				clearTimeout(timeoutObject);
				timeoutObject = null;
			}
		}
	}).catch((error) => {
		console.log("Server is offline");
		console.log(error);
		process.exit()
	});	
}



