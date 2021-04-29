'use strict';

let authBasic = require('./auth_basic');
let authJWT = require('./auth_jwt');
let CrossOrigin = require('./cross_origin');
let DefaultRoute = require('./default_route');

/**
 * @description Export all midlleware
 * @type {{CrossOrigin: (function(*, *, *): *), authBasic: (function(*=, *, *): void), DefaultRoute: (function(*, *): void), authJWT: (function(*, *, *): (Json|any|Promise<any>))}}
 */
module.exports = {
    authBasic,
    authJWT,
    CrossOrigin,
    DefaultRoute,
    dta: {}
};
