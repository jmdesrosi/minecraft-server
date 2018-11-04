const Gamedig = require('gamedig');
const express = require('express');
const { spawn } = require('child_process');
const config = require('./minecraft.tfvars.json');
const app = express();
const port = 3000;

const check_interval = config.check_interval * 1000; //Convert from sec to ms
const shutdown_timeout = config.shutdown_timeout * 1000; //Convert from sec to ms

function shutdownServer() {
	console.log("\nShutting down server.");

	const ls = spawn('terraform', ['destroy', '-auto-approve', '-var-file=./minecraft.tfvars.json']);

	ls.stdout.on('data', (data) => {
	  console.log(`stdout: ${data}`);
	});
	
	ls.stderr.on('data', (data) => {
	  console.log(`stderr: ${data}`);
	});
	
	ls.on('close', (code) => {
	  console.log(`child process exited with code ${code}`);
	  process.exit();
	});
}

function checkServerPopulation() {
    Gamedig.query({
		type: 'minecraftping',
		host: config.domain_name
	}).then((state) => {
		if (state.players.length == 0) {
			if (timeoutObject == null) {
				console.log("Server is empty, starting countdown");
				timeoutObject = setTimeout(function() {
					shutdownServer();
				}, shutdown_timeout);
			} else {
				process.stdout.write(".");
			}
		} else {
			if (timeoutObject != null) {
				console.log("\nServer has users, cancelling countdown");
				clearTimeout(timeoutObject);
				timeoutObject = null;
			}
		}
	}).catch((error) => {
		console.log("Server " + config.domain_name + " is offline");
	});	
}

var timeoutObject = null;

setInterval(function () {
	checkServerPopulation();
}, check_interval); 

app.get('/', (req, res) => res.send('Minecraft monitoring!'));
app.listen(port, () => console.log(`Minecraft monitoring app listening on port ${port}!`));



