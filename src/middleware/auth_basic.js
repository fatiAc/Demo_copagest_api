'use strict';

const {WsResponse} = require('../app/helpers/ws-response/ws.response');
const {HttpStatus} = require('../app/helpers/http-status/http-status.enum');
let basicAuth_ = require('basic-auth');
let env = require('../../env/env').ENV_APP('ws');

/**
 * @description Verification auth basic
 * @param req
 * @param res
 * @param next
 */
module.exports = (req, res, next) => {
    let user = basicAuth_(req);
    let invalidAuthResponse = new WsResponse(HttpStatus.UNAUTHORIZED, 'Accès refusé, données de session invalid !');
    if (!user || !user.name || !user.pass)
        //res.set('WWW-Authenticate', 'Basic realm=Authorization Required');
        //res.sendStatus(401);
        //res.json(failed('Authentification erronée [Authorization Basic Required] !'));
        invalidAuthResponse = new WsResponse(HttpStatus.UNAUTHORIZED, 'Authentification erronée [Authorization Basic Required] ! !');
    else if (user.name === env.username && user.pass === env.password)
        next();
    else
        //res.set('WWW-Authenticate', 'Basic realm=Authorization Required');
        //res.sendStatus(401);
        //res.json(failed('Authentification erronée [Authorization Basic incorrect] !'));
        invalidAuthResponse = new WsResponse(HttpStatus.UNAUTHORIZED, 'Authentification erronée [Authorization Basic incorrect] !');

    return res.status(invalidAuthResponse.statusCode).json(invalidTokenResponse);


};
