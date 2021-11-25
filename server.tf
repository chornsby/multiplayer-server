// Fetch the possible availability domains for the compartment
data "oci_identity_availability_domains" "default" {
  compartment_id = var.tenancy_ocid
}

// Create a virtual network for deploying servers
resource "oci_core_vcn" "vcn" {
  compartment_id = var.tenancy_ocid

  cidr_blocks  = ["10.0.0.0/16"]
  display_name = "server-vcn"
  dns_label    = "server"
}

// Define a gateway from which the network can reach the internet
resource "oci_core_internet_gateway" "internet" {
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "internet-gateway"
  enabled      = true
}

// Allow traffic to be routed out to the internet
resource "oci_core_route_table" "internet" {
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "internet-route"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet.id
  }
}

// Allow all outbound traffic and inbound traffic on the game server port
// but restrict SSH access to only this machine where Terraform is running
resource "oci_core_security_list" "rules" {
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "server-security-list"
  egress_security_rules {
    description = "All traffic"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    description = "Node access"
    source      = "${chomp(data.http.icanhazip.body)}/32"
    protocol    = "6"
    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    description = "Server TCP"
    source      = "0.0.0.0/0"
    protocol    = "6"
    tcp_options {
      max = var.open_port_max
      min = var.open_port_min
    }
  }
  ingress_security_rules {
    description = "Server UDP"
    source      = "0.0.0.0/0"
    protocol    = "17"
    udp_options {
      max = var.open_port_max
      min = var.open_port_min
    }
  }
}

// Create a subnet using the above routing and security rules
resource "oci_core_subnet" "public" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name      = "public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.internet.id
  security_list_ids = [oci_core_security_list.rules.id]
}

// Deploy a single hefty Ubuntu LTS server and set up the software
// dependencies and a run script to get started quickly
resource "oci_core_instance" "server" {
  availability_domain = data.oci_identity_availability_domains.default.availability_domains[0].name
  compartment_id      = oci_core_vcn.vcn.compartment_id
  shape               = "VM.Standard.A1.Flex"

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.public.id
  }
  display_name = "game-server"
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  shape_config {
    memory_in_gbs = 24
    ocpus         = 4
  }
  // https://docs.oracle.com/en-us/iaas/images/image/0fef99ff-3e6a-4f32-b504-28143e310475/
  source_details {
    source_id   = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaarszpq7ymdbzc7qoultyf4wliee4flk34mw4ux263skueksm7lfxa"
    source_type = "image"
  }

  // TODO: Continue improving using tricks from:
  //  https://teilgedanken.de/Blog/post/setting-up-a-minecraft-server-using-systemd/
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade --assume-yes",
    ]

    connection {
      host = self.public_ip
      type = "ssh"
      user = "ubuntu"
    }
  }
}

output "instance-ip" {
  value = oci_core_instance.server.public_ip
}
