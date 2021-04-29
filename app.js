'use strict';

let app = require('express')();
let bodyParser = require('body-parser');
let dotenv = require('dotenv').config();
let fs = require('fs');
let expressEndPts = require('express-list-endpoints');
let {ENV_APP} = require('./env/env');
let _env = ENV_APP('ws');
let cors = require('cors');
// Option of Server Https
let optionsHttps = {
    key: fs.readFileSync('./env/certificate/localhost.key'),
    cert: fs.readFileSync('./env/certificate/localhost.cert'),
    requestCert: false,
    rejectUnauthorized: false
};

// Create instance Server Http and Https
let http = require('http').createServer(app);
let https = require('https').createServer(optionsHttps, app);

// Init Middleware in App
let {CrossOrigin, DefaultRoute} = require('./src/middleware');


// Init Body Parser
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
// Init All Route in App
app.use('/api', CrossOrigin, require('./src/app/controllers'));
app.use(DefaultRoute);
app.use(cors());

// Run Server Http
http.listen(_env.porthttp, (err) => {
    if (err)
        console.log('app not running with http. error: %s', err);
    else
        console.log('app running with http in http://%s:%s', _env.host, _env.porthttp);
});

// Run Server Https
https.listen(_env.porthttps, (err) => {
    if (err)
        console.log('app not running with https. error: %s', err);
    else
        console.log('app running with http in https://%s:%s', _env.host, _env.porthttps);
});

// Show All Routes
//console.log(expressEndPts(app));




