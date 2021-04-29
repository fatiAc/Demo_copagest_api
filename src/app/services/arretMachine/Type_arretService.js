const {Type_arret} = require('../../entities/arretMachine/index');
const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');

module.exports = {
    create: (Type_arretObjet) => {
        return Type_arret
            .create(Type_arretObjet)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    update: (Type_arretObjet) => {
        return Type_arret
            .update(Type_arretObjet, {where: {ID_TYPE_ARRET: Type_arretObjet.ID_TYPE_ARRET}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    delete: (Type_arretObjet) => {
        return Type_arret
            .destroy({where: Type_arretObjet})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAll: () => {
        return Type_arret
            .findAll({order: ['LIBELLE']})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },
};
