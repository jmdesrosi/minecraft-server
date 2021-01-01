const Gamedig = require('gamedig');
const { spawn } = require('child_process');
const SingleInstance = require('single-instance');

const process_lock  = new SingleInstance('minecraft-monitoring');
const config = require('./minecraft.tfvars.json');

const check_interval = config.check_interval * 1000; //Convert from sec to ms
const shutdown_timeout = config.shutdown_timeout * 1000; //Convert from sec to ms
const terraform = config.terraform || 'terraform';

function shutdownServer() {
	console.log("\nShutting down server.");

	const ls = spawn(terraform, ['destroy', '-auto-approve', '-var-file=./minecraft.tfvars.json']);

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
		console.log("There are " + state.players.length + " players online.");
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
				console.log("Server has users, cancelling countdown");
				clearTimeout(timeoutObject);
				timeoutObject = null;
			}
		}
	}).catch((error) => {
		console.log("Server " + config.domain_name + " is offline");
	});	
}

var timeoutObject = null;
process_lock.lock().then(() => {
	console.log("\nStarting to monitor server " + config.domain_name);
    setInterval(function () {
		checkServerPopulation();
	}, check_interval); 
}).catch(err => {
	console.log(err); // it will print out 'An application is already running'
	process.exit();
});


