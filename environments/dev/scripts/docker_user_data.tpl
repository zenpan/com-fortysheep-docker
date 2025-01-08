#!/bin/bash
apt-get update -y
# install tools needed by Ansible controller
apt-get install -y python3 python3-pip

cat << 'EOF' >> /home/ubuntu/.bash_aliases
# EC2 Instance Metadata Service v2 helper functions
get-imds-token() {
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null)
    echo "export TOKEN='${TOKEN}'"
    export TOKEN="${TOKEN}"
}

get-metadata() {
    if [ -z "${TOKEN}" ]; then
        echo "No token found. Run get-imds-token first."
        return 1
    fi
    curl -H "X-aws-ec2-metadata-token: ${TOKEN}" "http://169.254.169.254/latest/meta-data/$1" 2>/dev/null
}

get-all-metadata() {
    if [ -z "${TOKEN}" ]; then
        echo "No token found. Run get-imds-token first."
        return 1
    fi
    curl -H "X-aws-ec2-metadata-token: ${TOKEN}" "http://169.254.169.254/latest/meta-data/" 2>/dev/null
}
EOF

# Set correct ownership
chown ubuntu:ubuntu /home/ubuntu/.bash_aliases