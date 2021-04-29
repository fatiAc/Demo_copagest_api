let router = require('express').Router();
let evenement_fabricationService = require('../../services/arretMachine/Evenement_fabricationService');

router.get('/findAll', function (req, res) {
    evenement_fabricationService
        .findAll()
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/create', function (req, res) {
    evenement_fabricationService
        .create(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
})

router.put('/update', function (req, res) {
    evenement_fabricationService
        .update(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

router.post('/delete', function (req, res) {
    evenement_fabricationService
        .delete(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        });
});

module.exports = router;
