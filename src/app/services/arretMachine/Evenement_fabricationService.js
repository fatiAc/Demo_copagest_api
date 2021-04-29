const {Evenement_fabrication} = require('../../entities/arretMachine/index');
const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');

module.exports = {
    create: (Evenement_fabricationObjet) => {
        return Evenement_fabrication
            .create(Evenement_fabricationObjet)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    update: (Evenement_fabricationObjet) => {
        return Evenement_fabrication
            .update(Evenement_fabricationObjet, {where: {ID_EVENEMENT: Evenement_fabricationObjet.ID_EVENEMENT}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    delete: (Evenement_fabricationObjet) => {
        return Evenement_fabrication
            .destroy({where: Evenement_fabricationObjet})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAll: () => {
        return Evenement_fabrication
            .findAll({order: ['LIBELLE']})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },
}
