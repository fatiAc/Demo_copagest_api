let activeDirectory = require('activedirectory2');
let jwt = require('jsonwebtoken');
let {ENV_APP} = require('../../../../env/env');
let _env = ENV_APP('ws');
let _envLdap = ENV_APP('ldap');
const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');
let dbintegrale = require("../../../../env/entitiy_connection")('dbintegrale');

let usersService = require('../monitoring/utilisateur.service');

const {SessionApplicatifEntity} = require("../../entities/monitoring");

// Function to generate token jwt
function generateJwt(user) {
    return jwt.sign(user, _env.jwt_secret, {expiresIn: _env.expiresIn});
}

// Export method
module.exports = {

    isHasAccess: async (userID, champID, rubriqID) => {
        return dbintegrale.query(` SELECT * FROM A_UTILISATEUR_MODULE userModule
                                    LEFT OUTER JOIN A_RUBRIQUE rubriq ON rubriq.ID_MODULE = userModule.ID_MODULE
                                    LEFT OUTER JOIN A_CHAMP_RUBRIQUE champRubriq ON champRubriq.ID_RUBRIQUE = rubriq.ID_RUBRIQUE
                                      WHERE ID_UTILISATEUR = ${userID} AND champRubriq.ID_CHAMP = ${champID} AND champRubriq.ID_RUBRIQUE = ${rubriqID}`, {type: dbintegrale.QueryTypes.SELECT}).then(data => {
            return new WsResponse(HttpStatus.OK, 'Opération succés', data.length > 0);
        }).catch((err) => {
            throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
        });
    },

    // JWT authentication with jsonwebtoken
    authJWT: async (user) => {
        if (!user || !user.pseudo || !user.password) {
            throw new WsResponse(HttpStatus.BAD_REQUEST, 'Identifiant invalide !');
        }

        let typemodule = 2;
        if (user.mobile === 1) {
            typemodule = 1
        }
        return await usersService
            .findUserWithRoles(user.pseudo, 1, typemodule)
            .then(({data}) => {
                if (user.password !== data.MPASSE)
                    return new WsResponse(HttpStatus.UNAUTHORIZED, 'Mot de passe incorrect !');
                else if (data.roles.length === 0)
                    return new WsResponse(HttpStatus.UNAUTHORIZED, ` Vous n'avez pas l'autorisation d'accéder à ce lien veuillez contactez votre administrateur !`);
                else {
                    return new WsResponse(HttpStatus.OK, 'Opération succés', {
                        accessToken: generateJwt({
                            ID_UTILISATEUR: data.ID_UTILISATEUR,
                            MATRICULE: data.MATRICULE,
                            ID_SITE: data.ID_SITE,
                            NOM: data.NOM,
                            ID_PROFIL: data.ID_PROFIL,
                            SITE: data.SITE,
                            roles: data.roles,
                            ID_SESSION_APPLICATIF: data.ID_SESSION_APPLICATIF
                        })
                    });
                }
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    getcurrversion: async (idprojet) => {
        return dbintegrale
            .query('SELECT VERSION_ACTUELLE FROM A_PROJET WHERE ID_PROJET = ' + idprojet,
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    checkForLastOpenedSessions: async (matricule) => {
        return await usersService.getOpenedSessions(matricule)
            .then(({data}) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            })
    },

    checkSessionByAppSessionId: async (idSessionApp) => {
        return SessionApplicatifEntity.findOne({where: {ID_SESSION_APPLICATIF: idSessionApp}}).then((sessionApp) => {
            if (sessionApp) {
                return new WsResponse(HttpStatus.OK, 'Session User', sessionApp.DATE_FERMETURE_SESSION);
            } else {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, 'Utilisateur n\'existe pas sur la base de données !!', null);
            }
        }).catch((err) => {
            throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
        })
    },

    logout: async (iduser) => {
        return await usersService.closeLastSession(iduser)
            .then(() => {
                return new WsResponse(HttpStatus.OK, 'Session fermer avec succée', null);
            })
    },

    logoutByIdSession: async (iduser, idSessionApp) => {
        return await usersService.closeSessionByID(iduser, idSessionApp)
            .then(() => {
                return new WsResponse(HttpStatus.OK, 'Session fermer avec succée', null);
            })
    },

    // LDAP authentication with Windows Server
    authLDAP: async (user) => {

        if (!user || !user.pseudo || !user.password) {
            throw new WsResponse(HttpStatus.BAD_REQUEST, 'Identifiant invalide !');
        }

        let ad = await new activeDirectory({url: `ldap://${_envLdap.host}:${_envLdap.port}`, baseDN: _envLdap.baseDN});
        let session = `${user.pseudo}@${_envLdap.domaineExterne}`;

        return await usersService.findByEmail(session)
            .then((data) => {
                if (!data) {
                    throw new WsResponse(HttpStatus.UNAUTHORIZED, 'Utilisateur introuvable !');
                }
                let sessionLdap = `${user.pseudo}@${_envLdap.domaineLocal}`;
                return new Promise((resolve, reject) => {
                    ad.authenticate(sessionLdap, user.password, (err, auth) => {
                        if (auth)
                            resolve(auth);
                        else
                            reject(err);
                    })
                }).then((data) => {
                    return new WsResponse(HttpStatus.OK, 'Opération succés', generateJwt({
                        id: data.IdUserModule,
                        idtiers: data.IdTiers,
                        pseudo: data.Mtr,
                        username: '',
                        password: user.password
                    }));
                }).catch((err) => {
                    return new WsResponse(HttpStatus.UNAUTHORIZED, 'Utilisateur ou Mot de passe invalide !', err);
                });
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

};
