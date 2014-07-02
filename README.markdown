## Mapserver appliance

This git will build a fresh new Ubuntu 12.04 (precise 64bit) virtual server with VirtualBox and Vagrant.  An empty osm postgresql database is ready to use.  You have to select your public network (interface).  Database port foward is 5454

 * Database user/pw  : osm/osm
 * Ubuntu user/pw  : vagrant/vagrant
 * Database port foward : 5454
 * Web port foward : 8080

## Prerequired

 * VirtualBox
 * Vagrant

## Package list

 * python2.7
 * postgresql-9.1, PostGIS (with a osm database)
 * Apache2, WSGI mod
 * Mapserver 6.2, Mapcache, tinyows
 * imposm, osm2pgsql, osmosis
    
## On Mac / Ubuntu

	sh ./init_vagrant.sh
	vagrant ssh
	http://localhost:8080

## On Windows

 * Download this repo and unzip it
 * In your unzip directory, download this file http://files.vagrantup.com/precise64.box


	vagrant box add scribeui precise64.box 
	vagrant up 
	vagrant ssh


 * Connec with your favorit client (MobaXtrem or putty)





