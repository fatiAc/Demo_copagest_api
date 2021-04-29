'use strict';

let fs = require('fs');

let NODE_ENV = process.env.MODE_ENV; // dev | test | prod
let ENV_APP = (name) => { return getObjet(name) };
let ENV_DB = (name='default') => { return getObjet('db')[name] };

/**
 * @description Get Info Database Connection from file env.json
 * @param name
 * @return {*}
 */
function getObjet(name) {
    let content = JSON.parse(fs.readFileSync("./env/env.json"));
    return content[NODE_ENV][name];
};

/**
 * @description Export env
 * @type {{ENV_DB: (function(*=): *), NODE_ENV: string, ENV_APP: (function(*=): *)}}
 */
module.exports = {
    NODE_ENV,
    ENV_APP,
    ENV_DB
};
