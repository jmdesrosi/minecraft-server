#!/usr/bin/env bash

source localrc.sh

export TF_LOG=INFO
export PATH=$PWD:$PATH
export SSH_FINGERPRINT=$(ssh-keygen -E md5 -lf $SSH_PUB | awk '{print $2}' | cut -c 5- )

function start() {
    pushd script

    terraform init

    terraform apply -auto-approve \
      -var "do_token=${DO_PAT}" \
      -var "pub_key=$SSH_PUB" \
      -var "pvt_key=$SSH_KEY" \
      -var "ssh_fingerprint=$SSH_FINGERPRINT" \
      -var "domain_name=$DOMAIN_NAME"

    dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

    popd

    startMonitor
}

function stop() {
    pushd script

    ansible-playbook -i inventory -u steve deprovision.yml

    terraform  destroy -auto-approve \
      -var "do_token=${DO_PAT}" \
      -var "pub_key=$SSH_PUB" \
      -var "pvt_key=$SSH_KEY" \
      -var "ssh_fingerprint=$SSH_FINGERPRINT" \
      -var "domain_name=$DOMAIN_NAME"

    popd
}

function setup() {
    generateLocalrc

    pushd app
    npm install
    popd
    
}

function startMonitor() {
    pushd app
    node monitor.js
    popd
}

function generateLocalrc() {
    if [ ! -f "localrc.sh" ]; then
        echo "export DO_PAT=<DIGITAL-OCEAN-ACCESS-TOKEN>" >> localrc.sh
        echo "export SSH_PUB=$HOME/.ssh/id_rsa.pub" >> localrc.sh
        echo "export SSH_KEY=$HOME/.ssh/id_rsa" >> localrc.sh
        echo "export DOMAIN_NAME=<DOMAIN-NAME>" >> localrc.sh
        echo "export REPO=<REPO>" >> localrc.sh
        echo "export WORLD_REPO=<WORLD-REPO>" >> localrc.sh

        chmod +x localrc.sh
    fi
}

case "$1" in
 stop)
   stop
   ;;
 start)
   start
   ;;
 setup)
   setup
   ;;
 *)
   echo "Usage: manageServer.sh {start|stop|setup}" >&2
   exit 3
   ;;
esac