variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "domain_name" {}
 
provider "digitalocean" {
  token = "${var.do_token}"
}
resource "digitalocean_droplet" "minecraft" {
    image = "docker-18-04"
    name = "minecraft"
    region = "lon1"
    size = "2gb"
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
    inline = ["sudo apt-get -y install python"]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file(var.pvt_key)}"
    }
  }

  provisioner "local-exec" {
    command = "echo '${self.name} ansible_host=${self.ipv4_address} ansible_python_interpreter=/usr/bin/python3' > inventory"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} --extra-vars \"world_repo=$WORLD_REPO\" provision.yml" 
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
  name = "only-22-25565"

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