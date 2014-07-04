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
 * imposm 2, osm2pgsql, osmosis


## Important directory

ScribeUI will be install in `/opt/scribeui` directory.  Your map projet will be in `/opt/scribeui/workspace/[your_workspace]]`

## How to use



## Install box on Mac / Ubuntu

	sh ./init_vagrant.sh

Visite http://localhost:8080 or `vagrant ssh` to connect to your server.
	

## Install box on Windows

After install of VirtualBox and Vagrant download this repo and unzip it.  In your unzip directory, download this file http://files.vagrantup.com/precise64.box then do this


	vagrant box add scribeui precise64.box 
	vagrant up 

You should be able to visite http://localhost:8080.   Also, you now be able to connect to your server with your favorit ssh client (MobaXtrem or putty).  On Windows, vagrant saved a key file to simplify this:

	Host: 127.0.0.1
	Port: 2222
	Username: vagrant
	Private key: C:/Documents and Settings/mapgears/.vagrant.d/insecure_private_key





