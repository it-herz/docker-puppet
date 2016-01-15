FROM debian:latest

MAINTAINER Dmitrii Zolotov <dzolotov@herzen.spb.ru>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget && cd /tmp && \
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb && dpkg -i *.deb && \
    apt-get update && apt-get install -y puppetserver puppetdb r10k git activemq python-setuptools puppetdb-termini mc at && \
    mkdir /usr/share/activemq/activemq-data && chmod 777 -R /usr/share/activemq/activemq-data && \
    mkdir /var/run/activemq && chown activemq /var/run/activemq && chmod 755 -R /var/run/activemq && chown activemq /var/lib/activemq/data/ && chmod 755 /var/lib/activemq/data/ && \
    sed -i "s/stomp1/localhost/g" /etc/puppetlabs/mcollective/client.cfg && sed -i "s/stomp1/localhost/g" /etc/puppetlabs/mcollective/server.cfg && \
    echo "Europe/Moscow" >/etc/timezone && dpkg-reconfigure tzdata && \
    mkdir /opt/puppetlabs/mcollective/plugins/mcollective && cd /opt/puppetlabs/mcollective/plugins/mcollective && \
    git clone https://github.com/puppetlabs/mcollective-puppet-agent . && rm -rf /etc/puppetlabs/code/environments && rm -rf /etc/puppetlabs/code/hieradata && \
    mkdir -p /var/cache/r10k && ln -s /opt/puppetlabs/bin/puppet /usr/bin && ln -s /opt/puppetlabs/bin/mco /usr/bin && ln -s /opt/puppetlabs/bin/facter /usr/bin && rm /etc/puppetlabs/puppet/puppet.conf && rm /etc/puppetlabs/puppetdb/conf.d/jetty.ini

ADD hiera.yaml /etc/puppetlabs/code/
ADD r10k.agent.rb /opt/puppetlabs/mcollective/plugins/mcollective/agent/r10k.rb
ADD r10k.ddl /opt/puppetlabs/mcollective/plugins/mcollective/agent/r10k.rb
ADD r10k.application.rb /opt/puppetlabs/mcollective/plugins/mcollective/application/r10k.rb
ADD puppet.conf /etc/puppetlabs/puppet/
ADD puppetdb.conf /etc/puppetlabs/puppet/

RUN mkdir /var/log/supervisor/
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
RUN /usr/bin/easy_install supervisor-logging
ADD run_puppet_db.sh /opt/puppetlabs/
ADD run_puppet.sh /opt/puppetlabs/
ADD supervisord.conf /etc/supervisord.conf
ADD activemq.xml /etc/activemq/instances-enabled/mco/
ADD log4j.properties /etc/activemq/instances-enabled/mco/
ADD jetty.ini /etc/puppetlabs/puppetdb/conf.d

VOLUME ["/etc/puppetlabs/puppet/ssl","/etc/puppetlabs/code/environments","/etc/puppetlabs/code/hieradata","/etc/r10k.yaml"]

EXPOSE 8140 6163 8080 8081

CMD ["supervisord","-n","-c","/etc/supervisord.conf"]
