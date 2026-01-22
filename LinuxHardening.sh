#!/bin/bash

# Linux Hardening Bootstrapper
# Targeted for Ubuntu/Debian

echo "Starting system hardening..."

# 1. Update System
apt-get update && apt-get upgrade -y

# 2. Install Essential Security Tools
apt-get install -y ufw fail2ban unattended-upgrades libpam-pwquality auditd

# 3. Configure Firewall (UFW)
# Allow SSH but limit it, then enable firewall
ufw limit ssh
ufw allow http
ufw allow https
ufw --force enable

# 4. Secure SSH Configuration
# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Disallow root login and password-based auth
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

# 5. Enable Automatic Security Updates
dpkg-reconfigure -plow unattended-upgrades

# 6. Restrict Access to /etc/shadow
chmod 600 /etc/shadow

# 7. Network Hardening (sysctl)
cat <<EOF >> /etc/sysctl.conf
# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
# Enable TCP SYN Cookie Protection
net.ipv4.tcp_syncookies = 1
EOF
sysctl -p

echo "Hardening script complete. Please reboot for all changes to take effect."
