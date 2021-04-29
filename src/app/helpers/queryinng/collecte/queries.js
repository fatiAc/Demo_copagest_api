'use strict';

module.exports = {
    getNotTestedMission: () => {
        return `SELECT * FROM CL_MISSION_CONTROLE_ANTI_BIOTH WHERE RES_TEST_ANTI_BIOTH IS NULL
                         ORDER BY TOURNEE, NOM_PRODUCTEUR`
    },

    setResultOfTest: (resTest, controlleurID, missionID) => {
        return `UPDATE CL_MISSION_CONTROLE_ANTI_BIOTH set RES_TEST_ANTI_BIOTH = ${resTest}, ID_CONTROLLEUR_QUALITE = ${controlleurID}, DATE_PRISE_ECHANTILLON = '${moment(new Date().toISOString()).format('YYYY/MM/DD HH:mm:ss')}' WHERE ID_MISSION = ${missionID}`
    },

    // -------**** Liste des zones de collecte ****----------
    findZonesCollecte: () => {
        return 'select Z.ID_ZONE ,Z.ZONE,S.SITE from P_ZONE Z INNER JOIN P_SITE S ON Z.ID_SITE=S.ID_SITE  WHERE Z.ID_TYPE_ZONE=2 AND Z.ID_SITE IN (1,5) '
    },
// -------**** Liste des sites de collecte ****----------
    findSitesCollecte: () => {
        return 'select REF_SITE ,SITE,ID_SITE from P_SITE  WHERE ID_SITE IN(1,5) '
    },
// -------**** Liste des tournees de collecte ****----------
    findTourneeCollecte: () => {
        return 'select T.ID_TOURNEE,T.TOURNEE,S.SECTEUR,B.BLOC,Z.ZONE,C.SITE  '+
            'FROM P_TOURNEE T INNER JOIN P_SECTEUR S ON T.ID_SECTEUR=S.ID_SECTEUR '+
            'INNER JOIN P_BLOC B ON B.ID_BLOC=S.ID_BLOC '+
            'INNER JOIN P_ZONE Z ON Z.ID_ZONE=B.ID_ZONE '+
            'INNER JOIN P_SITE C ON C.ID_SITE=Z.ID_SITE '+
            'WHERE Z.ID_TYPE_ZONE=2 ORDER BY T.TOURNEE'
    },
// -------**** Liste des ups d'une tournee ****----------
    getUPTR: (tourneeID) => {
        return `
            select 
	                UP.ID_UNITE_PRODUCTION,UP.UNITE_PRODUCTION,UP.REF_UNITE_PRODUCTION,P.PRODUCTEUR ,pt.TOURNEE AS TOURNEE, pt.ID_TOURNEE 
            FROM  
	                P_UNITE_PRODUCTION UP INNER JOIN P_PRODUCTEUR P 
		                ON P.ID_PRODUCTEUR=UP.ID_PRODUCTEUR
	                INNER JOIN P_TOURNEE_UNITE_PRODUCTION ON P_TOURNEE_UNITE_PRODUCTION.ID_UNITE_PRODUCTION = UP.ID_UNITE_PRODUCTION
	                INNER JOIN P_TOURNEE pt ON PT.ID_TOURNEE = P_TOURNEE_UNITE_PRODUCTION.ID_TOURNEE  WHERE pt.ID_TOURNEE = ${tourneeID} ORDER BY UP.UNITE_PRODUCTION 
	                 `
    },
// -------**** Liste des ups non affetées à une tournee ****----------
    getUP: () => {
        return 'select UP.ID_UNITE_PRODUCTION,UP.UNITE_PRODUCTION,UP.REF_UNITE_PRODUCTION,P.PRODUCTEUR  '+
            'FROM  P_UNITE_PRODUCTION UP INNER JOIN P_PRODUCTEUR P ON P.ID_PRODUCTEUR=UP.ID_PRODUCTEUR '+
            'WHERE  UP.ACTIF=1 AND UP.ID_UNITE_PRODUCTION NOT IN (SELECT DISTINCT ID_UNITE_PRODUCTION FROM P_TOURNEE_UNITE_PRODUCTION ) ORDER BY UP.UNITE_PRODUCTION '
    },
// -------**** get zone by id ****----------
    findzonebyid: (id) => {
        return 'select ID_ZONE from P_ZONE  WHERE ID_ZONE='+id
    },
// -------**** get zone by id ****----------
    findzonebyidsite: (id_site,zone) => {
        return 'select ID_ZONE from P_ZONE  WHERE ID_SITE='+id_site +' AND ZONE=\''+zone+'\' AND ID_TYPE_ZONE=2'
    },
// -------**** delete zone ****----------
    deletezone: (id) => {
        return 'delete from P_ZONE  WHERE ID_ZONE='+id
    },
// -------**** delete bloc by id_zone ****----------
    deleteblocbyidzone: (id) => {
        return 'delete from P_BLOC  WHERE ID_ZONE='+id
    },

// -------**** get tournee by id ****----------
    findtourneebyid: (id) => {
        return 'select ID_TOURNEE from P_TOURNEE  WHERE ID_TOURNEE='+id
    },
// -------**** delete tournee ****----------
    deletetournee: (id) => {
        return 'delete from P_TOURNEE  WHERE ID_TOURNEE = '+id
    },
// -------**** delete secteur by id_tournee ****----------
    deletesecteurbyidtournee: (id) => {
        return 'delete from P_SECTEUR   WHERE ID_SECTEUR='+id
    },

// -------**** get tournee by nom ****----------
    findtourneebynom: (tournee) => {
        return 'select ID_TOURNEE from P_TOURNEE  WHERE TOURNEE='+tournee
    },
// -------**** get bloc by zone ****----------
    findblocbyzone: (id_zone) => {
        return 'select z.id_site, z.id_zone,b.id_bloc from P_ZONE z inner join P_BLOC b on z.id_zone=b.id_zone where z.id_zone='+id_zone
    },
// -------**** Ajouter Secteur ****----------
    ajoutersecteur: (id_site,id_bloc,secteur) => {
        return 'insert into P_SECTEUR VALUES (\''+secteur+'\',null,'+id_site+',null,null,null,null,null,null,'+id_bloc+')'
    },
// -------**** Ajouter tournee ****----------
    ajoutertournee: (id_secteur,tournee) => {
        return 'insert into P_TOURNEE VALUES (\''+tournee+'\','+id_secteur+',null,null,null,null,null,null)'
    },
// -------**** Ajouter zone ****----------
    ajouterzone: (id_site,zone) => {
        return 'insert into P_ZONE VALUES (\''+zone+'\','+id_site+',null,2 )'
    },
// -------**** Ajouter bloc ****----------
    ajouterbloc: (id_zone,bloc) => {
        return 'insert into P_BLOC VALUES (\''+bloc+'\','+id_zone+')'
    },
// -------**** supprimer up tournee ****----------
    deleteuptournee: (id_tournee,id_up) => {
        let req='delete from P_TOURNEE_UNITE_PRODUCTION where ID_TOURNEE='+id_tournee+' AND ID_UNITE_PRODUCTION='+id_up
        return req;
    },
// -------------------------------------------------------------------------------------- Collecte ---------------------------


};
