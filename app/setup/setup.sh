# run script as superuser

mkdir /var/www
mkdir /var/www/downloads
mkdir /var/www/incomplete
mkdir /var/www/komaru
mkdir /var/www/queue
mkdir /var/www/sort
mkdir /var/www/trash
mkdir /var/www/upload
mkdir /var/www/uploaded
mkdir /var/www/verify
mkdir /root/log
mkdir /root/log/encode

pacman -S transmission-gtk nodejs php mediainfo mkvtoolnix-gui mysql patch autoconf automake yasm wget libx264 cmake mercurial libfdk-aac lame nasm opus --noconfirm

mkdir ~/ffmpeg_sources

cd ~/ffmpeg_sources
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
make distclean

cd ~/ffmpeg_sources
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjvf last_x264.tar.bz2
cd x264-snapshot*
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-opencl
PATH="$HOME/bin:$PATH" make
make install
make distclean

cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install
make distclean

cd ~/ffmpeg_sources
wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master
tar xzvf fdk-aac.tar.gz
cd mstorsjo-fdk-aac*
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean

cd ~/ffmpeg_sources
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared
make
make install
make distclean

cd ~/ffmpeg_sources
wget http://downloads.xiph.org/releases/opus/opus-1.1.2.tar.gz
tar xzvf opus-1.1.2.tar.gz
cd opus-1.1.2
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make clean

cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --pkg-config-flags="--static" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libx265 --enable-nonfree
PATH="$HOME/bin:$PATH" make
make install
make distclean
hash -r

cp /root/ffmpeg_build/bin/ffmpeg /usr/bin
cp /root/ffmpeg_build/bin/ffplay /usr/bin
cp /root/ffmpeg_build/bin/ffprobe /usr/bin
cp /root/ffmpeg_build/bin/ffserver /usr/bin
cp /root/ffmpeg_build/bin/lame /usr/bin
cp /root/ffmpeg_build/bin/vstasm /usr/bin
cp /root/ffmpeg_build/bin/x264 /usr/bin
cp /root/ffmpeg_build/bin/x265 /usr/bin
cp /root/ffmpeg_build/bin/yasm /usr/bin
cp /root/ffmpeg_build/bin/ytasn /usr/bin

systemctl enable httpd.service
systemctl enable mysqld.service

chattr +i '/root/.config/transmission-daemon/settings.json' # prevent modify
#chattr -i '/root/.config/transmission-daemon/settings.json' # allow modify

echo "Run command as non-root: yaourt -S perl-archive-zip-crc32 --noconfirm"
echo "Edit '/etc/php/php.ini', remove semicolon from ';extension=mysqli.so'"
echo "Schedule periodic execute /root/bot.sh"
