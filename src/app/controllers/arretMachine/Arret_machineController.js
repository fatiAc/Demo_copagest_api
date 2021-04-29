let router = require('express').Router();
let arret_machineService = require('../../services/arretMachine/Arret_machineService');

router.get('/findAll', function (req, res) {
    arret_machineService
        .findAll()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/create', function (req, res) {
    arret_machineService
        .create(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.put('/update', function (req, res) {
    arret_machineService
        .update(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/delete', function (req, res) {
    arret_machineService
        .delete(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findArretMachineByCritaria/:machineID/:piloteID/:shiftID/:month', function (req, res) {
    arret_machineService
        .findArretMachineByCritaria(req.params.machineID, req.params.piloteID, req.params.shiftID, req.params.month)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findArretMachineOfConnectedPilote/:connectedPiloteID', function (req, res) {
    arret_machineService
        .findArretMachineOfConnectedPilote(req.params.connectedPiloteID)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

module.exports = router;
