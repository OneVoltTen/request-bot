sudo apt-get update
sudo apt-get upgrade
sudo apt-get install transmission-daemon libx264-dev php-curl npm nodejs-legacy autoconf automake build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev yasm cmake mercurial libmp3lame-dev libopus-dev php7.0-cli php7.0-common mysql-client mediainfo mkvtoolnix php5-curl;

npm install request cheerio
npm install jasmine-node --save-dev

ls -al /var/www/

npm i

mkdir ~/ffmpeg_sources

sudo apt-get install yasm
sudo apt-get install libx264-dev

sudo apt-get install cmake mercurial
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install
make distclean

sudo apt-get install libfdk-aac-dev
sudo apt-get install libmp3lame-dev
sudo apt-get install libopus-dev

cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build"   --pkg-config-flags="--static"   --extra-cflags="-I$HOME/ffmpeg_build/include"   --extra-ldflags="-L$HOME/ffmpeg_build/lib"   --bindir="$HOME/bin"   --enable-gpl --enable-libfdk-aac --enable-libmp3lame   --enable-libopus --enable-libvorbis   --enable-libvpx   --enable-libx264   --enable-libx265   --enable-nonfree
PATH="$HOME/bin:$PATH" make
make install
make distclean
hash -r

clear
ffmpeg

#move * in bin folder to /usr/bin/ ...
echo "Move '/root/bin' files to /usr/bin/"

sudo chown yubikiri:yubikiri /var/www/*

sudo mkdir /var/www
sudo mkdir /var/www/downloads
sudo mkdir /var/www/downloads/.queue
sudo mkdir /var/www/downloads/.00
sudo mkdir /var/www/encoded
sudo mkdir /var/www/incomplete
sudo mkdir /var/www/komaru
sudo mkdir /var/www/logs
sudo mkdir /var/www/sort
sudo mkdir /var/www/trash
sudo mkdir /var/www/logs
sudo mkdir /var/www/uploaded
#wget https://www.link/files.zip -O temp.zip; unzip temp.zip; rm temp.zip
#To finish...

# bot.sh every 10 minutes
# retrieve.sh every 5 minutes
