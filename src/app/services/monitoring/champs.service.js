const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');
let {ChampEntity, RubriqueEntity} = require("../../entities/monitoring");
/* {include: [{model: RubriqueEntity}]} */

module.exports = {

    /**
     * @description retourner la list de champs
     * @returns Promise
     */
    findAll: () => {
        return ChampEntity
            .findAll()
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    /**
     * @description retourner list de champs par module
     * @param idModule integer
     * @returns Promise
     */
    findByModule: (idModule) => {
        return ChampEntity
            .findAll({where: {ID_MODULE: idModule}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    /**
     * @description retourner un champ par id
     * @param id integer
     * @returns Promise
     */
    findById: (id) => {
        return ChampEntity
            .findByPk(id, {include: [{model: RubriqueEntity}]})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    /**
     * @description ajouter un champ
     * @param champObject
     * @returns Promise
     */
    create: (champObject) => {
        return ChampEntity
            .create(champObject)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    /**
     * @description modifier le champ donnée
     * @param champObject
     * @returns Promise
     */
    update: (champObject) => {
        return ChampEntity
            .update(champObject, {where: {ID_CHAMP: champObject.ID_CHAMP}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    /**
     * @description supprimer un champ
     * @param idChamp
     * @returns Promise
     */
    delete: (idChamp) => {
        return ChampEntity
            .destroy({where: {ID_CHAMP: idChamp}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },
};
