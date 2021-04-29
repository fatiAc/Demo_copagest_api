const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');
const {UserEntity, SessionApplicatifEntity, SiteEntity} = require("../../entities/monitoring");
const dbintegrale = require("../../../../env/entitiy_connection")('dbintegrale');
const Sequelize = require('sequelize');
const moment = require('moment');
let Queries = require("../../helpers/queryinng/monitoring/queries");

module.exports = {

    findUsersByMatricule: (matricule) => {
        return UserEntity.findOne({where: {MATRICULE: matricule, ACTIF: 1}}).then((users) => {
            if (users) {
                return new WsResponse(HttpStatus.OK, 'Utilisateurs by matricule', users);
            } else {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, 'Utilisateur n\'existe pas sur la base de données !!', null);
            }
        }).catch((err) => {
            throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
        })
    },

    findByID: (userID) => {
        return UserEntity.findOne({where: {ID_UTILISATEUR: userID}}).then((user) => {
            if (user) {
                return new WsResponse(HttpStatus.OK, 1, user);
            } else {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, 'Utilisateur introuvable ! ', null);
            }
        }).catch((err) => {
            throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
        })
    },

    /**
     * @description Get one user by matricule
     * @returns {Promise<Model[]> | Promise<Model[]>}
     * @param matricule
     * @param idProjet
     * @param idTypeModule
     */
    findUserWithRoles: (matricule, idProjet, idTypeModule) => {
        return dbintegrale.query(` SELECT userr.*, site.SITE FROM A_UTILISATEUR userr LEFT OUTER JOIN P_SITE site ON site.ID_SITE = userr.ID_SITE WHERE MATRICULE = ${matricule} AND ACTIF = 1 `, {type: dbintegrale.QueryTypes.SELECT})
            .then(async data => {
                if (data.length > 0) {
                    data = data[0];
                    let roles = [];
                    let rubriques = await dbintegrale.query(`
                UPDATE [A_SESSION_APPLICATIF] SET DATE_FERMETURE_SESSION = SYSDATETIME() WHERE [ID_UTILISATEUR] = ${data.ID_UTILISATEUR} AND DATE_FERMETURE_SESSION IS NULL;
                SELECT 
                    am.LIB_MODULE , am.ID_MODULE, ar.ID_RUBRIQUE, ar.LIB_RUBRIQUE, ar.TITRE AS TITLE, ar.INTERFACE AS ROUTE, AC.ID_CHAMP, AC.LIB_CHAMP, AC.ABRV_CHAMP, adp.ID_PROFIL, ar.ICON
                FROM 
                    A_DROIT_PROFIL adp  INNER JOIN A_CHAMP_RUBRIQUE acr ON acr.ID_AFFECT_RBCH = adp.ID_AFFECT_RBCH
                    INNER JOIN A_RUBRIQUE ar ON ar.ID_RUBRIQUE = acr.ID_RUBRIQUE INNER JOIN A_CHAMP ac ON ac.ID_CHAMP = acr.ID_CHAMP
                    INNER JOIN A_Module am ON am.ID_MODULE = ar.ID_MODULE
                WHERE 
                    ar.ACTIF_RB = 1 AND adp.ID_Profil IN (
                        SELECT  Distinct apf.Id_Profil 
                        FROM 
                            A_UTILISATEUR au INNER JOIN A_UTILISATEUR_MODULE aum ON aum.ID_UTILISATEUR = au.ID_UTILISATEUR
                            INNER JOIN A_MODULE am ON am.ID_MODULE = aum.ID_MODULE INNER JOIN A_PROJET ap ON ap.ID_PROJET = am.ID_PROJET
                            INNER JOIN A_PROFIL apf ON apf.ID_PROFIL = aum.ID_PROFIL
                        WHERE 
                            MATRICULE = ${matricule} AND ap.ID_PROJET = ${idProjet} AND aum.ACTIVE = 1 )
                and am.ID_TYPE_MODULE = ${idTypeModule} AND am.ID_PROJET = ${idProjet}
                     `,
                        {type: dbintegrale.QueryTypes.SELECT});

                    let sessionApplicatif = await SessionApplicatifEntity.create({
                        ID_UTILISATEUR: data.ID_UTILISATEUR,
                        DATE_OUVERTURE_SESSION: new Date(),
                        DATE_FERMETURE_SESSION: null,
                        ID_PROJET: idProjet
                    });
                    // filter and complete roles
                    for (let k = 0; k < rubriques.length; k++) {

                        let _module = {
                            id: rubriques[k].ID_MODULE,
                            libelle: rubriques[k].LIB_MODULE,
                            rubriques: [],
                        };

                        for (let i = 0; i < rubriques.length; i++) {
                            let rubrique = {
                                id: rubriques[i].ID_RUBRIQUE,
                                libelle: rubriques[i].LIB_RUBRIQUE,
                                title: rubriques[i].TITLE,
                                route: rubriques[i].ROUTE,
                                icone: rubriques[i].ICON,
                                champs: []
                            };

                            for (let j = 0; j < rubriques.length; j++) {

                                if (rubriques[j].ID_RUBRIQUE === rubrique.id) {
                                    rubrique.champs.push(rubriques[j].ABRV_CHAMP);
                                }
                            }
                            if (_module.id === rubriques[i].ID_MODULE && !_module.rubriques.some(r => r.id === rubrique.id)) {
                                _module.rubriques.push(rubrique);
                            }
                        }
                        if (roles.length === 0)
                            roles.push(_module);
                        else {
                            if (!roles.some(role => role.id === _module.id))
                                roles.push(_module);
                        }
                    }
                    data.roles = roles;
                    data.ID_PROFIL = rubriques.length > 0 ? rubriques[0].ID_PROFIL : null;
                    data.ID_SESSION_APPLICATIF = sessionApplicatif.ID_SESSION_APPLICATIF;
                    return new WsResponse(HttpStatus.OK, 'Opération succés', data);
                } else throw new WsResponse(500, 'Utilisateur introuvable !', data);
            })
            .catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    /**
     * @description close all opened user sessions
     * @param iduser
     * @returns {Promise<T>}
     */
    closeLastSession: (iduser) => {
        return dbintegrale.query(`UPDATE A_SESSION_APPLICATIF SET DATE_FERMETURE_SESSION = '${moment(new Date()).format('YYYY-MM-DDTHH:mm:ss')}' 
                           WHERE ID_SESSION_APPLICATIF IN (SELECT ID_SESSION_APPLICATIF from A_SESSION_APPLICATIF
                      INNER JOIN A_UTILISATEUR sessionUser ON sessionUser.ID_UTILISATEUR = A_SESSION_APPLICATIF.ID_UTILISATEUR
                      WHERE sessionUser.ID_UTILISATEUR = ${iduser} AND DATE_FERMETURE_SESSION IS NULL)`, {
            type: dbintegrale.QueryTypes.UPDATE
        })
            .then(() => {
                return new WsResponse(HttpStatus.OK, 'Session fermer avec succée', null);
            })
            .catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            })
    },

    closeSessionByID: (iduser, idSessionApp) => {
        return dbintegrale.query(`UPDATE A_SESSION_APPLICATIF SET DATE_FERMETURE_SESSION = '${moment(new Date()).format('YYYY-MM-DDTHH:mm:ss')}' 
                           WHERE ID_SESSION_APPLICATIF = ${idSessionApp} AND ID_UTILISATEUR = ${iduser}`, {
            type: dbintegrale.QueryTypes.UPDATE
        })
            .then(() => {
                return new WsResponse(HttpStatus.OK, 'Session fermer avec succée', null);
            })
            .catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            })
    },

    /**
     * @description get all opened user sessions
     * @returns {Promise<T>}
     * @param matricule
     */
    getOpenedSessions: (matricule) => {
        return dbintegrale.query(`SELECT A_SESSION_APPLICATIF.* from A_SESSION_APPLICATIF
                      INNER JOIN A_UTILISATEUR sessionUser ON sessionUser.ID_UTILISATEUR = A_SESSION_APPLICATIF.ID_UTILISATEUR
                      WHERE sessionUser.MATRICULE = ${matricule} AND DATE_FERMETURE_SESSION IS NULL`, {
            type: dbintegrale.QueryTypes.SELECT
        })
            .then(sessions => {
                return new WsResponse(HttpStatus.OK, 'Session fermer avec succée', sessions);
            })
            .catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            })
    },


    getUsersWithSite: (page, pagesize) => {
        return UserEntity.findAndCountAll({
            attributes: {include: [Sequelize.col('ST.SITE')]},
            where: {ACTIF: 1},
            include: [{model: SiteEntity, as: 'ST', required: true, attributes: []}],
            limit: pagesize,
            offset: page,
            raw: true
        })
            .then(users => {
                return new WsResponse(HttpStatus.OK, 'Utilisateurs demo data', users);
            })
            .catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            })
    },

    /**
     * @description supprimer un PROJET
     * @returns Promise
     */
    getGLPIUsers: () => {
        return UserEntity.findAll({where: {ACTIF: 1, ID_DERICTION: [125, 86]}}).then((users) => {
            if (users) {
                return new WsResponse(HttpStatus.OK, 'Utilisateurs GLPI DSI', users);
            } else {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, 'Utilisateur n\'existe pas sur la base de données !!', null);
            }
        }).catch((err) => {
            throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
        })
    },

    update: (oldEntity, newEntity) => {
        return UserEntity.update(newEntity, {where: oldEntity}).then((users) => {
            return new WsResponse(HttpStatus.OK, ' ', users);
        }).catch((err) => {
            throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
        })
    },

    findMagasinierAll: () => {
        return dbintegrale
            .query(Queries.getUsersMagasinier(),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAllUsers: () => {
        return dbintegrale
            .query(Queries.getAllUser(),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAllUsersBySite: (idsite) => {
        return dbintegrale
            .query(Queries.findAllUsersBySite(idsite),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    }
};
