# docker-puppet
Dockerized Puppet Server

Puppet server with embedded r10k / hiera deployment + MCollective

Published ports:
- 8080 - PuppetDB Web Interface
- 8081 - PuppetDB API
- 8140 - Puppet Server
- 6163 - ActiveMQ Port (STOMP)

Execute:
```` 
docker run -itd -p 8140:8140 -p 8080:8080 -p 8081:8081 -p 6163:6163 -v /etc/r10k.yaml:/etc/r10k.yaml -v /etc/puppetlabs/code/environments/:/etc/puppetlabs/code/environments -v /etc/puppetlabs/code/hieradata/:/etc/puppetlabs/code/hieradata -v /ssl:/etc/puppetlabs/puppet/ssl --name puppet --hostname puppet.hspu.local docker.hspu.local:80/puppet
````

- --hostname - FQDN for server
- /ssl - directory for CA / issued certificates
- /etc/puppetlabs/code/enviroments - modules & Puppetfile
- /etc/puppetlabs/code/hieradata - hiera configuration
- /etc/r10k.yaml - R10K configuration (for example)
````
:cachedir: /var/cache/r10k

:sources:
  environments:
    basedir: /etc/puppetlabs/code/environments
    prefix: false
    remote: http://...
  hiera:
    basedir: /etc/puppetlabs/code/hieradata
    prefix: false
    remote: http://...

````
