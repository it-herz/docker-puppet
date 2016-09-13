#!/bin/bash
echo "Run puppet server"
chown puppet -R /etc/puppetlabs/puppet/ && chmod 777 -R /etc/puppetlabs/puppet/ssl/
FQDN=`facter -p fqdn`
echo "Changing hosts..."
cp /etc/hosts /etc/hosts2

echo $FQDN >/root/masters.txt

echo "development: $FQDN:4570" >/root/reaktor/config/resque.yml
echo "test: $FQDN:4570" >>/root/reaktor/config/resque.yml
echo "production: $FQDN:4570" >>/root/reaktor/config/resque.yml

sed -i "s/\(.*\)$FQDN.*/\1$FQDN/g" /etc/hosts2
cp /etc/hosts2 /etc/hosts
rm /etc/hosts2
sed  -i "s/FQDN/$FQDN/g" /etc/puppetlabs/puppet/puppet.conf
cd /opt/puppetlabs/server/bin/
./puppetserver foreground
