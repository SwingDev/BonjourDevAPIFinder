var port = process.env.PORT || 8080;
var advertisedName = (process.env.BONJOUR_ADV_NAME || "example").substring(0,15).toLowerCase();  // Bonjour requirement

var mdns = require("mdns");
var ad = mdns.createAdvertisement(mdns.tcp(advertisedName), port);
ad.start();

var http = require('http');

http.createServer(function (request, response) {
    response.writeHead(200, {
        'Content-Type': 'text/plain',
        'Access-Control-Allow-Origin' : '*'
    });
    response.end('Hello World\n');
}).listen(port);
