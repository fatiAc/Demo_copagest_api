const {Evenement_machine, dbintegrale} = require('../../entities/arretMachine/index');
const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');
const Queries = require("../../helpers/queryinng/arretMachine/queries");

module.exports = {
    create: (Evenement_machineObjet) => {
        return Evenement_machine
            .create(Evenement_machineObjet)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    update: (Evenement_machineObjet) => {
        return Evenement_machine
            .update(Evenement_machineObjet, {where: {ID: Evenement_machineObjet.ID}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    delete: (Evenement_machineObjet) => {
        return Evenement_machine
            .destroy({where: {ID_MACHINE: Evenement_machineObjet.ID_MACHINE}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAll: () => {
        return Evenement_machine
            .findAll()
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },


    bulkCreate: (Evenement_machineList) => {
        return Evenement_machine
            .bulkCreate(Evenement_machineList)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAllMachineFabricationSteps() {
        return dbintegrale
            .query(Queries.findAllMachineFabricationSteps(),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                let myJson = data.reduce(function (result, current) {  // order my json by ID_MACHINE
                    result[current.ID_MACHINE] = result[current.ID_MACHINE] || [];
                    result[current.ID_MACHINE].push(current);
                    return result;
                }, {});
                let result = [];
                let myEvents = null;
                for (let key in myJson) {
                    myEvents = []
                    for (let item of myJson[key]) {
                        myEvents.push({
                            ID_EVENEMENT: item.ID_EVENEMENT_FABRICATION,
                            LIBELLE: item.eventFabricLibelle,
                            CODE_COULEUR: "#" + item.CODE_COULEUR
                        });
                    }
                    result.push({
                        ID_MACHINE: Number(key),
                        LIBELLE: data.find(element => element.ID_MACHINE == key).machineLibelle,
                        events: myEvents
                    })
                }
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length}`, result);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

};
