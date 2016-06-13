#!/bin/bash
FQDN=`facter -p fqdn`
export RESTART=0

mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp 
chmod 777 /var/run/postgresql/9.4-main.pg_stat_tmp
if [ ! -f /etc/puppetlabs/puppetdb/ssl/public.pem ]
then
  export RESTART=1

#apply extension

#create user and database (with utf8) support
  sudo -u postgres createuser -DSR puppetdb -w
  sudo -u postgres createdb -E UTF8 --template=template0 -O puppetdb puppetdb

  sudo -u postgres psql --dbname=puppetdb -c "CREATE EXTENSION pg_trgm;"

#extract container FQDN and bind puppetdb
  sed -i "s/FQDN/$FQDN/g" /etc/puppetlabs/puppet/puppetdb.conf
#change Java Heap Size
  sed -i "s/192m/4g/g" /etc/default/puppetdb
#wait for puppetdb loads and signs certificate request
  while [ ! -f /etc/puppetlabs/puppet/ssl/ca/signed/$FQDN.pem ]
  do
    echo Waiting for certificates...
    sleep 5
  done
#copy certificate, setup ssl for puppetdb
  puppet agent --disable
  /opt/puppetlabs/bin/puppetdb ssl-setup -f
fi
#and start puppetdb
#r10k deploy environment -v
#r10k deploy environment -pv
#if [ "$RESTART" == "1" ]
#then
#  export PUPPETSERVER_PID=`ps aux | grep puppet-server | grep -v runuser | grep -v grep | awk {'print $2'}`
#  echo "echo Goodbye, puppetserver && kill -9 $PUPPETSERVER_PID" | at now + 2 minutes
#fi
/opt/puppetlabs/bin/puppetdb foreground
