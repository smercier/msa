#!/bin/bash
echo ===== need to execut as root ... =====
echo ===== Install utf-8 =====
export LANGUAGE=en_CA.UTF-8
export LANG=en_CA.UTF-8
export LC_ALL=en_CA.UTF-8
localedef -i en_CA -f UTF-8 en_CA
locale-gen en_CA.UTF-8
update-locale
dpkg-reconfigure locales
echo ===== Vagrant Postinstal =====
# sh postinstall.sh
apt-get update
echo ===== Mapserver Suite OSM tool =====
apt-get install -y python2.7 python-software-properties
add-apt-repository -y ppa:ubuntugis/ppa
apt-get update
apt-get install -y postgresql-9.1 postgresql-server-dev-9.1 postgresql-contrib-9.1 postgresql-9.1-postgis-2.0
apt-get install -y apache2 binutils checkinstall git vim screen make python-virtualenv python-pip python-all-dev osm2pgsql osmosis
apt-get install -y gdal-bin cgi-mapserver mapserver-bin libmapcache mapcache-cgi mapcache-tools libapache2-mod-mapcache tinyows
mkdir /tmp/ms_tmp
chown www-data:www-data /tmp/ms_tmp

echo ===== OSM tool =====
wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert
mv osmconvert /usr/bin
apt-get install -y build-essential python-dev protobuf-compiler libprotobuf-dev libtokyocabinet-dev python-psycopg2 libgeos-c1
pip install imposm

echo ===== WSGI mod =====
apt-get -y install python-dev apache2-prefork-dev
wget https://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz
tar xzf mod_wsgi-3.4.tar.gz && cd mod_wsgi-3.4
./configure --with-python=/usr/bin/python2.7
make
make install

cat >/etc/apache2/mods-available/wsgi.load  <<EOF 
LoadModule wsgi_module /usr/lib/apache2/modules/mod_wsgi.so 
EOF
ln -s /etc/apache2/mods-available/wsgi.load /etc/apache2/mods-enabled/wsgi.load


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
echo "host    all             all             0.0.0.0/0            md5" | tee -a : > /dev/null
service postgresql restart
echo ===== Install ScribeUI =====

cd /opt
git clone https://github.com/smercier/scribeui.git && cd scribeui

echo "Install app..."

sed -i -e "s/'127.0.0.1'/'127.0.0.1:8080'/g" proxy.cgi
sed -i -e "s/localhost\/cgi-bin/localhost:8080\/cgi-bin/g" production.ini
sed -i -e "s/mapcache.output.directory =/#mapcache.output.directory =/g" production.ini
cp production.ini local.ini
make
make install
make perms
## make load-basescribe-data

echo "creating /opt/scribeui/pyramid.wsgi"

cat > /opt/scribeui/pyramid.wsgi <<EOF
from pyramid.paster import get_app, setup_logging
ini_path = '/opt/scribeui/production.ini'
setup_logging(ini_path)
application = get_app(ini_path, 'main')
EOF

echo "Creating /etc/apache2/sites-available/scribeui"

cat > /etc/apache2/sites-available/scribeui <<EOF
WSGIDaemonProcess scribeui user=www-data group=www-data threads=10 python-path=/opt/scribeui/lib/python2.7/site-packages
WSGIScriptAlias /scribeui /opt/scribeui/pyramid.wsgi

<Directory /opt/scribeui/>
        WSGIApplicationGroup %{ENV:APPLICATION_GROUP}
        WSGIPassAuthorization On
        WSGIProcessGroup scribeui
        Order deny,allow
        Allow from all
</Directory>
EOF

ln -s /etc/apache2/sites-available/scribeui /etc/apache2/sites-enabled/scribeui

service apache2 restart

