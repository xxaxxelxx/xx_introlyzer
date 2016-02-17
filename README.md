# ***CUSTOMERWEB***
# Customers web module
# Part of Dockerized Distributed Streaming System

[xxaxxelxx/xx_customerweb](https://index.docker.io/u/xxaxxelxx/xx_customerweb/)

## Synopsis
This repo is the base for an [automated docker build](https://hub.docker.com/r/xxaxxelxx/xx_customerweb/) and is part of a dockerized distributed streaming system consisting of following elements:
* [xxaxxelxx/xx_customerweb](https://github.com/xxaxxelxx/xx_customerweb)
* [xxaxxelxx/xx_bridgehead](https://github.com/xxaxxelxx/xx_bridgehead)
* [xxaxxelxx/xx_coverter](https://github.com/xxaxxelxx/xx_converter)
* [xxaxxelxx/xx_customerweb](https://github.com/xxaxxelxx/xx_customerweb)
* [xxaxxelxx/xx_geograph](https://github.com/xxaxxelxx/xx_geograph)
* [xxaxxelxx/xx_icecast](https://github.com/xxaxxelxx/xx_icecast)
* [xxaxxelxx/xx_liquidsoap](https://github.com/xxaxxelxx/xx_liquidsoap)
* [xxaxxelxx/xx_loadbalancer](https://github.com/xxaxxelxx/xx_loadbalancer)
* [xxaxxelxx/xx_logsplitter](https://github.com/xxaxxelxx/xx_logsplitter)
* [xxaxxelxx/xx_pulse](https://github.com/xxaxxelxx/xx_pulse)
* [xxaxxelxx/xx_reflector](https://github.com/xxaxxelxx/xx_reflector)
* [xxaxxelxx/xx_rrdcollect](https://github.com/xxaxxelxx/xx_rrdcollect)
* [xxaxxelxx/xx_rrdgraph](https://github.com/xxaxxelxx/xx_rrdgraph)
* [xxaxxelxx/xx_sshdepot](https://github.com/xxaxxelxx/xx_sshdepot)
* [xxaxxelxx/xx_sshsatellite](https://github.com/xxaxxelxx/xx_sshsatellite)

The running docker container provides a service for very special streaming purposes usable for a distributed architecture.
It presumably will not fit for you, but it is possible to tune it. If you need some additional information, please do not hesitate to ask.

This [xxaxxelxx/xx_customerweb](https://hub.docker.com/r/xxaxxelxx/xx_customerweb/) repo is an essential part of a complex compound used for streaming.
It provides web services to the customers.

### Example
```bash
$docker run -d --name customerweb --volumes-from sshdepot -e CUSTOMERPASSWORD_admin=PASSWORD_ADMIN -e CUSTOMERPASSWORD_CUSTOMER_1=PASSWORD_CUSTOMER_1  -e CUSTOMERPASSWORD_CUSTOMER_2=PASSWORD_CUSTOMER_2 -e CUSTOMERPASSWORD_CUSTOMER_N=PASSWORD_CUSTOMER_N -p 81:80 --restart=always xxaxxelxx/xx_customerweb  customer_1 customer_2 customer_n
```
***

## License

[MIT](https://github.com/xxaxxelxx/xx_Liquidsoap/blob/master/LICENSE.md)
