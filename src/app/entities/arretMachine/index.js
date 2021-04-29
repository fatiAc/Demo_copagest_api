let dbintegrale = require('../../../../env/entitiy_connection')('dbintegrale');

let Evenement_machine = dbintegrale.import('AM_EVENEMENT_MACHINE');
let Shift_machine_pilote = dbintegrale.import('AM_SHIFT_MACHINE_PILOTE');
let Arret_machine = dbintegrale.import('AM_ARRET_MACHINE');
let Type_arret = dbintegrale.import('AM_TYPE_ARRET');
let Evenement_fabrication = dbintegrale.import('AM_EVENEMENT_FABRICATION');
let Shift = dbintegrale.import('P_SHIFT');
let Machine = dbintegrale.import('P_MACHINE');

module.exports = {
    Evenement_machine,
    Shift_machine_pilote,
    Arret_machine,
    Type_arret,
    Evenement_fabrication,
    Shift, dbintegrale,
    Machine
};
