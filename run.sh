#!/bin/bash
docker run -rm -it --name sladpd \
  -p 389:389 \
  -v /swinfra_data/ldap:/var/lib/ldap \
  nickstenning/slapd

docker run -rm -it --name swinfra \
  -p 389:389 \
  -p 80:80 \
  -v /swinfra_data/ldap:/var/lib/ldap \
  -v /swinfra_data/lam:/var/lib/ldap-account-manager/config \
  swcho/swinfra