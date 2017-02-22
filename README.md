#Documentation Vagrant mit Docker

##Installation der Vagrant Box

Die Grundinstallation der VM wird anhand der [Dokumentation](http://webdevops-documentation.readthedocs.io/projects/vagrant-docker-vm/en/ubuntu-16.04/content/gettingStarted/index.html#installation "Zur Dokumentation") von WebDevOps durchgeführt.

Diese Anleitung bezieht sich auf das Projekt "***PhotoFancy***".
Die Vagrant Box wird hier in den Ordner ***vagrant-docker*** installiert.

	git clone --recursive --config core.autocrlf=false https://github.com/webdevops/vagrant-development.git vagrant-docker
	
	cd vagrant-docker

###spezielle Anpassungen der VM

#####Anpassungen in der vm.yml
Die SharedFolder müssen je nach Betriebssystem angepasst werden.

	# OSX
	sharedFolder:
		- { type: 'nfs', src: '~/Workspace/Webentwicklung', target: '/var/www' }

	# Windows
	sharedFolder:
		- { type: 'home' }

Die Port-Weiterleitungen auf Port 80 sollte angepasst werden.

	portForwarding:
		- { guest: 80, host: 80, hostIp: '192.168.56.2', protocol: 'tcp' }

####Für OSX mit Parallels-Provider

Bevor die Vagrant Box gestartet wird, müssen die ***Parallels*** und 
***bindfs*** Plugins installiert werden.

	vagrant plugin install vagrant-parallels
	vagrant plugin install vagrant-bindfs

#####Anpassungen im Vagrantfile
Das automatische Update der Parallels-Tools muss deaktiviert werden, da sonst die Box nicht startet (Tools können nicht installiert werden) - auf **false** setzen

	v.update_guest_tools = false
	
Die NFS Rechte müssen auch angepasst werden.

	:nfs => { :mount_options => [ "dmode=777", "fmode=777" ] }
	
##Installation PHP Docker Boilerplate

Offizielle [PHP Docker Boilerplate Dokumentation](https://github.com/webdevops/php-docker-boilerplate "Zur offiziellen PHP Docker Boilerplate Dokumentation").

Vagrant Box starten

	vagrant up

Nach dem Starten der VM-Box per ***vagrant ssh*** einwählen, dann in den entprechenden Order navigieren.

	cd /var/www/vagrant-docker


###Grundinstallation

	git clone --recursive https://github.com/digitalprint/photofancy-docker-boilerplate.git photofancy
	
	cd photofancy
	
	# copy favorite docker-compose.*.yml to docker-compose.yml
	cp docker-compose.development.yml docker-compose.yml

#####Anpassungen im Dockerfile.development

Ubuntu 14.04 mit PHP 5.6 eintragen

	FROM webdevops/php-apache-dev:ubuntu-14.04

Für ***PhotoFancy*** fehlen noch einige Module. Die unter dem ***RUN bootstrap.sh*** Befehl einfügen.

	# Install tools
	RUN add-apt-repository ppa:otto-kesselgulasch/gimp
	RUN apt-get update
	RUN apt-get install -y ruby-sass
	RUN apt-get install -y mc
	RUN apt-get install -y vim
	RUN apt-get install -y jhead
	RUN apt-get install -y mysql-client unixodbc libpq5
	
	# Install Gmic
	RUN apt-get install -y gmic gimp-gmic
	
	# Install SphinxSearch
	RUN apt-get install -y sphinxsearch
	
	RUN rm -rf /var/lib/apt/lists/*
	RUN apt-get clean -y

#####Anpassungen etc/environment.yml
Document Root für ***PhotoFancy***'s Symfony Applikation anpassen

	WEB_DOCUMENT_ROOT=/app/web/
	WEB_DOCUMENT_INDEX=app_dev.php

	DOCUMENT_ROOT=/app/web/
	DOCUMENT_INDEX=app_dev.php

***PhotoFancy*** Standard Werte für MySQL eintragen

	MYSQL_ROOT_PASSWORD=photofancy_standard_password
	MYSQL_DATABASE=photofancy

#####Anpassungen docker-compose.yml
Der ***nfs*** Ordner muss mit in den Storage eingebunden werden. Je nach System den entsprechenden Ordner verknüpfen. Als Docker-Storage Name verwenden wir ***pfshared***

	Für OSX:
	
	storage:
		build:
		context: docker/storage/
	volumes:
		- /storage
		- /var/www/_nfs_:/pfshared

#####Anpassungen etc/php/development.ini
Die Datei ***ect/php/development.ini*** überschreibt gewisse Parameter der ***php.ini***. Hier muss nur der IDE-Key angepasst werden.

	xdebug.idekey = "PHPSTORM"
	
Anschließend die Container bilden und hochfahren.

	docker-compose up -d
	
Wenn man an der Konfiguration etwas ändert, reicht es in den meisten Fällen, die Container neu zu starten.

	docker-compose stop
	docker-compose up -d
	
... ansonsten alten Container entfernen und neu bilden (Beispiel MySQL)

	docker-compose rm mysql
	
Zum Schluss die IP in der ***hosts*** Datei auf local.photofancy.de mappen.

	192.168.56.2 local.photofancy.de
	

##PhotoFancy Projekt einbinden (BETA)

zum ersten Testen kann der komplette Inhalt des aktuellen ***PhotoFancy*** Projekts in den ***app*** Ordner kopiert werden (ohne den ***.git*** Ordner!).

#####Anpassungen parameters.yml
Der MySQL- Host und Port muss angepasst werden:

	database_host: mysql
	database_port: 3306

Alle alten Verlinkungen auf den ***nfs*** Ordner müssen ersetzt werden:

	Alt: /var/www/_nfs_/
	Neu: /pfshared/

#####Datenbank füllen
Die Datenbank muss erstmal mit einem alten Dump gefüllt werden, bevor man den Sync mit der Online-DB machen kann.

#####Datenbank Verbindung per SSH (MySQL-Tool)

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

	cd web
	ln -nfs /pfshared/ _filesystem