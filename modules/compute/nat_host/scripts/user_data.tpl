#!/bin/bash
cat << 'USERDATA' > /var/lib/cloud/scripts/per-instance/user-data.sh
#!/bin/bash
apt-get update -y
apt-get upgrade -y

# Install packages
apt-get install -y curl htop net-tools iptables-persistent sysstat nethogs tmux awscli

# Enable and start iptables (iptables-persistent handles this)
systemctl enable netfilter-persistent
systemctl start netfilter-persistent

# Configure IP forwarding
echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.d/99-nat.conf
sysctl -p /etc/sysctl.d/99-nat.conf

# Configure iptables for NAT
# Clear existing rules
iptables -F
iptables -t nat -F

# Set default policies
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Configure NAT rules
iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
iptables -A FORWARD -i ens5 -o ens5 -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Save iptables rules (Ubuntu uses iptables-persistent)
iptables-save > /etc/iptables/rules.v4

# Ensure iptables rules are restored on boot (handled by netfilter-persistent)
systemctl enable netfilter-persistent

# Configure sysctl parameters for NAT instance
cat >> /etc/sysctl.d/99-nat.conf << ENDCONF
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.netfilter.nf_conntrack_max = 262144
ENDCONF

# Load nf_conntrack module
modprobe nf_conntrack
echo "nf_conntrack" | tee -a /etc/modules-load.d/nf_conntrack.conf

# Apply sysctl changes
sysctl -p /etc/sysctl.d/99-nat.conf

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# Install EC2 Instance Connect
apt-get install -y ec2-instance-connect
USERDATA

chmod +x /var/lib/cloud/scripts/per-instance/user-data.sh
/var/lib/cloud/scripts/per-instance/user-data.sh

# Create .bash_aliases for ubuntu user
cat << 'EOF' >> /home/ubuntu/.bash_aliases
# EC2 Instance Metadata Service v2 helper functions
get-imds-token() {
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null)
    echo "export TOKEN='$${TOKEN}'"
    export TOKEN="$${TOKEN}"
}

get-metadata() {
    if [ -z "$${TOKEN}" ]; then
        echo "No token found. Run get-imds-token first."
        return 1
    fi
    curl -H "X-aws-ec2-metadata-token: $${TOKEN}" "http://169.254.169.254/latest/meta-data/$1" 2>/dev/null
}

get-all-metadata() {
    if [ -z "$${TOKEN}" ]; then
        echo "No token found. Run get-imds-token first."
        return 1
    fi
    curl -H "X-aws-ec2-metadata-token: $${TOKEN}" "http://169.254.169.254/latest/meta-data/" 2>/dev/null
}
EOF

# Set correct ownership
chown ubuntu:ubuntu /home/ubuntu/.bash_aliases
