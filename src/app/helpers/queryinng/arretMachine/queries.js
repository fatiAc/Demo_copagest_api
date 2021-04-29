'use strict';

module.exports = {
    findAllPilotes: () => {
        return `SELECT DISTINCT CONCAT(MATRICULE,' - ', NOM) AS pilote, userModule.ID_UTILISATEUR AS ID_PILOTE 
                    FROM A_UTILISATEUR_MODULE userModule
                      INNER JOIN A_UTILISATEUR utilisateur ON utilisateur.ID_UTILISATEUR = userModule.ID_UTILISATEUR
                      WHERE ID_PROFIL = 3056 ORDER BY CONCAT(MATRICULE,' - ', NOM)`;
    },

    findAllShiftMachinePilot: () => {
        return `SELECT CONCAT(MATRICULE,' - ', machine.LIBELLE,' - ', shift.LIBELLE) AS combinaison, pilote.NOM AS pilote,shift.LIBELLE AS shiftt, machine.LIBELLE AS machine, combinaison.ID_PILOTE, machine.ID_MACHINE, shift.ID_SHIFT, ID
                      FROM AM_SHIFT_MACHINE_PILOTE combinaison
                      INNER JOIN A_UTILISATEUR pilote ON pilote.ID_UTILISATEUR = combinaison.ID_PILOTE
                      INNER JOIN P_MACHINE machine ON machine.ID_MACHINE = combinaison.ID_MACHINE
                      INNER JOIN P_SHIFT shift ON shift.ID_SHIFT = combinaison.ID_SHIFT
                      ORDER BY machine.LIBELLE`;
    },

    findShiftMachinePilotOfConnectedPilote: (connectedPiloteID) => {
        return `SELECT CONCAT(MATRICULE,' - ', machine.LIBELLE,' - ', shift.LIBELLE) AS combinaison, pilote.NOM AS pilote,shift.LIBELLE AS shiftt, machine.LIBELLE AS machine, combinaison.ID_PILOTE, machine.ID_MACHINE, shift.ID_SHIFT, ID
                      FROM AM_SHIFT_MACHINE_PILOTE combinaison
                      INNER JOIN A_UTILISATEUR pilote ON pilote.ID_UTILISATEUR = combinaison.ID_PILOTE
                      INNER JOIN P_MACHINE machine ON machine.ID_MACHINE = combinaison.ID_MACHINE
                      INNER JOIN P_SHIFT shift ON shift.ID_SHIFT = combinaison.ID_SHIFT
                      WHERE combinaison.ID_PILOTE = ${connectedPiloteID}
                      ORDER BY machine.LIBELLE`;

    },

    findAllMachineFabricationSteps: () => {
        return `SELECT ID_EVENEMENT_FABRICATION, machineFabrication.ID_MACHINE,  machine.LIBELLE AS machineLibelle, eventFabric.LIBELLE AS eventFabricLibelle, eventFabric.CODE_COULEUR
                        FROM AM_EVENEMENT_MACHINE machineFabrication
                        INNER JOIN P_MACHINE machine ON machine.ID_MACHINE = machineFabrication.ID_MACHINE
                        INNER JOIN AM_EVENEMENT_FABRICATION eventFabric ON eventFabric.ID_EVENEMENT = machineFabrication.ID_EVENEMENT_FABRICATION
                        ORDER BY machine.LIBELLE`;
    },

    findArretMachineOfConnectedPilote: (connectedPiloteID) => {
        let query = `SELECT FORMAT(DATE_ARRET,'dd/MM/yyyy, hh:mm tt') AS dateArret,FORMAT( arretMachine.DATESYS,'dd/MM/yyyy, hh:mm tt') AS dateSaisie, CONCAT(pilote.MATRICULE,' - ',
                         pilote.NOM)AS pilote, machine.LIBELLE AS machine, CONCAT(HEURE_DEBUT, ' - ',HEURE_FIN) AS shiftt, DUREE_ARRET_MINUTE, typeArret.LIBELLE AS typeArret,
                         eventFabric.LIBELLE AS eventFabric FROM AM_ARRET_MACHINE arretMachine
                         INNER JOIN AM_SHIFT_MACHINE_PILOTE shiftMachinePilote ON shiftMachinePilote.ID = arretMachine.ID_SHIFT_MACHINE_PILOTE
                         INNER JOIN AM_TYPE_ARRET typeArret ON typeArret.ID_TYPE_ARRET = arretMachine.ID_TYPE_ARRET
                            INNER JOIN AM_EVENEMENT_FABRICATION eventFabric ON eventFabric.ID_EVENEMENT = arretMachine.ID_EVENEMENT_FABRICATION
                            INNER JOIN P_SHIFT shiftt ON shiftt.ID_SHIFT = shiftMachinePilote.ID_SHIFT
                            INNER JOIN P_MACHINE machine ON machine.ID_MACHINE = shiftMachinePilote.ID_MACHINE
                            INNER JOIN A_UTILISATEUR pilote ON pilote.ID_UTILISATEUR = shiftMachinePilote.ID_PILOTE `;

        query += connectedPiloteID != 'null' ? ` WHERE shiftMachinePilote.ID_PILOTE = ${connectedPiloteID}` : ``;
        query += ` ORDER BY arretMachine.DATESYS`;
        return query

    },

    findArretMachineByCritaria: (machineID, piloteID, shiftID, month) => {
        let query = ` SELECT DUREE_ARRET_MINUTE, FORMAT(DATE_ARRET, 'yyyy-MM-dd') AS DATE_ARRET, CONCAT ('#',typeArret.CODE_COLEUR) AS CODE_COULEUR,typeArret.LIBELLE AS typeArretLibelle, shiftt.NBR_HEURE FROM AM_ARRET_MACHINE arretMachine
                            INNER JOIN AM_TYPE_ARRET typeArret ON typeArret.ID_TYPE_ARRET = arretMachine.ID_TYPE_ARRET
                            INNER JOIN AM_SHIFT_MACHINE_PILOTE shiftMachinePilote ON shiftMachinePilote.ID = arretMachine.ID_SHIFT_MACHINE_PILOTE
                            INNER JOIN AM_EVENEMENT_FABRICATION eventFabric ON eventFabric.ID_EVENEMENT = arretMachine.ID_EVENEMENT_FABRICATION
                            INNER JOIN P_SHIFT shiftt ON shiftt.ID_SHIFT = shiftMachinePilote.ID_SHIFT
                            INNER JOIN P_MACHINE machine ON machine.ID_MACHINE = shiftMachinePilote.ID_MACHINE
                            INNER JOIN A_UTILISATEUR pilote ON pilote.ID_UTILISATEUR = shiftMachinePilote.ID_PILOTE 
                                 WHERE 1 = 1 `;

        query += month != 'null' ? ` AND MONTH(FORMAT(DATE_ARRET, 'yyyy-MM-dd')) = ${month}` : ``;
        query += machineID != 'null' ? ` AND machine.ID_MACHINE = ${machineID}` : ``;
        query += piloteID != 'null' ? ` AND shiftMachinePilote.ID_PILOTE = ${piloteID}` : ``;
        query += shiftID != 'null' ? ` AND shiftt.ID_SHIFT = ${shiftID}` : ``;
        query += ` ORDER BY DATE_ARRET `;

        return query;
    },

    findMachinesOfSelectedPilote(piloteID) {
        return `SELECT machine.LIBELLE, machine.ID_MACHINE FROM AM_SHIFT_MACHINE_PILOTE shiftMachinePilote
                        INNER JOIN P_MACHINE machine ON machine.ID_MACHINE = shiftMachinePilote.ID_MACHINE
                        WHERE ID_PILOTE = ${piloteID}`;
    },


    findPilotesMutualMachines(piloteID) {
        return `SELECT CONCAT(MATRICULE, ' - ', NOM) AS pilote, ID_UTILISATEUR AS ID_PILOTE FROM AM_SHIFT_MACHINE_PILOTE shiftMachinePilote
                        INNER JOIN A_UTILISATEUR pilote ON pilote.ID_UTILISATEUR = shiftMachinePilote.ID_PILOTE
                        WHERE shiftMachinePilote.ID_MACHINE IN (SELECT ID_MACHINE FROM AM_SHIFT_MACHINE_PILOTE WHERE ID_PILOTE = ${piloteID})`;
    },

    findPiloteByMachineAndShift(machineID, shiftID) {
        return `SELECT CONCAT(MATRICULE, ' - ', NOM) AS pilote, ID_UTILISATEUR AS ID_PILOTE FROM AM_SHIFT_MACHINE_PILOTE shiftMachinePilote
                        INNER JOIN A_UTILISATEUR pilote ON pilote.ID_UTILISATEUR = shiftMachinePilote.ID_PILOTE
                        WHERE shiftMachinePilote.ID_MACHINE  = ${machineID} AND ID_SHIFT = ${shiftID}`;
    },

    getCurrentshiftAndMachineByPilote(pilote){
      return `
      SELECT
        asmp.ID_SHIFT, ps.LIBELLE, HEURE_DEBUT, HEURE_FIN, asmp.ID_MACHINE, au.NOM,  au.MATRICULE, pm.LIBELLE  AS MACHINE, ppm.PARC, pe.ENTREPOT, pe.REF_ENTREPOT, ID_ENTREPOT, ID_PILOTE
      FROM
        P_SHIFT ps INNER JOIN AM_SHIFT_MACHINE_PILOTE asmp ON ps.ID_SHIFT = asmp.ID_SHIFT AND asmp.ID_PILOTE = ${pilote} 
		
		AND SYSDATETIME() BETWEEN CONCAT((CASE WHEN ( HEURE_DEBUT > HEURE_FIN AND DATEPART(HOUR, GETDATE()) BETWEEN 0 AND  HEURE_FIN ) 
		THEN cast(DATEADD (DD , -1, SYSDATETIME()) AS DATE) ELSE CAST(SYSDATETIME() AS DATE) END), 'T',
        (CASE WHEN LEN(CAST(HEURE_DEBUT AS varchar)) = 1 THEN  CONCAT('0',CAST(HEURE_DEBUT AS varchar)) ELSE CAST(HEURE_DEBUT AS varchar) END)

        ,':00:00')


		AND CONCAT((CASE WHEN ( HEURE_DEBUT > HEURE_FIN AND DATEPART(HOUR, GETDATE())  BETWEEN HEURE_DEBUT AND 23 ) THEN cast(DATEADD (DD , 1, SYSDATETIME()) AS DATE) 
			--WHEN ( HEURE_DEBUT > HEURE_FIN AND DATEPART(HOUR, GETDATE())  BETWEEN 0 AND HEURE_FIN ) THEN CAST(SYSDATETIME() AS DATE)
			ELSE CAST(SYSDATETIME() AS DATE) END), 'T',
        (CASE WHEN LEN(CAST(HEURE_FIN AS varchar)) = 1 THEN  CONCAT('0',CAST(HEURE_FIN AS varchar)) ELSE CAST(HEURE_FIN AS varchar) END)

        ,':59:59')
		
   

        AND asmp.ACTIF = 1

        INNER JOIN A_UTILISATEUR au ON au.ID_UTILISATEUR = asmp.ID_PILOTE
        INNER JOIN P_MACHINE pm ON pm.ID_MACHINE = asmp.ID_MACHINE AND pm.ACTIF = 1
        INNER JOIN P_PARC_MACHINE ppm ON ppm.ID_PARC_MACHINE = pm.ID_PARC_MACHINE
        INNER JOIN P_ENTREPOT pe ON pe.ID_ENTREPOT = ppm.ID_ENTREPOT_EMBALAGE
`
    },

    /*  findArretMachineByCritaria: (machineID, piloteID, typeArretID) => {
          let query = ` SELECT FORMAT(DATE_ARRET,'dd/MM/yyyy, hh:mm tt')AS dateArret,FORMAT( arretMachine.DATESYS,'dd/MM/yyyy, hh:mm tt') AS dateSaisie, CONCAT(pilote.MATRICULE,' - ',
                           pilote.NOM)AS pilote, machine.LIBELLE AS machine, CONCAT(HEURE_DEBUT, ' - ',HEURE_FIN) AS shiftt, DUREE_ARRET_MINUTE, typeArret.LIBELLE AS typeArret,
                           eventFabric.LIBELLE AS eventFabric FROM AM_ARRET_MACHINE arretMachine
                              INNER JOIN AM_TYPE_ARRET typeArret ON typeArret.ID_TYPE_ARRET = arretMachine.ID_TYPE_ARRET
                              INNER JOIN AM_SHIFT_MACHINE_PILOTE shiftMachinePilote ON shiftMachinePilote.ID = arretMachine.ID_SHIFT_MACHINE_PILOTE
                              INNER JOIN AM_EVENEMENT_FABRICATION eventFabric ON eventFabric.ID_EVENEMENT = arretMachine.ID_EVENEMENT_FABRICATION
                              INNER JOIN P_SHIFT shiftt ON shiftt.ID_SHIFT = shiftMachinePilote.ID_SHIFT
                              INNER JOIN P_MACHINE machine ON machine.ID_MACHINE = shiftMachinePilote.ID_MACHINE
                              INNER JOIN A_UTILISATEUR pilote ON pilote.ID_UTILISATEUR = shiftMachinePilote.ID_PILOTE
                                   WHERE 1 = 1 `;

          query += machineID != 'null' ? ` AND machine.ID_MACHINE = ${machineID}` : ``;
          query += piloteID != 'null' ? ` AND shiftMachinePilote.ID_PILOTE = ${piloteID}` : ``;
          query += typeArretID != 'null' ? ` AND typeArret.ID_TYPE_ARRET = ${typeArretID}` : ``;
          query += ` ORDER BY dateArret DESC`;

          return query;
      },*/


};
