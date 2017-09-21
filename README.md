# Documentation Vagrant mit Docker

## Installation der Vagrant Box

Die Grundinstallation der VM wird anhand der [Dokumentation](http://webdevops-documentation.readthedocs.io/projects/vagrant-docker-vm/en/ubuntu-16.04/content/gettingStarted/index.html#installation "Zur Dokumentation") von WebDevOps durchgeführt.

Diese Anleitung bezieht sich auf das Projekt "***PhotoFancy***".
Die Vagrant Box wird hier in den Ordner ***photofancy-environment*** installiert.

	git clone --recursive --config core.autocrlf=false https://github.com/webdevops/vagrant-development.git photofancy-environment
	
	cd photofancy-environment
	
	# bindfs Plugin installieren
	vagrant plugin install vagrant-bindfs
	
	# Wenn unter OSX der Parallels Provider benutzt wird, muss das Plugin installiert werden
	vagrant plugin install vagrant-parallels
	
	# Wenn unter Windows die VMWare Workstation benutzt wird, muss das Plugin installiert werden
	vagrant plugin install vagrant-vmware-workstation

## spezielle Anpassungen der VM

### Anpassungen in der vm.yml
Die SharedFolder müssen je nach Betriebssystem angepasst werden.

	# OSX
	sharedFolder:
		- { type: 'nfs', src: '~/Workspace/Webentwicklung', target: '/var/www' }

	# Windows (Source je nach User anpassen)
	sharedFolder:
		- { type: 'default', src: 'C:/www', target: '/var/www'}

Die Port-Weiterleitungen auf Port 80 sollte angepasst werden (unter Windows wird Standardmäßig Port 80 gesetzt, keine Weiterleitung nötig).

	portForwarding:
		- { guest: 80, host: 80, hostIp: '192.168.56.2', protocol: 'tcp' }


CPU und Speicher der Box zuweisen, Beispiel anhand eines Quadcore Prozessors und min. 8GB RAM

    cpu: '2'
    memory: '6144'

### Anpassungen im Vagrantfile
Das automatische Update der Parallels-Tools muss deaktiviert werden, da sonst die Box nicht startet (Tools können nicht installiert werden) - auf **false** setzen

	v.update_guest_tools = false
	
Die NFS Rechte müssen auch angepasst werden (Nur für OSX).

	:nfs => { :mount_options => [ "dmode=777", "fmode=777" ] }
    
Unter OSX mit Parallels Provider müssen folgende Zeilen auskommentiert werden, da die Box nicht "headless" startet:

    #v.customize ["set", :id, "--startup-view", "headless"]
	
## Installation PHP Docker Boilerplate

Offizielle [PHP Docker Boilerplate Dokumentation](https://github.com/webdevops/php-docker-boilerplate "Zur offiziellen PHP Docker Boilerplate Dokumentation").

### Grundinstallation

	git clone https://github.com/digitalprint/photofancy-docker-boilerplate.git photofancy

##### in den photofancy Ordner wechseln

	cd photofancy

##### docker-compose.yml erstellen

	cp docker-compose.development.yml docker-compose.yml
	
##### memory_limit in der php.ini anpassen
Dazu die Datei **etc/php/development.ini** öffnen und den Wert erhöhen

    memory_limit = 6000M


## PhotoFancy Projekt Setup

### PhotoFancy Projekt in den ***app*** Ordner klonen
    
    git clone https://github.com/digitalprint/photofancy2.git app

### Anpassungen parameters.yml
Die vorhandene ***parameters.yml*** in den ***app/config*** Ordner kopieren und dann den MySQL- Host und Port anpassen...

	database_host: mysql
	database_port: 3306


... sowie alle Ordnerpfade anpassen.

	shared_dir_web: _filesystem
    shared_dir_resources: _filesystem/resources
    shared_dir_pfresources: _filesystem/resources
    shared_dir_cache: _filesystem/photofancy/cache
    shared_dir_orders: _filesystem/photofancy/output
    shared_dir_effect_repository: _filesystem/photofancy/repo/private/effects/current
    shared_dir_effect_src: _filesystem/photofancy/repo/private/effects/current/provider/pf/filter/src
    shared_dir_uploads: _filesystem/uploads
    shared_dir_assets: _filesystem/assets
	
... und den Node Pfad auf /usr/bin setzen

    node_module_path: /usr/bin

## Vagrant starten und einloggen

    vagrant up
    
Wenn die Vagrant Box gestartet ist, loggen wir uns per SSH ein

    vagrant ssh
    
und wechseln anschließend in das PhotoFancy Projekt

    cd /var/www/photofancy-environment/photofancy/app
	
PhotoFancy Setup via Composer

	php -dmemory_limit=-1 /usr/local/bin/composer install -o --prefer-dist

Anschließend wechseln wir wieder zurück in den PhotoFancy Projekt Ordner 

    cd /var/www/photofancy-environment/photofancy


## Docker-Container hochfahren und verbinden

#### ACHTUNG: es gibt derzeit noch einen Fehler in der **photofancy.sh**. Nach einem Clone von Github werden die Line-Endings verändert. So lässt sich das Script nicht ausführen.
#### Dafür gibt es einen kleinen Hotfix: 

Öffne die Datei **photofancy.sh** aus dem Ordner **photofancy-environment/photofancy/etc/installer/photofancy.sh** auf deiner Festplatte in **PHPStorm**.
Anschließend einmal die Line-Endings auf **Unix/OSX (\n)** stellen. Dann noch irgendwo ein Leerzeichen einfügen, so dass das Dokument geändert wird. Nun noch speichern. Weiter gehts!

Als erstes werden die Docker-Container gestartet.

    docker-compose up -d

Um später die Befehle der ***php app/console*** auszuführen, muss man sich mit der App-Container-Instanz verbinden. 
Man landet direkt im Projektverzeichnis.

	docker exec -t -i photofancy_app_1 /bin/bash
	

### Datenbank Create & Sync

	# DB Erzeugen
	php app/console doctrine:schema:create
	
	# Session Tabelle anlegen
	php app/console doctrine:query:sql "CREATE TABLE sessions ( sess_id VARBINARY(128) NOT NULL PRIMARY KEY, sess_data BLOB NOT NULL, sess_time INTEGER UNSIGNED NOT NULL, sess_lifetime MEDIUMINT NOT NULL ) COLLATE utf8_bin, ENGINE = InnoDB;"
	
	# Lokale DB -> Online DB Sync
	php app/console pf:database:sync
	
	
## PhotoFancy Installer starten

    Hier werden alle benötigten Tools wie Gmic, Potrace, OpenCV etc. installiert.
    
    ...wir befinden uns immer noch im Docker App-Container...
    
    cd /opt/docker/etc/installer
    ./photofancy.sh
    
    Anschließend müssen noch die Assets für das dev-Environment installiert werden.
    
    cd /app
    php app/console assets:install web --symlink


## Vagrant IP in der ***hosts*** Datei auf photofancy mappen.

	192.168.56.2 local.photofancy.de local.photofancy.ro local.photofancy.pl local.photofancy.co.uk local.photofancy.es local.photofancy.fr local.photofancy.it local.photofancy.com

## PhotoFancy Effektmanager Projekt Setup
Als letztes muss noch das Effektmanager Repository geklont werden.

    cd /app
    git clone https://github.com/digitalprint/photofancy-effectmanager.git web/_filesystem/photofancy/repo/private/effects/current
    
## Glückwunsch - PhotoFancy ist jetzt unter local.photofancy.de/app_dev.php als Entwicklungsumgebung erreichbar! 

## Starten und Stoppen von Vagrant und Docker

### 1. Starten der Vagrant Box und Docker-Container

    1. Vagrant starten
    cd pfad_zum_ordner_photofancy-environment
    vagrant up
    
    2. In die Vagrant Box per SSH einwählen
    vagrant ssh
    
    3. Docker-Container starten
    cd /var/www/photofancy-environment/photofancy
    docker-compose up -d
    
    
### 2. Stoppen der Vagrant Box und Docker-Container

    1. Docker-Container stoppen (man muss sich in der Vagrant Box befinden)
    docker-composer stop
    
    2. Vagrant Box stoppen / neustarten

Falls man sich noch in der Vagrant Box befindet, diese mit ***exit*** verlassen, anschließend

    1. Stoppen
    vagrant halt
    
    2. Neustarten
    vagrant reload
    
    3. Neustarten und neu Provisionieren (nach Änderungen in der config.yml)
    vagrant reload --provision
    
    
### 3. In den Docker-App-Container springen
 
    docker exec -t -i photofancy_app_1 /bin/bash
    
    
### Datenbank Verbindung per SSH (MySQL-Tool)

	MySQL-Host:     127.0.0.1
	Benutzer:       root
	Password:       **********
	Datenbank:      photofancy
	Port:           13306
	
	SSH-Host:       192.168.56.2
	SSH-Benutzer:   vagrant
	SSH-Password:   **********
	SSH-Port:       22