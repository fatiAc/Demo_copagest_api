let router = require('express').Router();

router.use('/evenement_machine', require('./Evenement_machineController'));
router.use('/shift_machine_pilote', require('./Shift_machine_piloteController'));
router.use('/arret_machine', require('./Arret_machineController'));
router.use('/type_arret', require('./Type_arretController'));
router.use('/evenement_fabrication', require('./Evenement_fabricationController'));
router.use('/shift', require('./ShiftController'));
router.use('/machine', require('./MachineController'));
module.exports = router;
