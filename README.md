# Documentation Vagrant mit Docker

## Installation der Vagrant Box

Die Grundinstallation der VM wird anhand der [Dokumentation](http://webdevops-documentation.readthedocs.io/projects/vagrant-docker-vm/en/ubuntu-16.04/content/gettingStarted/index.html#installation "Zur Dokumentation") von WebDevOps durchgeführt.

Diese Anleitung bezieht sich auf das Projekt "***PhotoFancy***".
Die Vagrant Box wird hier in den Ordner ***photofancy-environment*** installiert.


> :information_source: Die CPU Virtualisierungstechnologie nicht vergeßen zu aktivieren.

```bash
git clone --recursive --config core.autocrlf=false https://github.com/webdevops/vagrant-development.git photofancy-environment

cd photofancy-environment
```

bindfs Plugin installieren
```bash
vagrant plugin install vagrant-bindfs
```

Wenn unter OSX der Parallels Provider benutzt wird, muss das Plugin installiert werden
```bash
vagrant plugin install vagrant-parallels
```

Wenn unter Windows die VMWare Workstation benutzt wird, muss das Plugin installiert werden
```bash
vagrant plugin install vagrant-vmware-workstation
```

## Spezielle Anpassungen der VM

### Anpassungen in der vm.yml

CPU und Speicher der Box zuweisen, Beispiel anhand eines Quadcore Prozessors und min. 8GB RAM
```yml
    cpu: '2'
    memory: '6144' // composer braucht > 4096 Arbeitsspeicher
```

Die SharedFolder müssen je nach Betriebssystem angepasst werden.
```yml
    # OSX
    sharedFolder:
        - { type: 'nfs', src: '~/Workspace/Webentwicklung', target: '/var/www' }
```

```yml
    # Windows (Source je nach User anpassen)
    sharedFolder:
        - { type: 'default', src: 'C:/www', target: '/var/www'}
```

Um den "Authentication failure" Warning zu vermeiden
```yml
    useSshPasswordAuth: true
```

### Anpassungen im Vagrantfile
Das automatische Update der Parallels-Tools muss deaktiviert werden, da sonst die Box nicht startet (Tools können nicht installiert werden) - auf **false** setzen
```ruby
    v.update_guest_tools = false
```
Die NFS Rechte müssen auch angepasst werden (Nur für OSX).
```ruby
    :nfs => { :mount_options => [ "dmode=777", "fmode=777" ] }
```
Unter OSX mit Parallels Provider müssen folgende Zeilen auskommentiert werden, da die Box nicht "headless" startet:
```ruby
    #v.customize ["set", :id, "--startup-view", "headless"]
```
## Installation PHP Docker Boilerplate

Offizielle [PHP Docker Boilerplate Dokumentation](https://github.com/webdevops/php-docker-boilerplate "Zur offiziellen PHP Docker Boilerplate Dokumentation").


Vagrant Box starten
```bash
vagrant up
```
    
Per SSH in die Box einloggen
```bash
vagrant ssh
username/password: vagrant
```

Auf dem Ubuntu-System dann in den Projekt-Order navigieren.
```bash
cd /var/www/photofancy-environment
```

### Grundinstallation

:information_source: GitHub Benutzername/Kennwort erforderlich
```bash
git clone https://github.com/digitalprint/photofancy-docker-boilerplate.git photofancy
```

##### in den photofancy Ordner wechseln
```bash
cd photofancy
```

##### docker-compose.yml erstellen
```bash
cp docker-compose.development.yml docker-compose.yml
```

Anschließend die Container hochfahren.
```bash
docker-compose up -d
```

Wenn man an der Konfiguration etwas ändert, reicht es in den meisten Fällen, die Container neu zu starten.
```bash
docker-compose stop
docker-compose up -d
```

... ansonsten alten Container entfernen und neu bilden (Beispiel MySQL)
```bash
docker-compose rm mysql
```

Zum Schluss die IP in der ***hosts*** Datei *(in deine Host-Maschine)* auf photofancy mappen.

    192.168.56.2 local.photofancy.de local.photofancy.ro local.photofancy.pl local.photofancy.co.uk local.photofancy.es local.photofancy.fr local.photofancy.it local.photofancy.com

## PhotoFancy Projekt Setup

### PhotoFancy Projekt in den ***app*** Ordner klonen
```bash    
git clone https://github.com/digitalprint/photofancy2.git app
```

### Anpassungen parameters.yml
Die vorhandene ***parameters.yml*** in den ***app/config*** Ordner kopieren und dann den MySQL- Host und Port anpassen...
```yml
    database_host: mysql
    database_port: 3306
```


... sowie alle Ordnerpfade anpassen.
```yml
    shared_dir_web: _filesystem
    shared_dir_resources: _filesystem/resources
    shared_dir_pfresources: _filesystem/resources
    shared_dir_cache: _filesystem/photofancy/cache
    shared_dir_orders: _filesystem/photofancy/output
    shared_dir_effect_repository: _filesystem/photofancy/repo/private/effects/current
    shared_dir_effect_src: _filesystem/photofancy/repo/private/effects/current/provider/pf/filter/src
    shared_dir_uploads: _filesystem/uploads
    shared_dir_assets: _filesystem/assets
```

... und den Node Pfad auf /usr/bin setzen
```yml
    node_module_path: /usr/bin
```

und wechseln anschließend in das PhotoFancy Projekt
```bash
cd /var/www/photofancy-environment/photofancy/app
```

## Mit Docker-Container verbinden
Um später die Befehle der ***php app/console*** auszuführen, muss man sich mit der Container-Instanz verbinden. Man landet direkt im Projektverzeichnis.

```bash
docker exec -t -i photofancy_app_1 /bin/bash
```

PhotoFancy Setup via Composer
```bash
php -dmemory_limit=-1 /usr/local/bin/composer install -o --prefer-dist
```

Anschließend wechseln wir wieder zurück in den PhotoFancy Projekt Ordner 
```bash
cd /var/www/photofancy-environment/photofancy
```

## Docker-Container hochfahren und verbinden

### Datenbank Create & Sync

DB Erzeugen
```bash
php app/console doctrine:schema:create
```

Session Tabelle anlegen
```bash
php app/console doctrine:query:sql "CREATE TABLE sessions ( sess_id VARBINARY(128) NOT NULL PRIMARY KEY, sess_data BLOB NOT NULL, sess_time INTEGER UNSIGNED NOT NULL, sess_lifetime MEDIUMINT NOT NULL ) COLLATE utf8_bin, ENGINE = InnoDB;"
```

Lokale DB -> Online DB Sync
```bash
php app/console pf:database:sync
```

## Benutzer anlegen: ##

Admin-Benutzer für die lokale Dev-umgebung anlegen (Username=pfadmin, Passwort=pfadmin)

```bash
php app/console fos:user:create pfadmin admin@dev.photofancy.de pfadmin

php app/console fos:user:promote ppadmin ROLE_ADMIN
```


## PhotoFancy Installer starten

Hier werden alle benötigten Tools wie Gmic, Potrace, OpenCV etc. installiert.

...wir befinden uns immer noch im Docker App-Container...

```bash
cd /opt/docker/etc/installer
./photofancy.sh
```

Anschließend müssen noch die Assets für das dev-Environment installiert werden.

```bash
cd /app
php app/console assets:install web --symlink
```


## PhotoFancy Effektmanager Projekt Setup
Als letztes muss noch das Effektmanager Repository geklont werden.

```bash
cd /app
git clone https://github.com/digitalprint/photofancy-effectmanager.git web/_filesystem/photofancy/repo/private/effects/current
```

## Glückwunsch - PhotoFancy ist jetzt unter local.photofancy.de:8000/app_dev.php als Entwicklungsumgebung erreichbar! 

## Starten und Stoppen von Vagrant und Docker

### 1. Starten der Vagrant Box und Docker-Container

1. Vagrant starten
```bash
cd pfad_zum_ordner_photofancy-environment
vagrant up
```

2. In die Vagrant Box per SSH einwählen
```bash
vagrant ssh
```

3. Docker-Container starten
```bash
cd /var/www/photofancy-environment/photofancy
docker-compose up -d
```

4. Jetzt kannst du photofancy von dein Browser besuchen
http://local.photofancy.de:8000 oder https://local.photofancy.de:8443


### 2. Stoppen der Vagrant Box und Docker-Container

1. Docker-Container stoppen (man muss sich in der Vagrant Box befinden)
```bash
docker-composer stop
```

2. Vagrant Box stoppen / neustarten

Falls man sich noch in der Vagrant Box befindet, diese mit ***exit*** verlassen, anschließend

1. Stoppen
```bash
vagrant halt
```

2. Neustarten
```bash
vagrant reload
```
    
3. Neustarten und neu Provisionieren (nach Änderungen in der config.yml)
```bash
vagrant reload --provision
```

### 3. In den Docker-App-Container springen
```bash 
docker exec -t -i photofancy_app_1 /bin/bash
```

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