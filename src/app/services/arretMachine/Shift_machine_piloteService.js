const {Shift_machine_pilote, dbintegrale} = require('../../entities/arretMachine/index');
const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');
let Queries = require("../../helpers/queryinng/arretMachine/queries");

module.exports = {
    create: (Shift_machine_piloteObjet) => {
        return Shift_machine_pilote
            .create(Shift_machine_piloteObjet)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    update: (Shift_machine_piloteObjet) => {
        return Shift_machine_pilote
            .update(Shift_machine_piloteObjet, {where: {ID: Shift_machine_piloteObjet.ID}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    delete: (Shift_machine_piloteObjet) => {
        return Shift_machine_pilote
            .destroy({where: Shift_machine_piloteObjet})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAll: () => {
        return Shift_machine_pilote
            .findAll()
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAllPilotes() {
        return dbintegrale
            .query(Queries.findAllPilotes(),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAllShiftMachinePilot() {
        return dbintegrale
            .query(Queries.findAllShiftMachinePilot(),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findShiftMachinePilotOfConnectedPilote(connectedPiloteID) {
        return dbintegrale
            .query(Queries.findShiftMachinePilotOfConnectedPilote(connectedPiloteID),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findPilotesMutualMachines(piloteID) {
        return dbintegrale
            .query(Queries.findPilotesMutualMachines(piloteID),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findPiloteByMachineAndShift(machineID, shiftID) {
        return dbintegrale
            .query(Queries.findPiloteByMachineAndShift(machineID, shiftID),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    getCurrentshiftAndMachineByPilote(idPilote){
        return dbintegrale
            .query(Queries.getCurrentshiftAndMachineByPilote(idPilote),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    }
}
