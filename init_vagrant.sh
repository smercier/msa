#!/bin/bash
echo ===== Vagrant and Virtualbox =====
wget http://files.vagrantup.com/precise64.box
vagrant box add scribeui precise64.box
vagrant up


