const express = require('express');
const app = express();
const fs = require("fs");
const bodyParser = require('body-parser');
const time = require('silly-datetime')

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.get('/testGet', function (req, res) {
   fs.readFile( __dirname + "/" + "users.json", 'utf8', function (err, data) {
      console.log( data );
      res.end( data );
   });
})

app.post('/testPost', function(req, res){
    console.log(req.body);
    res.end(time.format(new Date(), 'HH:mm'))
})

var server = app.listen(9999, function () {
   var host = server.address().address
   var port = server.address().port
   console.log("Example app listening at http://"+host+":"+port)
})