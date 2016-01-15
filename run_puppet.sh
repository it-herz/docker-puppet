#!/bin/bash
echo "Run puppet server"
FQDN=`facter -p fqdn`
echo "Changing hosts..."
cp /etc/hosts /etc/hosts2
sed -i "s/\(.*\)$FQDN.*/\1$FQDN/g" /etc/hosts2
cp /etc/hosts2 /etc/hosts
rm /etc/hosts2
sed  -i "s/FQDN/$FQDN/g" /etc/puppetlabs/puppet/puppet.conf
cd /opt/puppetlabs/server/bin/
./puppetserver foreground
