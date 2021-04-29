let router = require('express').Router();
let evenement_machineService = require('../../services/arretMachine/Evenement_machineService');

router.get('/findAll', function (req, res) {
    evenement_machineService
        .findAll()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/create', function (req, res) {
    evenement_machineService
        .create(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});


router.put('/update', function (req, res) {
    evenement_machineService
        .delete(req.body[0].ID_MACHINE)
        .then((response) => {
            evenement_machineService.bulkCreate(req.body)
                .then((responseCreate) => {
                    res.status(response.statusCode).json(responseCreate);
                }).catch((error) => {
                res.status(error.statusCode).json(error);
            });
        }).catch((error) => {
        res.status(error.statusCode).json(error);
    });
});

router.post('/delete', function (req, res) {
    evenement_machineService
        .delete(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/bulkCreate', function (req, res) {
    evenement_machineService
        .bulkCreate(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.get('/findAllMachineFabricationSteps', function (req, res) {
    evenement_machineService
        .findAllMachineFabricationSteps()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

module.exports = router;
