var dgram = require("dgram");
var server1 = dgram.createSocket("udp4");

const os = require('os');

server1.on("error", function (err) {
  console.log("server error:\n" + err.stack);
  server1.close();
});

server1.on("message", function (msg, rinfo) {
  console.log("server got: " + msg + " from " +
    rinfo.address + ":" + rinfo.port);
    if(msg == 'Sight++'){
        server1.send("approve", rinfo.port, rinfo.address);
    }

});

server1.on("listening", function () {
  var address = server1.address();
  console.log("server listening " +
      address.address + ":" + address.port);
});

server1.bind(9999);