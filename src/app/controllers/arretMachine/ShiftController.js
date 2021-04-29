let router = require('express').Router();
let shiftService = require('../../services/arretMachine/ShiftService');

router.get('/findAll', function (req, res) {
    shiftService
        .findAll()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/create', function (req, res) {
    shiftService
        .create(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.put('/update', function (req, res) {
    shiftService
        .update(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/delete', function (req, res) {
    shiftService
        .delete(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

module.exports = router;
