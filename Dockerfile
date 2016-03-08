FROM debian:jessie
MAINTAINER xxaxxelxx <x@axxel.net>

<<<<<<< HEAD
RUN sed -e 's/$/ contrib non-free/' -i /etc/apt/sources.list 
=======
#RUN sed -e 's/$/ contrib non-free/' -i /etc/apt/sources.list 
>>>>>>> 85240ecf05cee9bac4867a5f5905447fb6436366

RUN apt-get -qq -y update
#RUN apt-get -qq -y dist-upgrade

ENV TERM=xterm
<<<<<<< HEAD
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq -y install sudo

RUN apt-get -qq -y install mc 
RUN apt-get -qq -y install less
RUN apt-get -qq -y install bc 
RUN apt-get -qq -y install geoip-bin
RUN apt-get -qq -y install wget
RUN apt-get -qq -y install zip 
RUN apt-get clean

VOLUME /customer

COPY ./*.sh /
=======

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -qqy mc sqlite
RUN apt-get install -qqy php5-sqlite
RUN apt-get install -qqy php5-cgi
RUN apt-get install -qqy lighttpd

# clean up
RUN apt-get clean

COPY lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY *.php /
COPY *.html /
#COPY lighttpd-plain.user /etc/lighttpd/
#RUN chown -R www-data /etc/lighttpd
#RUN chown -R www-data /var/www/html

COPY entrypoint.sh /entrypoint.sh
#COPY index.html /index.html
#COPY index.php /index.php


#ENV UPDATEPASSWORD="my-_-password"

#EXPOSE 80
>>>>>>> 85240ecf05cee9bac4867a5f5905447fb6436366

ENTRYPOINT [ "/entrypoint.sh" ]
#CMD [ "bash" ]
