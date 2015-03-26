FROM phusion/baseimage:0.9.8
MAINTAINER Sungwoo <sungwoo.cho.dev@gmail.com>

#################################################################
# SLAPD
# https://github.com/aexo/docker-ldap-account-manager
#################################################################

ENV HOME /root

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Configure apt
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
RUN apt-get -y update

# Install slapd
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y slapd

# Default configuration: can be overridden at the docker command line
ENV LDAP_ROOTPASS root
ENV LDAP_ORGANISATION SwForge
ENV LDAP_DOMAIN swforge.com

EXPOSE 389

RUN mkdir /etc/service/slapd
ADD etc/service/slapd/run /etc/service/slapd/run
RUN chmod +x /etc/service/slapd/run

# To store the data outside the container, mount /var/lib/ldap as a data volume

#################################################################
# LAM
# https://github.com/aexo/docker-ldap-account-manager
#################################################################

#install ldap account manager
RUN C_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y install ldap-account-manager

# copy default config lam
RUN cp -r /var/lib/ldap-account-manager/config /opt/lam

EXPOSE 80

#RUN rm /etc/apache2/sites-enabled/*default*

RUN mkdir /etc/service/apache2
ADD etc/service/apache2/run /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

# docker run  -v /data/lam:/var/lib/ldap-account-manager/config -d aexoti/lam

#################################################################
# MySQL
# https://github.com/vpetersson/redmine
#################################################################


#################################################################
# Redmine
# https://github.com/vpetersson/redmine
#################################################################

# Install required packages
RUN apt-get -qq update && \
    apt-get -qq install -y wget ruby ruby-dev build-essential imagemagick libmagickwand-dev libmysql-ruby libmysqlclient-dev apache2 apt-transport-https ca-certificates git-core subversion && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 && \
    echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list && \
    apt-get -qq update && \
    apt-get -qq install -y libapache2-mod-passenger && \
    apt-get clean

ENV BRANCH 2.6-stable
RUN cd /usr/local && \
    git clone https://github.com/redmine/redmine.git && \
    cd redmine && \
    git checkout $BRANCH && \
    rm -rf .git

RUN touch /usr/local/redmine/log/production.log
WORKDIR /usr/local/redmine

# Install dependencies
RUN gem install -q bundler mysql2 && \
    bundle install --without development test

# Add files and clean up unnecessary files
ADD etc/apache2/redmine_apache.conf /etc/apache2/redmine_apache.conf
ADD etc/service/redmine/run /etc/service/redmine/run

EXPOSE 3000

#################################################################
# clean up

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

