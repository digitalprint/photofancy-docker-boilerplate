#Documentation Vagrant mit Docker

##Installation der Vagrant Box

Die Grundinstallation der VM wird anhand der [Dokumentation](http://webdevops-documentation.readthedocs.io/projects/vagrant-docker-vm/en/ubuntu-16.04/content/gettingStarted/index.html#installation "Zur Dokumentation") von WebDevOps durchgeführt.

Diese Anleitung bezieht sich auf das Projekt "***PhotoFancy***".
Die Vagrant Box wird hier in den Ordner ***photofancy-environment*** installiert.

	git clone --recursive --config core.autocrlf=false https://github.com/webdevops/vagrant-development.git photofancy-environment
	
	cd photofancy-environment
	
	# bindfs Plugin installieren
	vagrant plugin install vagrant-bindfs
	
	# Wenn unter OSX der Parallels Provider benutzt wird, muss das Plugin installiert werden
	vagrant plugin install vagrant-parallels

##spezielle Anpassungen der VM

###Anpassungen in der vm.yml
Die SharedFolder müssen je nach Betriebssystem angepasst werden.

	# OSX
	sharedFolder:
		- { type: 'nfs', src: '~/Workspace/Webentwicklung', target: '/var/www' }

	# Windows
	sharedFolder:
		- { type: 'home' }

Die Port-Weiterleitungen auf Port 80 sollte angepasst werden (unter Windows wird Standardmäßig Port 80 gesetzt, keine Weiterleitung nötig).

	portForwarding:
		- { guest: 80, host: 80, hostIp: '192.168.56.2', protocol: 'tcp' }


###Anpassungen im Vagrantfile
Das automatische Update der Parallels-Tools muss deaktiviert werden, da sonst die Box nicht startet (Tools können nicht installiert werden) - auf **false** setzen

	v.update_guest_tools = false
	
Die NFS Rechte müssen auch angepasst werden (Nur für OSX).

	:nfs => { :mount_options => [ "dmode=777", "fmode=777" ] }
    
Unter OSX mit Parallels Provider müssen folgende Zeilen auskommentiert werden, da die Box nicht "headless" startet:

    #v.customize ["set", :id, "--startup-view", "headless"]
	
##Installation PHP Docker Boilerplate

Offizielle [PHP Docker Boilerplate Dokumentation](https://github.com/webdevops/php-docker-boilerplate "Zur offiziellen PHP Docker Boilerplate Dokumentation").

Vagrant Box starten

	vagrant up
	
Per SSH in die Box einloggen

	vagrant ssh

Auf dem Ubuntu-System dann in den entprechenden Order navigieren.

    # OSX #
	cd /var/www/photofancy-environment
	
	# Windows #
	cd /vagrant


###Grundinstallation

	git clone https://github.com/digitalprint/photofancy-docker-boilerplate.git photofancy

#####in den photofancy Ordner wechseln

	cd photofancy

#####docker-compose.yml erstellen

	cp docker-compose.development.yml docker-compose.yml
	
###Anpassungen docker-compose.yml
Der ***nfs*** Ordner muss mit in den Storage eingebunden werden. Je nach System den entsprechenden Ordner verknüpfen. Als Docker-Storage Name verwenden wir ***pfshared***

	Für OSX:
	
	volumes:
		- /storage
		- /var/www/_nfs_:/pfshared
		
	Für Windows:

    volumes:
        - /storage
        - C:/www/_nfs_:/pfshared (Benutzerdefinierten Pfad einsetzen)

Anschließend die Container hochfahren.

	docker-compose up -d
	
Wenn man an der Konfiguration etwas ändert, reicht es in den meisten Fällen, die Container neu zu starten.

	docker-compose stop
	docker-compose up -d
	
... ansonsten alten Container entfernen und neu bilden (Beispiel MySQL)

	docker-compose rm mysql
	
Zum Schluss die IP in der ***hosts*** Datei auf photofancy mappen.

	192.168.56.2 local.photofancy.de local.photofancy.ro local.photofancy.pl local.photofancy.co.uk local.photofancy.es local.photofancy.fr local.photofancy.it local.photofancy.com
	

##PhotoFancy Projekt Setup

###PhotoFancy Projekt in den ***app*** Ordner klonen
    
    git clone https://github.com/digitalprint/photofancy2.git app

###Anpassungen parameters.yml
Die vorhandene ***parameters.yml*** in den ***app/config*** Ordner kopieren und dann den MySQL- Host und Port anpassen...

	database_host: mysql
	database_port: 3306


... sowie alle alten Verlinkungen auf den ***nfs*** Ordner ersetzen.

	Alt: /var/www/_nfs_/
	Neu: /pfshared/


###Datenbank Verbindung per SSH (MySQL-Tool)

	MySQL-Host:	127.0.0.1
	Benutzer:		root
	Password:		**********
	Datenbank:	photofancy
	Port:			13306
	
	SSH-Host:		192.168.56.2
	SSH-Benutzer:	vagrant
	SSH-Password:	**********
	SSH-Port:		22


##Mit Docker-Container verbinden
Um später die Befehle der ***php app/console*** auszuführen, muss man sich mit der Container-Instanz verbinden. Man landet direkt im Projektverzeichnis.

	docker exec -t -i photofancy_app_1 /bin/bash
	
Symlink auf den pfshared muss noch gesetzt werden.

	ln -nfs /pfshared/ web/_filesystem
	
PhotoFancy Setup via Composer

	composer install

Datenbank Create & Sync

	# DB Erzeugen
	php app/console doctrine:schema:create
	
	# Session Tabelle anlegen
	php app/console doctrine:query:sql "CREATE TABLE sessions ( sess_id VARBINARY(128) NOT NULL PRIMARY KEY, sess_data BLOB NOT NULL, sess_time INTEGER UNSIGNED NOT NULL, sess_lifetime MEDIUMINT NOT NULL ) COLLATE utf8_bin, ENGINE = InnoDB;"
	
	# Lokale DB -> Online DB Sync
	php app/console pf:database:sync
	
	
##OpenCV Bibliothek installieren

    ...wir befinden uns immer noch im Docker App-Container
    
    cd /opt/docker/provision/photofancy_install
    
    git clone https://github.com/opencv/opencv.git
    
    cd opencv
    mkdir release
    cd release
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
    
    make (1-3 Kaffee-Längen)
    sudo make install
    
Das ***photofancy_install*** Verzeichnis kann jetzt wieder gelöscht werden

    rm -r /opt/docker/provision/photofancy_install
    
<br>
---

![PHP Docker Boilerplate](https://static.webdevops.io/php-docker-boilerplate.svg)

[![latest v5.2.0-beta3](https://img.shields.io/badge/latest-v5.2.0_beta3-green.svg?style=flat)](https://github.com/webdevops/php-docker-boilerplate/releases/tag/5.2.0-beta3)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

This is an easy customizable docker boilerplate for any PHP-based projects like _Symfony Framework_, _CakePHP_, _Yii_ and many other frameworks or applications.

Supports:

- Nginx or Apache HTTPd
- PHP-FPM (with Xdebug)
- MySQL, MariaDB or PerconaDB
- PostgreSQL
- Solr (disabled, without configuration)
- Elasticsearch (disabled, without configuration)
- Redis (disabled)
- Memcached (disabled)
- Mailcatcher (if no mail sandbox is used, eg. [Vagrant Development VM](https://github.com/mblaschke/vagrant-development))
- FTP server (vsftpd)
- PhpMyAdmin
- maybe more later...

This Docker boilerplate is based on the [Docker best practices](https://docs.docker.com/articles/dockerfile_best-practices/) and doesn't use too much magic. Configuration of each docker container is available in the `docker/` directory - feel free to customize.

This boilerplate can also be used for any other web project. Just customize the makefile for your needs.

*Warning: There may be issues when using it in production.*

If you have any success stories please contact me.

You can use my [Vagrant Development VM](https://github.com/mblaschke/vagrant-development) for this Docker boilerplate, e.g. for easily creating new boilerplate installations with short shell command: `ct docker:create directory`.

## Table of contents

- [First steps / Installation and requirements](/documentation/INSTALL.md)
- [Updating docker boilerplate](/documentation/UPDATE.md)
- [Customizing](/documentation/CUSTOMIZE.md)
- [Services (Webserver, MySQL... Ports, Users, Passwords)](/documentation/SERVICES.md)
- [Docker Quickstart](/documentation/DOCKER-QUICKSTART.md)
- [Run your project](/documentation/DOCKER-STARTUP.md)
- [Container detail info](/documentation/DOCKER-INFO.md)
- [Troubleshooting](/documentation/TROUBLESHOOTING.md)
- [Changelog](/CHANGELOG.md)

## Credits

This Docker layout is based on https://github.com/denderello/symfony-docker-example/

Thanks for your support, ideas and issues.
- [Ingo Pfennigstorf](https://github.com/ipf)
- [Florian Tatzel](https://github.com/PanadeEdu)
- [Josef Florian Glatz](https://github.com/jousch)
- [Ingo Müller](https://github.com/IngoMueller)
- [Benjamin Rau](https://twitter.com/benjamin_rau)
- [Philipp Kitzberger](https://github.com/Kitzberger)
- [Stephan Ferraro](https://github.com/ferraro)
- [Cedric Ziel](https://github.com/cedricziel)
- [Elmar Hinz](https://github.com/elmar-hinz)


Thanks to [cron IT GmbH](http://www.cron.eu/) for inspiration.

Did I forget anyone? Send me a tweet or create pull request!
