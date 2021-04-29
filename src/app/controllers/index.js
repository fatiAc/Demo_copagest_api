'use strict';

let router = require('express').Router();

router.use('/auth', require('./auth/auth.controller'));
router.use('/arretMachine', require('./arretMachine'));

module.exports = router;
