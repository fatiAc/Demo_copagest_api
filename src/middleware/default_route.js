'use strict';

const {WsResponse} = require('../app/helpers/ws-response/ws.response');
const {HttpStatus} = require('../app/helpers/http-status/http-status.enum');

/**
 * @description Default route if route not found
 * @param req
 * @param res
 */
module.exports = (req, res) => {
    //res.status(HttpStatus.NOT_FOUND).json(makeResponse(404, "route introuvable, veuillez contacter le support"));
    res.status(HttpStatus.NOT_FOUND).json(new WsResponse(HttpStatus.NOT_FOUND, 'Path invalid !'));
};

