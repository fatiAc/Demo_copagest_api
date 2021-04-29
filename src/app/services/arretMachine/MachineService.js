const {Machine, dbintegrale} = require('../../entities/arretMachine/index');
const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');
const Queries = require('../../helpers/queryinng/arretMachine/queries.js');

module.exports = {
    create: (MachineObjet) => {
        return Machine
            .create(MachineObjet)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    update: (MachineObjet) => {
        return Machine
            .update(MachineObjet, {where: {ID: MachineObjet.ID}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    delete: (MachineObjet) => {
        return Machine
            .destroy({where: MachineObjet})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAll: () => {
        return Machine
            .findAll({where: {ACTIF: 1}, attributes: ['ID_MACHINE', 'LIBELLE'], order: ['LIBELLE']})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findMachineOfPilote: (piloteID) => {
        return dbintegrale
            .query(Queries.findMachinesOfSelectedPilote(piloteID),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    }
};
