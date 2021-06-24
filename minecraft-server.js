const fs = require('fs');
const yaml = require('js-yaml');
const Gamedig = require('gamedig');
const { spawn } = require('child_process');
const SingleInstance = require('single-instance');

const process_lock  = new SingleInstance('minecraft-monitoring');

let monitorConfig;
let baseConfig;
try {
	let monitorYaml = fs.readFileSync('./vars/minecraft-monitor.yml', 'utf8');
	let baseYaml = fs.readFileSync('./vars/minecraft.yml', 'utf8');
	monitorConfig = yaml.loadAll(monitorYaml)[0].input;
	baseConfig = yaml.loadAll(baseYaml)[0].input;
} catch (e) {
    console.log(e);
}

const check_interval = monitorConfig.check_interval * 1000; //Convert from sec to ms
const shutdown_timeout = monitorConfig.shutdown_timeout * 1000; //Convert from sec to ms

function shutdownServer() {
	console.log("\nShutting down server.");

	const ls = spawn('/usr/local/bin/ansible-playbook', ["playbook.yml", "--extra-vars='{ \"destroy\":true }'"], { cwd: process.cwd()+'/ansible' });

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
		host: baseConfig.domain_name
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
		console.log(error);
		console.log("Server " + baseConfig.domain_name + " is offline");
	});	
}

var timeoutObject = null;
process_lock.lock().then(() => {
	console.log("\nStarting to monitor server " + baseConfig.domain_name);
    setInterval(function () {
		checkServerPopulation();
	}, check_interval); 
}).catch(err => {
	console.log(err); 
	process.exit();
});
