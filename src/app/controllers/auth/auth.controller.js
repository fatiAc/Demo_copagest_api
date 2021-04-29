'use strict';

const router = require('express').Router();
const authSerivce = require('../../services/auth/auth.service');
const {authJWT} = require('../../../middleware');

router.post('/userconnected', authJWT, (req, res) => {
    res.status(200).json(req.user);
});

// Authentification JWT
router.post('/jwt', (req, res) => {
    authSerivce
        .authJWT(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});

router.get('/logout/:idUser', authJWT, (req, res) => {
    authSerivce
        .logout(req.params.idUser)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});

router.put('/logoutOnClose', (req, res) => {
    authSerivce
        .logout(req.body.idUser)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});

router.get('/logoutByIdSession/:iduser/:idSessionApplicatif', (req, res) => {
    authSerivce
        .logoutByIdSession(req.params.iduser, req.params.idSessionApplicatif)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});

router.get('/checkOpenedSessions/:matricule', (req, res) => {
    authSerivce
        .checkForLastOpenedSessions(req.params.matricule)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});

router.get('/checkSessionByAppSessionId/:idSessionApplicatif', (req, res) => {
    authSerivce
        .checkSessionByAppSessionId(req.params.idSessionApplicatif)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});

router.get('/getcurrversion/:idProjet', (req, res) => {
    authSerivce
        .getcurrversion(req.params.idProjet)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});

// Authentification LDPA
router.post('/ldap', (req, res) => {
    authSerivce
        .authLDAP(req.body)
        .then((response) => {
            res.status(response.statusCode).json(response);
        })
        .catch((error) => {
            res.status(error.statusCode).json(error);
        })
});


module.exports = router;
