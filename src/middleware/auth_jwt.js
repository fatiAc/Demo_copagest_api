'use strict';
const {WsResponse} = require('../app/helpers/ws-response/ws.response');
const {HttpStatus} = require('../app/helpers/http-status/http-status.enum');
let jwtToken = require('jsonwebtoken');
let env = require('../../env/env').ENV_APP('ws');

/**
 * @description Verification auth jwt token
 * @param req
 * @param res
 * @param next
 * @returns {Json | any | Promise<any>}
 */
module.exports = (req, res, next) => {
    let token = req.body.token || req.query.token || req.headers['x-access-token'] || req.headers['authorization'];
    if (token && token.startsWith('Bearer ')) {
        // Remove Bearer from string
        token = token.slice(7, token.length);
    }
    if (token) {
        // Verify jwt token
        jwtToken.verify(token, env.jwt_secret, (err, decoded) => {

            let invalidTokenResponse = new WsResponse(HttpStatus.UNAUTHORIZED, 'Accès refusé, données de session invalid !');

            invalidTokenResponse["invalidToken"] = true;

            if (err)
                return res.status(invalidTokenResponse.statusCode).json(invalidTokenResponse);
            //return res.json(failed(`invalid token erreur : ${err.toString()}`, 401));
            if (decoded.ID_UTILISATEUR !== undefined) {
                req.user = decoded;
                if (req.user == undefined || req.user == null) {
                    return res.status(invalidTokenResponse.statusCode).json(invalidTokenResponse);
                } else
                    return next();
            } else {
                return res.status(invalidTokenResponse.statusCode).json(invalidTokenResponse);
                //return res.json(failed('token decoded invalid', 401));
            }
        })
    } else {
        return res.status(HttpStatus.UNAUTHORIZED).json(new WsResponse(HttpStatus.UNAUTHORIZED, 'Accès refusé, vous devez être authentifié !'));
        //return res.status(HttpStatus.UNAUTHORIZED).json(makeResponse(401, 'Accès refusé, vous devez être authentifié !'));
        //return res.status(401).json('invalid token', 401);
    }
};
