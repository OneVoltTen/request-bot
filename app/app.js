var fs = require('fs');
var URL = require('url');
var request = require('request');
var cheerio = require('cheerio');
var Transmission = require('transmission');
var transmission = new Transmission();
var count=0;
var appdir = "";
var url = 'https://animepahe.com/request0.php';
// var url = 'https://beta.animepahe.com/devrequest/0';
// https://www.nyaa.se/?page=view&tid=607865
// https://bakabt.me/torrent/148508/07-ghost-720p-hatsuyuki

fs.readFile('/root/app/appdir.txt', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  var appdir = data;
  appdir.replace(/\s/g,''); //remove whitespace
  console.log('['+appdir+']');

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
				console.log(url.href);
				return cb(null, url.href);
				//return cb(new Error('invalid torrent url: ' + url));
				break;
	    }
	    function getBakabt() {
		request(url.href, function(err, response, body) {
		    if (err) return cb(err);
		    var $ = cheerio.load(body);
		    return cb(null, 'https://bakabt.me/' + $('.download_link').attr('href'));
		});
	    }
	    function getNyaa() {
			if (url.href.indexOf("page=download") == -1){8
				return cb(null, 'https://www.nyaa.se/?page=download&tid=' + url.query.tid);
			}else{
				return cb(null, url.href);
			}
	    }
	}

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
			if(torrent.id && torrent.hidden==0) {
				count++;
				//console.log('MAL: ' + torrent.id + ' Title: ' + torrent.title);
				var torarray = torrent.url.split("\r\n");
				var index;
				for (index = 0; index < torarray.length; ++index) {
					if(torarray[index]) {
						//console.log(torarray[index]);
						getTorrentFile(torarray[index], function(err, torrentFileUrl) {
							var urlt = torrentFileUrl;
							console.log('id: ' + torrent.id + ' title: ' + torrent.title + ' fansub: ' + torrent.fansub + ' audio: ' + torrent.audio + ' sub: ' + torrent.sub + ' url: ' + urlt);
							transmission.addUrl(torrentFileUrl, {"download-dir": appdir+'/sort'}, function(err, arg) {
								if (err) {throw err;process.exit(1);}
								fs.appendFile('/root/log/torrent.log', appdir+'/sort/'+arg.name + ':' + torrent.title + ':' + torrent.fansub + ':' + torrent.audio + ':' + torrent.sub + ':' + torrent.id + '\n', function(err) {
									if (err) {console.log("error!");throw err;process.exit(1);}
								});
							});
						});
					}
				}
			}
		});
		process.stdout.write(count + " request(s) found\n");
	});

});
