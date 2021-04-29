'use strict';

/**
 * @description Autorization gross origin for all
 * @param req
 * @param res
 * @param next
 * @returns {*}
 */
module.exports = (req, res, next) => {
    /*   if (req.method == 'OPTIONS') {
           console.log('======================  ************** ', req.method)
           res.header("Access-Control-Allow-Origin", "*");
           res.header('Access-Control-Allow-Methods', 'DELETE, PUT, GET, POST, OPTIONS');
           res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, x-access-token , authorization");
           next();
       } else {
           res.header("Access-Control-Allow-Origin", "*");
           res.header('Access-Control-Allow-Methods', 'DELETE, PUT, GET, POST, OPTIONS');
           res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, x-access-token, authorization");
           next();
       }*/
    res.header("Access-Control-Allow-Origin", "*");
    res.header('Access-Control-Allow-Credentials', true);
    res.header("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, responseType, observe,  x-access-token, authorization");
    next();

};
