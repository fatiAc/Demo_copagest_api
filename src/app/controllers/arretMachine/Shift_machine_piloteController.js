let router = require('express').Router();
let shift_machine_piloteService = require('../../services/arretMachine/Shift_machine_piloteService');

router.get('/findAll', function (req, res) {
    shift_machine_piloteService
        .findAll()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/create', function (req, res) {
    shift_machine_piloteService
        .create(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.put('/update', function (req, res) {
    shift_machine_piloteService
        .update(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/delete', function (req, res) {
    shift_machine_piloteService
        .delete(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/getPilotes', function (req, res) {
    shift_machine_piloteService
        .findAllPilotes()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findAllShiftMachinePilot', function (req, res) {
    shift_machine_piloteService
        .findAllShiftMachinePilot()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findShiftMachinePilotOfConnectedPilote/:connectedPiloteID', function (req, res) {
    shift_machine_piloteService
        .findShiftMachinePilotOfConnectedPilote(Number(req.params.connectedPiloteID))
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findPilotesMutualMachines/:piloteID', function (req, res) {
    shift_machine_piloteService
        .findPilotesMutualMachines(Number(req.params.piloteID))
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findPiloteByMachineAndShift/:machineID/:shiftID', function (req, res) {
    shift_machine_piloteService
        .findPilotesMutualMachines(Number(req.params.machineID), Number(req.params.shiftID))
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/getCurrentshiftAndMachineByPilote/:idIpConnecte', function (req, res) {
    shift_machine_piloteService
        .getCurrentshiftAndMachineByPilote(Number(req.params.idIpConnecte))
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

module.exports = router;
