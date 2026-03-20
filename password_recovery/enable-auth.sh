#!/bin/bash

CONFIG="/var/jenkins_home/config.xml"

echo "[+] Enabling Jenkins authentication..."

# Backup config
cp $CONFIG ${CONFIG}.bak

# Enable security
sed -i 's/<useSecurity>false<\/useSecurity>/<useSecurity>true<\/useSecurity>/g' $CONFIG

# Replace authorization strategy
sed -i 's#<authorizationStrategy class="hudson.security.AuthorizationStrategy\$Unsecured"/>#<authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">\n  <denyAnonymousReadAccess>true</denyAnonymousReadAccess>\n</authorizationStrategy>#' $CONFIG

# Ensure security realm exists
if ! grep -q "HudsonPrivateSecurityRealm" $CONFIG; then
  sed -i '/<useSecurity>true<\/useSecurity>/a \
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">\n\
    <disableSignup>false</disableSignup>\n\
  </securityRealm>' $CONFIG
fi

echo "[+] Authentication enabled."
echo "[+] Restart Jenkins container now:"
echo "    docker restart jenkins"