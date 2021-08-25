// Fetch the possible availability domains for the compartment
data "oci_identity_availability_domains" "default" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_vcn" "vcn" {
  compartment_id = var.tenancy_ocid

  cidr_blocks  = ["10.0.0.0/16"]
  display_name = "minecraft-vcn"
  dns_label    = "minecraft"
}

resource "oci_core_internet_gateway" "internet" {
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "internet-gateway"
  enabled      = true
}

resource "oci_core_route_table" "internet" {
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "internet-route"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet.id
  }
}

resource "oci_core_security_list" "rules" {
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "minecraft-security-list"
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
    description = "Minecraft TCP"
    source      = "0.0.0.0/0"
    protocol    = "6"
    tcp_options {
      max = 25565
      min = 25565
    }
  }
  ingress_security_rules {
    description = "Minecraft UDP"
    source      = "0.0.0.0/0"
    protocol    = "17"
    udp_options {
      max = 25565
      min = 25565
    }
  }
}

resource "oci_core_subnet" "public" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_core_vcn.vcn.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name      = "public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.internet.id
  security_list_ids = [oci_core_security_list.rules.id]
}

resource "oci_core_instance" "server" {
  availability_domain = data.oci_identity_availability_domains.default.availability_domains[0].name
  compartment_id      = oci_core_vcn.vcn.compartment_id
  shape               = "VM.Standard.A1.Flex"

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.public.id
  }
  display_name = "minecraft-server"
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
  shape_config {
    memory_in_gbs = 16
    ocpus         = 4
  }
  // https://docs.oracle.com/en-us/iaas/images/image/06a7e282-aff6-45f3-865f-d0bac2435b13/
  source_details {
    source_id   = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaap5yq7hwr66cezuo5drpseaqe65mbcyswmht25j5n4ocghr7jvtma"
    source_type = "image"
  }

  // TODO: Continue improving using tricks from:
  //  https://teilgedanken.de/Blog/post/setting-up-a-minecraft-server-using-systemd/
  provisioner "remote-exec" {
    inline = [
      "sudo yum update --assumeyes",
      "sudo yum install jdk-16.0.2 --assumeyes",
      "sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp",
      "sudo firewall-cmd --permanent --zone=public --add-port=25565/udp",
      "sudo firewall-cmd --reload",
      "wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar",
      "echo 'eula=true' > eula.txt",
      "echo 'java -Xms1G -Xmx4G -jar server.jar nogui' > run.sh",
      "chmod +x run.sh",
    ]

    connection {
      host = self.public_ip
      type = "ssh"
      user = "opc"
    }
  }
}

output "instance-ip" {
  value = oci_core_instance.server.public_ip
}
