var fs = require('fs');
var URL = require('url');
var request = require('request');
var cheerio = require('cheerio');
var Transmission = require('transmission');
var transmission = new Transmission();
var count=0;
var url = 'https://beta.animepahe.com/devrequest';
// https://www.nyaa.se/?page=view&tid=607865
// https://bakabt.me/torrent/148508/07-ghost-720p-hatsuyuki

// Gets the torrent file
function getTorrentFile(url, cb) {
    url = URL.parse(url, true);
    
    switch (url.hostname) {
        case 'www.nyaa.se':
            getNyaa();
            break;
        case 'bakabt.me':
            getBakabt();
            break;
        default:
            return cb(new Error('invalid torrent url: ' + url));
    }
    function getBakabt() {
        request(url.href, function(err, response, body) {
            if (err) return cb(err);
            var $ = cheerio.load(body);
            return cb(null, 'https://bakabt.me/' + $('.download_link').attr('href'));
        });
    }
    function getNyaa() {
        return cb(null, 'https://www.nyaa.se/?page=download&tid=' + url.query.tid);
    }
}

// get the torrents to download
function getTorrentsToDL(cb) {
    request(url, function(err, response, body) {
        if (err) return cb(err);
        if (response.statusCode != '200')
            return cb(new Error('torrent unable download url: ' + url + ' returned status code: ' + response.statusCode));
        return cb(null, JSON.parse(body));
    });
}

getTorrentsToDL(function(err, torrents) {
    if (err) throw err;
    torrents.forEach(function(torrent) {
		//console.log(torrent);
		if(torrent.id) {
			count++;
			//console.log('MAL: ' + torrent.id + ' Title: ' + torrent.title);
			//split links by line
			var torarray = torrent.url.split("\r\n");
			//foreach link
			var index;
			for (index = 0; index < torarray.length; ++index) {
				//console.log(torarray[index]);
				getTorrentFile(torarray[index], function(err, torrentFileUrl) {
					var urlt = torrentFileUrl;
					console.log('id: ' + torrent.id + ' title: ' + torrent.title + ' fansub: ' + torrent.fansub + ' audio: ' + torrent.audio + ' sub: ' + torrent.sub + ' url: ' + urlt);
					transmission.addUrl(torrentFileUrl, {"download-dir": "/var/www/sort"}, function(err, arg) {
						if (err) {throw err;process.exit(1);}
						fs.appendFile('/var/www/downloading.txt', '/var/www/sort/'+arg.name + ':' + torrent.title + ':' + torrent.fansub + ':' + torrent.audio + ':' + torrent.sub + ':' + torrent.id + '\n', function(err) {
							if (err) {throw err;process.exit(1);}
						});
					});
				});
			}
		}
	});
    if(count==0){
		process.stdout.write("oyasumi\n");
	}else{
		process.stdout.write("\n");
	}
});
