'use strict';

const {HttpStatus} = require('../http-status/http-status.enum');

exports.WsResponse  = class WsResponse {
    constructor(statusCode = HttpStatus.OK, message= '', data = null) {
        this.statusCode = statusCode;
        this.message = message;
        this.data = data;
    }

    get getStatusCode() {
        return this._statusCode;
    }

    set setStatusCode(value) {
        this._statusCode = value;
    }

    get getMessage() {
        return this._message;
    }

    set setMessage(value) {
        this._message = value;
    }

    get getData() {
        return this._data;
    }

    set setData(value) {
        this._data = value;
    }

    static successfully(data, message = 'Opération succés', statusCode = HttpStatus.HttpStatus.OK) {
        return {
            statusCode: statusCode,
            message: message,
            data: data,
        };
    }
};
