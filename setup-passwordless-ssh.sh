## A bash script to ssh into multiple sessions by securely entering the password once 

#!/bin/bash

read -s -p "Enter SSH password for app servers: " SSHPASS
echo

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
fi

PUBKEY=$(cat ~/.ssh/id_rsa.pub)

declare -A HOSTS
HOSTS=(
  [stapp01]=tony
  [stapp02]=steve
  [stapp03]=banner
)

for HOST in "${!HOSTS[@]}"; do
  USER=${HOSTS[$HOST]}
  echo "Setting up SSH for $USER@$HOST"

  sshpass -p "$SSHPASS" ssh -o StrictHostKeyChecking=no $USER@$HOST "
    mkdir -p ~/.ssh &&
    chmod 700 ~/.ssh &&
    echo '$PUBKEY' >> ~/.ssh/authorized_keys &&
    chmod 600 ~/.ssh/authorized_keys
  "
done

echo "Password-less SSH setup completed."
