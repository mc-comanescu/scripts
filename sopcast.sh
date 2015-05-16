#!/bin/bash

function installAPT() {

#instaleaza dependente
  sudo apt-get install aptitude wget tar 
  sudo aptitude update
  sudo aptitude install libstdc++5 libstdc++5:i386 python make gettext \
       libvlc5 vlc python-gtk2 python-glade2 non-free-codecs flashplugin-nonfree \
       mplayer2 xine-console sqlite3 python-sqlite zenity 

}

function installSOP() {

#ia pachetele de sopcast
  rm -rf ~/sopcast666
  mkdir ~/sopcast666
  cd ~/sopcast666
  wget http://download.sopcast.com/download/sp-auth.tgz
  wget http://sopcast-player.googlecode.com/files/sopcast-player-0.8.5.tar.gz
  tar xvf sp-auth.tgz
  cd sp-auth
  chmod 0755 sp-sc-auth
#instaleaza /usr/bin/sp-sc-auth
  sudo cp sp-sc-auth /usr/bin
  cd ..
#compileaza si instaleaza /usr/bin/sopcast-player
  tar xvf sopcast-player-0.8.5.tar.gz
  cd sopcast-player
  make
  sudo make install
}

function installRomani() {
# executam scraper in python

python<<EOF

from subprocess import Popen
import subprocess
import urllib2
import re

def alert(mesaj, error=False):

    if error : proc=Popen("zenity --error --text='%s'" % mesaj, shell=True)
    else : proc=Popen("zenity --info --text='%s'" % mesaj, shell=True)
    proc.communicate()

# o lista de canale gen "sop://adresa" = "Titlu"
canale = {}

# initializeaza sopcast-player, ca sa avem unde sa adaugam cananlele
subprocess.call('unset DISPLAY ; sopcast-player', shell=True)
try :

    website = urllib2.urlopen('http://www.sports-tv.ro/index3.htm')
    website_html = website.read()
    #print website_html
    # alt="Titlu" onclick="OnPlay('sop://gogogog', 'Foo')"
    # title="Titlu" onclick="OnPlay('sop://gogogo', 'Foo')" 
    for rand in website_html.split('\n'):
        lista = re.search("alt=\"(.*)\" onclick=\"OnPlay\('(.*)', ", rand)
        try : 
          canale[lista.group(2)] = lista.group(1)
        except : pass
        lista = re.search("title=\"(.*)\" onclick=\"OnPlay\('(.*)', ", rand)
        try : 
          canale[lista.group(2)] = lista.group(1)
        except : pass
    if not canale : alert("Nu am putut extrage o lista de canale de pe sports-tv", error = True)
    else : 
       import sqlite3
       from os.path import expanduser
       home = expanduser("~")
       home += '/.pySopCast/pySopCast.db'
       conn = sqlite3.connect(home)
       cursor = conn.cursor()
       for addr in sorted(canale, key=canale.get) :
           cursor.execute("DELETE from bookmarks where channel_url=\"%s\";" % (addr))
           cursor.execute("INSERT INTO bookmarks(channel_url ,channel_name) VALUES(\"%s\",\"%s\");" % (addr, canale[addr]))
       conn.commit()
       cursor.close() 
       conn.close()
except Exception as problem :
    alert("Erroare la procesarea listei de programe:\n%s" % str(problem), error = True)
EOF

}


echo "Instalez dependentele din Ubuntu, introdu parola ca sa execut sudo"
installAPT
zenity --info --text " Downloadez sopcast streamer si player de pe net "
installSOP
zenity --info --text " Am instalat in /usr/bin sopcast-player si sp-sc-auth"
installRomani
zenity --info --text " Am instalat o lista de canale romanesti in Bookmarks.\n Pentru vizionare ruleza sopcast-player.\n Distractie placuta!"
