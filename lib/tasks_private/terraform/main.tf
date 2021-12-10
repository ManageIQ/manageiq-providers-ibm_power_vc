terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
    }
  }
}

data "openstack_images_image_v2" "rhel" {
  name        = "${var.openstack_image}"
}

data "openstack_networking_network_v2" "network" {
  name           = "${var.openstack_network}"
}

data "openstack_compute_flavor_v2" "flavor" {
  name  = "${var.openstack_flavor}"
}


data "openstack_identity_project_v3" "project" {
  name = "${var.openstack_tenant_name}"
}

data "openstack_compute_instance_v2" "miq-test-vm" {
  id = "${openstack_compute_instance_v2.miq-testvm.id}"
}

resource "openstack_compute_instance_v2" "miq-testvm" {
  name = "miq-testvm"
  image_id  = data.openstack_images_image_v2.rhel.id
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  network {
    uuid = data.openstack_networking_network_v2.network.id
  }
}

