# Minecraft server
This repository contains scripts that automates the deployment of a Minecraft server running in a Docker container in a VM on [Digital Ocean](https://cloud.digitalocean.com).  
    
The intent is for the server to be ephemeral, meaning that if the server is inactive (meaning 0 players logged on), the server will be automatically destroyed. This is done to reduce the cloud costs. Now don't worry! The world data is saved to a git repository before destroying the server.

The solution relies on a few technologies:
  
  * [Digital Ocean](https://cloud.digitalocean.com)
  * [Terraform](https://www.terraform.io/)
To persist the world between runs, the solution relies on the world data being stored in a git repository.
It sets up all of the required infrastructure (VM, Firewall, DNS record) and then uploads setup scripts to the VM.




## Upload Cert to DigitalOcean
## Register DNS domain
## Setup DNS NS 
## Create localrc.sh
## Run Setup

  curl -fsSL https://clis.ng.bluemix.net/install/osx | sh  
  npm install

    dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

{
    "do_token": "47adb1b22431726ce33513590095cb4087283525df2fad87127aed7645525db2",
    "pub_key": "/Users/ldesrosi/.ssh/id_rsa.pub",
    "pvt_key": "/Users/ldesrosi/.ssh/id_rsa",
    "git_pvt_key": "/Users/ldesrosi/.ssh/minecraft",
    "domain_name": "slothcraft.co.uk",
    "world_repo": "git@github.com:ldesrosi/kijilas-server.git",
    "rcon_passwd": "BestGame4U",
    "ssh_fingerprint": "4c:ad:ef:e0:14:d1:a5:01:6c:32:4e:9c:2a:96:3c:c5"
    "check_interval" : 6000,
    "shutdown_timeout" : 6000
}