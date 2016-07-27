#! /usr/bin/env bash

vagrant box remove ubuntu-trusty64-netutils
[ -f ubuntu-trusty64-netutils.box ] && rm ubuntu-trusty64-netutils.box

vagrant package --base ubuntu-trusty64 --output ubuntu-trusty64-netutils.box --vagrantfile Vagrantfile.pkg
vagrant box add --name ubuntu-trusty64-netutils ubuntu-trusty64-netutils.box