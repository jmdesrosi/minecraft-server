# Minecraft server
Are you like me?  You like to play minecraft but don't feel like spending every single moment of your day playing it?  You would like your own server but it makes no sense to pay the full price for one server your might use only on Friday night and the week end?

I like to play Minecraft with my son and I like to geek-out so the solution to my problem was only natural...I did not like the idea of running a server locally with the problem of VPN or port forwarding setup and I was not about to pay full price for hosting. 

I decided that I was going to build an "automation stack" that would deploy a server, load the world and after a period of inactivity, it would automatically save the world and destroy the server.

If you look at Digital Ocean (Nice Cloud provider), you can get a server with 2 VCPU and 4GB of memory for only $0.03/hours.  This means that if you played 3 hours per day for 30 days it will cost you a whopping $2.70.  I can tell you, it's going to cost me a lot less.

Enough about the reason why I did this, if your still interested, read on... it gets a bit technical.

## The big idea
So as I mentioned, the concept is for the server to be ephemeral, meaning that if the server is inactive (meaning 0 players logged on), the server will be automatically destroyed. This is done to reduce the cloud costs. Now don't worry! The world data is saved to a git repository before destroying the server.

The server is deployed using a few technologies:  
  
  * [Digital Ocean](https://cloud.digitalocean.com)  
    Cloud hosting, to run the server.
  * Domain name  
    You could probably do away with the domain name but it's much easier to access your server using this instead of typing IP address.  
  * [Terraform](https://www.terraform.io/)  
    A really nice automation tool that can automate some hard tasks like remotely creating a Virtual Machine on a Cloud Provider, Setting up Firewalls, Configuring DNS.
  * [Ansible](https://www.ansible.com/)  
    This is called "Infrastructure-as-Code" essentially once Terraform as provisioned the VM, it invokes Ansible to perform the configuration of the server.
  * [Docker](http://docker.com/)  
    This is the component that will "contain" the Minecraft server.  It is based on a Docker container that can be found [here](https://hub.docker.com/r/itzg/minecraft-server/). Thanks itzg! :) 
  * [Node](https://nodejs.org/en/) & [NPM](https://docs.npmjs.com/cli/install)  
    Runs the application that will monitor the minecraft server for inactivity and automatically saves the world to github and then shuts it down.
  * [Git](http://github.com)  
    This is the solution we used to store our world.  It is normally used to store code but in this case we use it to store minecraft world data.
  
## Things you will need
While I listed all of the technologies that are in play, in reality you only need to worry about a fraction of those:
  
  * Digital Ocean account  
  * SSH Keys
  * Domain name registration  
  * Github account & git client  
  * Node and NPM
  
## Steps to get it going 

1. Copy "minecraft.tfvars.json.example" to "minecraft.tfvars.json"
1. Generate two pairs of SSH keys
   For each set of SSH keys, update the required fields of "minecraft.tfvars.json"
    * Personal id_rsa:  
      A set of key (private/public) for your workstation to be able to SSH to the server (May already exists)
    * Minecraft server id_rsa:
      A second set to allow the VM to upload world changes to github
1. Create a Digital Ocean API Key  
   Go to https://cloud.digitalocean.com/account/api/tokens to create the key and copy the generated string to your "minecraft.tfvars.json" file.
1. Upload personal id_rsa.pub (public key) to Digital Ocean
   This can be done from this link: https://cloud.digitalocean.com/account/security
1. Associate DNS domain name with name servers of Digital Ocean
   Follow these instructions: https://www.digitalocean.com/community/tutorials/how-to-point-to-digitalocean-nameservers-from-common-domain-registrars 
1. Update "minecraft.tfvars.json" with the domain name
1. Create a git repository for your world
   The repository can remain empty and the first time you start the server up, all of the required file and folder will be created.  Alternatively you can upload to you git repo an existing world.
1. Update "minecraft.tfvars.json" with the git repo using the SSH format
   If you need help with the SSH format look this link: https://help.github.com/articles/which-remote-url-should-i-use/
1. Upload the Minecraft server id_rsa.pub (public key) to your github repository deployment key
   Follow these instructions: https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys
1. Retrieve the SSH Fingerprint of your personal id_rsa.pub public key using:
   ssh-keygen -l -f <id_rsa.pub> -E md5
   **IMPORTANT:** Copy the fingerprint to the "minecraft.tfvars.json" file but do NOT include the "MD5:" of the resulting fingerprint
1. Set the terraform field to either "terraform" (on MacOS) or "./node_modules/terraform-npm/tools/terraform.exe" (Windows)
1. Run npm install

## Starting the server
Starting the server can be done by running this command:
`npm start`

This will start the server along with the monitoring process.  To be sure the server will get deleted in case of inactivity, it is recommended to let 10 minutes pass before logging on the server... at that point you should see that the server has been deleted and you can confirm it through the DigitalOcean Cloud dashboard.

## Stopping the server
Stopping the server can be done by running this command:
`npm stop`

## DNS not picking the new IP?
If you have an issue on Mac whereby the DNS is pointing to the wrong IP, you can try to run these commands:
    dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
Keep in mind that the TTL (Time To Live) of DNS entries is set to 1800 or 30 minutes.  This means that if you are frequently provisioning the server to test, it might take some time for the DNS to properly reflect the latest IP address.

