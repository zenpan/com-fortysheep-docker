#!/bin/bash
cat << 'USERDATA' > /var/lib/cloud/scripts/per-instance/user-data.sh
#!/bin/bash
dnf update -y

# Install packages, using --allowerasing for curl
dnf install --allowerasing -y curl
dnf install -y htop net-tools iptables-services sysstat nethogs tmux

# Enable and start iptables
systemctl enable --now iptables

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

# Save iptables rules
mkdir -p /etc/sysconfig/iptables
iptables-save > /etc/sysconfig/iptables/iptables.rules

# Ensure iptables rules are restored on boot
cat > /etc/systemd/system/iptables-restore.service << 'IPTABLES'
[Unit]
Description=Restore iptables rules
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/sysconfig/iptables/iptables.rules
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
IPTABLES

systemctl enable iptables-restore.service

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
dnf install -y amazon-cloudwatch-agent

# Install EC2 Instance Connect
dnf install -y ec2-instance-connect
USERDATA

chmod +x /var/lib/cloud/scripts/per-instance/user-data.sh
/var/lib/cloud/scripts/per-instance/user-data.sh

# Create .bash_aliases for ec2-user
cat << 'EOF' >> /home/ec2-user/.bash_aliases
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
chown ec2-user:ec2-user /home/ec2-user/.bash_aliases