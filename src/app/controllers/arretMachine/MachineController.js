let router = require('express').Router();
let machineService = require('../../services/arretMachine/MachineService');

router.get('/findAll', function (req, res) {
    machineService
        .findAll()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/create', function (req, res) {
    machineService
        .create(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.put('/update', function (req, res) {
    machineService
        .update(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/delete', function (req, res) {
    machineService
        .delete(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findMachineOfPilote/:piloteID', function (req, res) {
    machineService
        .findMachineOfPilote(req.params.piloteID)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

module.exports = router;
