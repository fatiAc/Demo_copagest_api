'use strict';

let seq = require('sequelize');
let {ENV_DB} = require('./env');

seq.DATE.prototype._stringify = function _stringify(date, options) {
    return this._applyTimezone(date, options).format('YYYY-MM-DD HH:mm:ss.SSS');
};

/**
 * @description Defiction connection entity in database
 * @param name (name of database in file json)
 * @return sequelize connection database
 */
module.exports = (name = 'default') => {
    let db = ENV_DB(name);
    let seqCnx = new seq(
        db.database,
        db.username,
        db.password,
        {
            host: db.host,
            dialect: db.dialect,
            logging: console.log,
            define: {
                timestamps: db.timestamps
            },
            timezone: '+01:00'
        }
    );

    seqCnx.authenticate()
        .then(() => {
            //console.log(`Connection sucessfully to database : ${db.database}`);
        }).catch((err) => {
        console.log(`Connection failed to database : ${db.database}`, err);
    });

    return seqCnx;
};
