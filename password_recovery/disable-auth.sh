#!/bin/bash

CONFIG="/var/jenkins_home/config.xml"

echo "[+] Disabling Jenkins authentication..."

# Backup config
cp $CONFIG ${CONFIG}.bak

# Disable security
sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' $CONFIG

# Set unsecured authorization
sed -i 's#<authorizationStrategy.*#<authorizationStrategy class="hudson.security.AuthorizationStrategy$Unsecured"/>#g' $CONFIG

echo "[+] Authentication disabled."
echo "[+] Restart Jenkins container now:"
echo "    docker restart jenkins"