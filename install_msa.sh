#!/bin/bash
echo ===== need to execut as root ... =====
echo ===== Install utf-8 =====
export LANGUAGE=en_CA.UTF-8
export LANG=en_CA.UTF-8
export LC_ALL=en_CA.UTF-8
sudo localedef -i en_CA -f UTF-8 en_CA
sudo locale-gen en_CA.UTF-8
sudo update-locale
sudo sudo dpkg-reconfigure locales
echo ===== Vagrant Postinstal =====
# sudo sh postinstall.sh
sudo apt-get update
echo ===== Mapserver Suite OSM tool =====
sudo apt-get install -y python2.7 python-software-properties
sudo add-apt-repository -y ppa:ubuntugis/ppa
sudo apt-get update
sudo apt-get install -y postgresql-9.1 postgresql-server-dev-9.1 postgresql-contrib-9.1 postgis
sudo apt-get install -y apache2 binutils checkinstall git vim screen make python-virtualenv python-pip python-all-dev osm2pgsql osmosis
sudo apt-get install -y gdal-bin cgi-mapserver mapserver-bin libmapcache mapcache-cgi mapcache-tools libapache2-mod-mapcache tinyows
sudo mkdir /tmp/ms_tmp
sudo chown www-data:www-data /tmp/ms_tmp

echo ===== OSM tool =====
wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert
sudo mv osmconvert /usr/bin
sudo apt-get install -y build-essential python-dev protobuf-compiler libprotobuf-dev libtokyocabinet-dev python-psycopg2 libgeos-c1
sudo pip install imposm

echo ===== WSGI mod =====
sudo wget https://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz
sudo tar xzf mod_wsgi-3.4.tar.gz && cd mod_wsgi-3.4
./configure --with-python=/usr/bin/python2.7
sudo make
sudo make install
cat >/etc/apache2/mods-enabled/wsgi2.load  <<EOF 
LoadModule wsgi_module /usr/lib/apache2/modules/mod_wsgi.so 
EOF

sudo ln -s /etc/apache2/mods-enabled/wsgi.load /etc/apache2/mods-available/wsgi
echo ===== init PostGIS =====
sudo su postgres -c'createdb -E UTF8 --lc-ctype en_CA.UTF-8 -T template0 template_postgis'
sudo su postgres -c'createlang -d template_postgis plpgsql;'
sudo su postgres -c'psql -U postgres -d template_postgis -c"CREATE EXTENSION postgis;"'
sudo su postgres -c'psql -U postgres -d template_postgis -c"CREATE EXTENSION hstore;"'
sudo su postgres -c'psql -U postgres -d template_postgis -c"CREATE EXTENSION unaccent;"'
sudo su postgres -c'psql -U postgres -d template_postgis -c"CREATE EXTENSION tsearch2;"'
sudo su postgres -c'psql -U postgres -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"'
sudo su postgres -c'psql -U postgres -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"'
sudo su postgres -c'psql -U postgres -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"'
sudo su postgres -c'createdb -E utf8 -T template_postgis osm'
sudo su postgres -c'psql -U postgres -d osm -c "CREATE USER osm WITH PASSWORD '"'"'osm'"'"';"'
sudo su postgres -c'psql -U postgres -d osm -c "GRANT ALL PRIVILEGES ON DATABASE osm to osm;"'
echo ===== Configuring postgresql =====
sed -i -e "s/#listen_addresses\ \=\ 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.1/main/postgresql.conf
echo "host    all             all             0.0.0.0/0            md5" | tee -a /etc/postgresql/9.1/main/pg_hba.conf > /dev/null
service postgresql restart
echo ===== Install ScribeUI =====

cd /opt
sudo git clone https://github.com/mapgears/scribeui.git
cd scribui

PATH_=${PWD} 
CURRENT_DIR=${PWD##*/}

echo "creating $PATH_/pyramid.wsgi"

cat > $PATH_/pyramid.wsgi <<EOF
from pyramid.paster import get_app, setup_logging
ini_path = '$PATH_/production.ini'
setup_logging(ini_path)
application = get_app(ini_path, 'main')
EOF

echo "Install app..."
sudo make
sudo chown -R youruser .
make install
sudo make perms

if [ ! -f /etc/apache2/sites-available/$CURRENT_DIR ]
then

echo "Creating /etc/apache2/sites-available/$CURRENT_DIR"

cat > /etc/apache2/sites-available/$CURRENT_DIR <<EOF
WSGIDaemonProcess $CURRENT_DIR user=www-data group=www-data threads=10 python-path=$PATH_/lib/python2.7/site-packages
WSGIScriptAlias /$CURRENT_DIR $PATH_/pyramid.wsgi

<Directory $PATH_>
        WSGIApplicationGroup %{ENV:APPLICATION_GROUP}
        WSGIPassAuthorization On
        WSGIProcessGroup $CURRENT_DIR
        Order deny,allow
        Allow from all
</Directory>
EOF

ln -s /etc/apache2/sites-available/$CURRENT_DIR /etc/apache2/sites-enabled/$CURRENT_DIR


fi

sudo ln -s /etc/apache2/sites-available/scribeui_pyramid /etc/apache2/sites-enabled/scribeui_pyramid
sudo apachectl restart

