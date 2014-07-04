#!/bin/bash
echo ===== Vagrant and Virtualbox =====
if [ ! -f precise64.box ]
then
     wget http://files.vagrantup.com/precise64.box
fi
vagrant box add --force scribeui precise64.box
vagrant up


