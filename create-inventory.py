#!/usr/bin/env python3
import json
import subprocess
import yaml


def fetch_terraform_outputs():
    """Fetch the latest Terraform outputs using the `terraform output -json` command."""
    try:
        # Run `terraform output -json` and capture its output
        result = subprocess.run(
            ["terraform", "output", "-json"], check=True, capture_output=True, text=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error executing terraform command: {e}")
        exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing Terraform JSON output: {e}")
        exit(1)


def generate_inventory(terraform_data):
    """Generate an Ansible dynamic inventory from Terraform outputs."""
    ssh_key_path = "~/.ssh/zp2key"
    inventory = {
        "all": {"hosts": {}},
        "nat": {"hosts": {}},
        "database": {"hosts": {}},
        "docker": {"hosts": {}},
    }

    # NAT host configuration (Amazon Linux 2)
    nat_config = {
        "ansible_host": terraform_data["nat_host_public_ip"]["value"],
        "ansible_user": "ec2-user",
        "ansible_connection": "ssh",
        "ansible_ssh_private_key_file": ssh_key_path,
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
    }
    inventory["all"]["hosts"]["nat_host"] = nat_config
    inventory["nat"]["hosts"]["nat_host"] = nat_config

    # Database host configuration (Ubuntu, via NAT as jump host)
    database_config = {
        "ansible_host": terraform_data["database_private_ip"]["value"],
        "ansible_user": "ubuntu",
        "ansible_connection": "ssh",
        "ansible_ssh_private_key_file": ssh_key_path,
        "ansible_ssh_common_args": (
            "-o ProxyCommand='ssh -W %h:%p -q -o StrictHostKeyChecking=no -i {ssh_key} ec2-user@{nat_host}'".format(
                ssh_key=ssh_key_path,
                nat_host=terraform_data["nat_host_public_ip"]["value"],
            )
        ),
    }
    inventory["all"]["hosts"]["database_host"] = database_config
    inventory["database"]["hosts"]["database_host"] = database_config

    # Docker host configuration (Ubuntu, direct connection)
    docker_config = {
        "ansible_host": terraform_data["docker_host_public_ip"]["value"],
        "ansible_user": "ubuntu",
        "ansible_connection": "ssh",
        "ansible_ssh_private_key_file": ssh_key_path,
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
    }
    inventory["all"]["hosts"]["docker_host"] = docker_config
    inventory["docker"]["hosts"]["docker_host"] = docker_config

    return inventory


def write_inventory_to_yaml(inventory, output_file="inventory.yml"):
    """Write the inventory to a YAML file."""
    try:
        with open(output_file, "w") as f:
            yaml.dump(inventory, f, default_flow_style=False)
        print(f"Inventory written to {output_file}")
    except Exception as e:
        print(f"Error writing inventory to YAML: {e}")
        exit(1)


def main():
    # Fetch the latest Terraform outputs
    terraform_data = fetch_terraform_outputs()
    # Generate the Ansible inventory
    inventory = generate_inventory(terraform_data)
    # Write the inventory to a file
    write_inventory_to_yaml(inventory)


if __name__ == "__main__":
    main()
