variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "git_pvt_key" {}
variable "world_repo" {}
variable "rcon_passwd" {}
variable "ssh_fingerprint" {}
variable "domain_name" {}
variable "check_interval" {}
variable "shutdown_timeout" {}
variable "terraform" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
resource "digitalocean_droplet" "minecraft" {
    image = "docker-18-04"
    name = "minecraft"
    region = "lon1"
    size = "s-4vcpu-8gb"
    private_networking = false
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
    inline = [
       "mkdir -p /src/minecraft/script",
       "apt install -y ansible"
    ]
  }
  provisioner "file" {
    source      = "server_script/"
    destination = "/src/minecraft/script"
  }
  provisioner "file" {
    source      = "${var.git_pvt_key}"
    destination = "/src/minecraft/script/minecraft.key"
  } 
  provisioner "remote-exec" {
    inline = [
       "cd /src/minecraft/script/ && ansible-playbook -u root -i '127.0.0.1,' --connection=local --extra-vars \"world_repo=${var.world_repo} rcon_passwd=${var.rcon_passwd}\" minecraft-start.yml" 
    ]
  }
  provisioner "remote-exec" {
    connection {
        user = "steve"
        type = "ssh"
        private_key = "${file(var.pvt_key)}"
        timeout = "2m"
    }
    inline = [
      "cd /src/minecraft/script/ && ansible-playbook -u steve -i '127.0.0.1,' --connection=local minecraft-stop.yml" 
    ]
    when = "destroy"
  }
}

# Create a new domain record
resource "digitalocean_domain" "default" {
   name = "${var.domain_name}"
   ip_address = "${digitalocean_droplet.minecraft.ipv4_address}"
}

resource "digitalocean_record" "CNAME-server" {
  domain = "${digitalocean_domain.default.name}"
  type = "CNAME"
  name = "server"
  value = "@"
}
resource "digitalocean_firewall" "minecraft" {
  name = "port-22-25565-25575"

  droplet_ids = ["${digitalocean_droplet.minecraft.id}"]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "25565"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "udp"
      port_range         = "25565"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "25575"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "udp"
      port_range         = "25575"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "udp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "icmp"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]
}
output "public_ip" {
  value = "${digitalocean_droplet.minecraft.ipv4_address}"
}