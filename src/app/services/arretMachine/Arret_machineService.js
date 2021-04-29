const {Arret_machine, dbintegrale} = require('../../entities/arretMachine/index');
const {WsResponse} = require('../../helpers/ws-response/ws.response');
const {HttpStatus} = require('../../helpers/http-status/http-status.enum');
const Queries = require('../../helpers/queryinng/arretMachine/queries.js');
const dateUtile = require('../../helpers/dateUtile');

module.exports = {
    create: (Arret_machineObjet) => {
        return Arret_machine
            .create(Arret_machineObjet)
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    update: (Arret_machineObjet) => {
        return Arret_machine
            .update(Arret_machineObjet, {where: {ID: Arret_machineObjet.ID}})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    delete: (Arret_machineObjet) => {
        return Arret_machine
            .destroy({where: Arret_machineObjet})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, 'Opération succés', data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findAll: () => {
        return Arret_machine
            .findAll()
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findArretMachineByCritaria: (machineID, piloteID, shiftID, month) => {
        return dbintegrale
            .query(Queries.findArretMachineByCritaria(machineID, piloteID, shiftID, new Date().getMonth() + 1 - month),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                if (data.length > 0) {
                    let reducedData = data.reduce(function (result, current) {  // order my json by ID_MACHINE
                        result[current.typeArretLibelle] = result[current.typeArretLibelle] || [];
                        result[current.typeArretLibelle].push(current);
                        return result;
                    }, {}); // groupe by typeArret
                    let arretMachine = [];
                    for (let key in reducedData) {
                        let dateDuree = [];
                        for (let item of reducedData[key]) { // data of selected typeArret
                            dateDuree.push({DATE_ARRET: item.DATE_ARRET, DUREE_ARRET_MINUTE: item.DUREE_ARRET_MINUTE})
                        }
                        for (let item of dateDuree) { // eleminer la redondance
                            let sum = item.DUREE_ARRET_MINUTE;
                            for (let element of dateDuree) {
                                if (dateDuree.indexOf(element) != dateDuree.indexOf(item) && element.DATE_ARRET == item.DATE_ARRET) {
                                    sum = sum + element.DUREE_ARRET_MINUTE;
                                    dateDuree.splice(dateDuree.indexOf(element), 1)
                                }
                            }
                            if (sum > item.DUREE_ARRET_MINUTE) // if is changed
                                dateDuree[dateDuree.indexOf(item)] = {
                                    DATE_ARRET: item.DATE_ARRET,
                                    DUREE_ARRET_MINUTE: sum
                                };
                        }
                        let myDate = new Date();
                        myDate.setMonth(myDate.getMonth() - month);
                        for (let date of dateUtile.getAllDaysOfMonth(myDate)) { // get data of all the days of current month
                            if (dateDuree.find(element => element.DATE_ARRET == date) == undefined) {
                                dateDuree.push({DATE_ARRET: date, DUREE_ARRET_MINUTE: 0})
                            }
                        }
                        dateDuree.sort((a, b) => new Date(a.DATE_ARRET) - new Date(b.DATE_ARRET)); // order by date_arret desc
                        const typeArret = data.find(element => element.typeArretLibelle == key)
                        arretMachine.push({
                            typeArretLibelle: typeArret.typeArretLibelle,
                            couleur: typeArret.CODE_COULEUR,
                            dateDuree: dateDuree
                        });
                    }
                    return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, {
                        data: arretMachine,
                        shift: data[0].NBR_HEURE
                    });
                } else return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, {
                    data: null,
                });

            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    },

    findArretMachineOfConnectedPilote: (connectedPiloteID) => {
        return dbintegrale
            .query(Queries.findArretMachineOfConnectedPilote(connectedPiloteID),
                {type: dbintegrale.QueryTypes.SELECT})
            .then((data) => {
                return new WsResponse(HttpStatus.OK, `Line count: ${data.length + 1}`, data);
            }).catch((err) => {
                throw new WsResponse(HttpStatus.INTERNAL_SERVER_ERROR, err.message, err);
            });
    }
}
