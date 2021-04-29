'use strict';
const dateUtil = require('../../dateUtile');

module.exports = {

    // -------**** Liste des agents de collecte ****----------
    findallAgentsCollecte: () => {
        return `
            select 
                DISTINCT A.ID_UTILISATEUR,A.NOM ,A.MATRICULE
            from
                A_UTILISATEUR A inner join A_UTILISATEUR_MODULE 
                    ON A.ID_UTILISATEUR = A_UTILISATEUR_MODULE.ID_UTILISATEUR and ID_PROFIL = 3063
         `

    },

    // -------**** Liste Semi remorque ****----------
    findallSemi: () => {
        return 'select ID_VEHICULE,MATRICULE_VEHICULE from P_VEHICULE WHERE IS_SEMI=1 '

    },

    getSemiRemorqueByTrans: (idTrans) => {
        return `
            SELECT 
                ID_VEHICULE, MATRICULE_VEHICULE 
            FROM 
                P_VEHICULE INNER JOIN P_TYPE_VEHICULE 
                    ON P_VEHICULE.ID_TYPE_VEHICULE = P_TYPE_VEHICULE.ID_TYPE_VEHICULE
                    and IS_SEMI = 1 AND Actif = 1 and ID_PROPRIETAIRE = ${idTrans}
        `

    },

// --------------**** Liste des ordres de mission ****-----------
    getAllSection: () => {
        return `
        SELECT ID_SECTION, SECTION FROM P_SECTION_ACTIVITE
      `
    },
    getVehiculeByTrans: (idTrans) => {
        return `
            SELECT 
                ID_VEHICULE, MATRICULE_VEHICULE 
            FROM 
                P_VEHICULE INNER JOIN P_TYPE_VEHICULE ON P_VEHICULE.ID_TYPE_VEHICULE = P_TYPE_VEHICULE.ID_TYPE_VEHICULE
            WHERE 
                ID_proprietaire = ${idTrans} AND ACTIF = 1 AND HAVE_MISSION = 1   
        `
    },

    getChauffeursByTrans: (idTrans) => {
        return `
            SELECT ID_CHAUFFEUR, NOM_COMPLET FROM P_CHAUFFEUR 
            WHERE ID_PROprietaire = ${idTrans} 
        `
    },

    GetOM: (siteID) => {
        return `
       SELECT
        TOP 300 OM.ID_ORDER_MISSION, REF_OM,DATE_HEURE_SAISIE AS DATE_HEURE,OM.DATE_SITUATION, CONCAT( cast( OM.DATE_HEURE_SAISIE as date)  ,'  ', left(cast(OM.DATE_HEURE_SAISIE as time),5)) AS DATE_HEURE_SAISIE,
        PV.MATRICULE_VEHICULE as Matricule_Vehicule, PV.ID_VEHICULE as Id_vehicule, PCA.CATEGORIE as Categorie ,PCA.ID_CATEGORIE as Id_categorie,
        ID_SECTION as Id_section, PSA.SECTION as Section, PROPRIETAIRE as Transportateur,
        OM.ID_PROPRIETAIRE AS Id_transporteur , TYPE_TRANSPORT as Type_transport, OM.ID_TYPE_TRANSPORT AS Id_typetransport,
        SEMI.ID_VEHICULE AS Id_semi, SEMI.MATRICULE_VEHICULE as Semi,
        STATUT_ORDRE_MISSION AS Statut ,TSOM.ID_STATUT_ORDRE_MISSION, 
        tournees = STUFF((
              SELECT ' - ' + tournee
                FROM T_DET_MISSION PDM INNER JOIN P_TOURNEE PT ON PDM.ID_TOURNEE = PT.ID_TOURNEE
                WHERE PDM.ID_ORDER_MISSION = OM.ID_ORDER_MISSION
                ORDER BY PDM.ORDRE ASC
                FOR XML PATH('')
                ), 1, 1, '')
  , AC.MATRICULE AS AGMATRICULE, AC.ID_UTILISATEUR AS AGIDUTILISATEUR, CONCAT(CAST(AC.MATRICULE AS VARCHAR),' - ',AC.NOM) AS AGENTCOLLECTE
  , AUCH.MATRICULE CHMATRICULE, AUCH.ID_UTILISATEUR CHIDUTILISATEUR, CONCAT(CAST(AUCH.MATRICULE AS VARCHAR),' - ',AUCH.NOM) AS CH
  ,AUCHEXT.ID_CHAUFFEUR CHEXID, AUCHEXT.NOM_COMPLET AS CHEXTNOM,
   AUCHEXT.NOM_COMPLET AS CHX
      from
      T_ORDER_MISSION OM LEFT OUTER JOIN P_VEHICULE PV ON OM.ID_VEHICULE = PV.ID_VEHICULE
      LEFT OUTER JOIN P_VEHICULE SEMI ON OM.ID_SEMI = SEMI.ID_VEHICULE
      LEFT OUTER JOIN P_CATEGORIE_ACTIVITE PCA ON PCA.ID_CATEGORIE = OM.ID_CATEGORIE
      LEFT OUTER JOIN P_SECTION_ACTIVITE PSA ON PSA.ID_SECTION = PCA.ID_SECTION_ACTIVITE
      LEFT OUTER JOIN P_PROPRIETAIRE PP ON PP.ID_PROPRIETAIRE = OM.ID_PROPRIETAIRE
      LEFT OUTER JOIN P_TYPE_TRANSPORT PTT on OM.ID_TYPE_TRANSPORT = PTT.ID_TYPE_TRANSPORT
      LEFT OUTER JOIN T_STATUT_ORDRE_MISSION TSOM on OM.ID_STATUT = TSOM.ID_STATUT_ORDRE_MISSION
      LEFT OUTER JOIN A_UTILISATEUR AU ON AU.ID_UTILISATEUR = OM.ID_OP_SAISIE
	  LEFT OUTER JOIN T_AGENT_MISSION TAM ON TAM.ID_ORDER_MISSION = OM.ID_ORDER_MISSION AND TAM.ID_TYPE_AGENT = 2
	  LEFT OUTER JOIN A_UTILISATEUR AC ON AC.ID_UTILISATEUR = TAM.ID_AGENT
	  LEFT outer join T_AGENT_MISSION TAMCH ON TAMCH.ID_ORDER_MISSION = OM.ID_ORDER_MISSION AND TAMCH.ID_TYPE_AGENT = 1
	  LEFT OUTER JOIN A_UTILISATEUR AUCH ON AUCH.ID_UTILISATEUR = TAMCH.ID_AGENT
	  LEFT outer join T_AGENT_MISSION TAMCHEXT ON TAMCHEXT.ID_ORDER_MISSION = OM.ID_ORDER_MISSION AND TAMCHEXT.ID_TYPE_AGENT = 3
	  LEFT OUTER JOIN P_CHAUFFEUR AUCHEXT ON AUCHEXT.ID_CHAUFFEUR = TAMCHEXT.ID_AGENT
      WHERE
      OM.ACTIF = 1 AND OM.ID_SITE = ${siteID}  AND CLOTURE = 0
      ORDER BY ID_ORDER_MISSION DESC
`
    },
// --------------**** Liste details ordre de mission ****-----------
    GetDetailOM: (id_om) => {
        return 'SELECT D.ID_ORDER_MISSION, D.ID_DET_MISSION ,D.ORDRE, D.ID_TOURNEE,T.TOURNEE, KM_SORTIE, KM_ENTRE, ' +
            'concat( cast( D.DATE_HEURE_DEPART as date),\'  \',  left(cast(D.DATE_HEURE_DEPART as time),5)) AS DATE_SORTIE,' +
            'concat( cast( D.DATE_HEURE_ARRIVEE as date),\'  \',  left(cast(D.DATE_HEURE_ARRIVEE as time),5)) AS DATE_ENTREE,' +
            'D.KM_ARRET, CASE WHEN D.ANNULER = 1 THEN \'Oui\' ELSE \'Non\' END AS ANNULER , D.ANNULER AS isAnnule, A.NOM as CONTROLEURENTREE,B.NOM AS CONTROLEURSORTIE ' +
            'FROM T_DET_MISSION D INNER JOIN P_TOURNEE T ON D.ID_TOURNEE=T.ID_TOURNEE ' +
            ' LEFT JOIN A_UTILISATEUR A ON A.ID_UTILISATEUR=D.ID_CONTROLLEUR_FLUX_ENTREE ' +
            ' LEFT JOIN A_UTILISATEUR B ON B.ID_UTILISATEUR=D.ID_CONTROLLEUR_FLUX_SORTIE ' +
            ' WHERE D.ID_ORDER_MISSION=' + id_om +
            '  ORDER BY ORDRE ASC'
    },

    //-------**** Annuler OM ****-------------
    UpdateStatutOM: (id_om) => {
        return 'UPDATE T_ORDER_MISSION SET ID_STATUT = 4 WHERE ID_ORDER_MISSION = ' + id_om
    },

    //-------**** Modifer chauffeur OM ****-------------
    updateAgent: (id_om, id_type, id_agent) => {
        return 'UPDATE T_AGENT_MISSION SET ID_AGENT=' + id_agent + ' WHERE ID_ORDER_MISSION=' + id_om + ' AND ID_TYPE_AGENT=' + id_type
    },

    //-------**** Supprimer OM ****-------------
    DeleteOM: (id_om) => {
        return ' UPDATE T_ORDER_MISSION SET ACTIF = 0 WHERE ID_ORDER_MISSION = ' + id_om
    },


    //-------**** get nbr détail OM ****-------------
    GetCountDetailOM: (id_om) => {
        return 'SELECT count(ID_DET_MISSION) as nbr from T_DET_MISSION WHERE ID_ORDER_MISSION = ' + id_om + ' AND ANNULER = 0'
    },

    //-------**** get l'arrive détail OM ****-------------
    GetArriveeDetailOM: (id_om) => {
        return 'SELECT  TOP 1 S.ID_SITE FROM T_DET_MISSION  D INNER JOIN P_TOURNEE_SITE S ON D.ID_TOURNEE=S.ID_TOURNEE and S.DEPART=0 ' +
            ' WHERE ID_ORDER_MISSION=' + id_om + ' and D.ANNULER=0 ORDER BY ORDRE DESC'
    },

    //-------**** get les trajet by depart ****-------------
    GetTrajetByDepart: (id_site) => {
        return ' select T.ID_TOURNEE,T.TOURNEE,S.ID_SITE, S.DEPART from P_TOURNEE T INNER JOIN P_TOURNEE_SITE  S ON T.ID_TOURNEE=S.ID_TOURNEE ' +
            'where S.ID_SITE=' + id_site + ' and DEPART=1 ORDER BY T.TOURNEE '
    },
    //-------**** Annuler détail OM ****-------------
    AnnulerDetailOM: (id_om, id_det_om) => {
        return 'UPDATE T_DET_MISSION SET ANNULER=1,ORDRE=0 WHERE ID_ORDER_MISSION=' + id_om +
            ' AND ID_DET_MISSION=' + id_det_om
    },
    //-------**** Arreter OM ****-------------
    ArreterOM: (id_det_om, km_arret) => {
        return 'UPDATE T_DET_MISSION SET KM_ARRET=' + km_arret + ' ,DATE_HEURE_ARRIVEE = getdate() WHERE ID_DET_MISSION=' + id_det_om
    },

    //-------**** Annuler le reste des trajets ****-------------
    Annulertrajets: (orderMissionID, ordre, opSaisieID) => {
        return `UPDATE T_DET_MISSION SET ANNULER = 1, ORDRE = 0, ID_OP_SAISIE = ${opSaisieID}, DATE_HEURE_SAISIE = sysdatetime() WHERE ID_ORDER_MISSION =  ${orderMissionID} AND ORDRE > =  ${ordre}`
    },


    //-------**** mettre à jour l'ordre du détail OM ****-------------
    UpdateOrdreDetailOM: (id_om, id_det_om) => {
        return 'UPDATE T_DET_MISSION SET ORDRE=ORDRE-1 WHERE ID_ORDER_MISSION=' + id_om +
            ' AND ANNULER=0 AND ORDRE >(select ordre from T_DET_MISSION where ID_DET_MISSION =' + id_det_om + ')'
    },
// //-------****  destination de l'ancien trajet ****-------------
// getdestinationAvant:(id_om,ordre)=>{

//   return ' SELECT  S.ID_SITE FROM T_DET_MISSION  D INNER JOIN P_TOURNEE_SITE S ON D.ID_TOURNEE=S.ID_TOURNEE and S.DEPART=0 '+
//   ' WHERE ID_ORDER_MISSION='+id_om+' and ORDRE='+ordre 
// },
// //-------****  depart du nouveau trajet ****-------------
// getdepartapres:(id_tournee)=>{

//   return 'SELECT ID_SITE FROM P_TOURNEE_SITE where ID_TOURNEE='+id_tournee+' AND DEPART=1' 
// },
// --------------**** Consultation des ordres de mission ****-----------
    consultOM: (datedebut, datefin, chauffeur, section, categorie, transporteur, vehicule, semi, typetransport) => {
        let req = ' ';
        let req1 = ' ';
        if (section != null) {
            req = ' and c.ID_SECTION_ACTIVITE=' + section
        }
        ;
        // else{
        //   req=' and om.ACTIF=0 '
        // };
        if (categorie != null) {
            req = req + ' and om.ID_CATEGORIE=' + categorie
        }
        ;
        if (transporteur != null) {
            req = req + ' and om.ID_PROPRIETAIRE=' + transporteur
        }
        ;
        if (vehicule != null) {
            req = req + ' and om.ID_VEHICULE=' + vehicule
        }
        ;
        if (semi != null) {
            req = req + ' and om.ID_SEMI=' + semi
        }
        ;
        if (typetransport != null) {
            req = req + ' and om.ID_TYPE_TRANSPORT=' + typetransport
        }
        ;
        if (chauffeur != null) {
            req1 = ' where A.Id_Chauffeur=' + chauffeur
            // if( id_agentcollecte!=null){
            //   req1=req1+' and A.Id_agent='+id_agentcollecte
            // }
        }
        // else{
        //   if( id_agentcollecte!=null){
        //     req1=req1+' where A.Id_agent='+id_agentcollecte
        //   }
        // }

        return 'select  cast(A.ID_ORDER_MISSION as int) as ID_ORDER_MISSION ,A.REF_OM,concat( cast( A.DATE_HEURE_SAISIE as date),\'  \',  left(cast(A.DATE_HEURE_SAISIE as time),5)) AS DATE_OM,cast(A.DATE_HEURE_SAISIE as datetime) AS dateheureom, ch.NOM_COMPLET  as Chauffeur1,u1.MATRICULE as matriculeChauffeurCOPAG,u1.NOM as ChauffeurCopag, u.NOM as Agent_collecte, ' +
            ' concat(isnull(ch.NOM_COMPLET,u1.NOM),\' Chauffeur / \', isnull(u.NOM,\'-----\'),\' Agent de collecte\') as Chauffeur,A.Matricule_Vehicule,A.Categorie,A.Id_section,A.Section,A.Transportateur, ' +
            'A.Type_transport,A.Semi,A.Statut,SUBSTRING(A.Tournee, 1, LEN(A.Tournee)-1) as Tournee FROM ' +
            '(select  distinct om.ID_ORDER_MISSION as ID_ORDER_MISSION ,om.REF_OM,om.DATE_HEURE_SAISIE, ' +
            '(select ag.ID_AGENT FROM T_AGENT_MISSION ag  where  ag.ID_ORDER_MISSION=om.ID_ORDER_MISSION and ag.ID_TYPE_AGENT=1 ) as Id_Chauffeur, ' +
            '(select ag.ID_AGENT FROM T_AGENT_MISSION ag  where  ag.ID_ORDER_MISSION=om.ID_ORDER_MISSION and ag.ID_TYPE_AGENT=2 ) as Id_agent, ' +
            'v.MATRICULE_VEHICULE as Matricule_Vehicule,v.ID_VEHICULE as Id_vehicule, ' +
            'c.CATEGORIE as Categorie,c.ID_CATEGORIE as Id_categorie,sc.ID_SECTION as Id_section, sc.SECTION as Section,  ' +
            'p.PROPRIETAIRE as Transportateur,p.ID_PROPRIETAIRE as Id_transporteur, ' +
            't.TYPE_TRANSPORT as Type_transport,t.ID_TYPE_TRANSPORT as Id_typetransport, ' +
            'om.ID_SEMI as Id_semi,v2.MATRICULE_VEHICULE AS Semi, ' +
            's.STATUT_ORDRE_MISSION as Statut ' +
            ',(select t.TOURNEE + \'/\' AS [text()] from T_DET_MISSION d inner join P_TOURNEE t on d.ID_TOURNEE=t.ID_TOURNEE where d.ID_ORDER_MISSION=om.ID_ORDER_MISSION AND d.ANNULER=0 ORDER BY d.ORDRE asc FOR XML PATH(\'\')) as Tournee ' +
            'from T_ORDER_MISSION om  ' +
            'inner join P_VEHICULE v on om.ID_VEHICULE=v.ID_VEHICULE ' +
            'left join P_VEHICULE v2 on om.ID_SEMI=v2.ID_VEHICULE ' +
            'inner join P_CATEGORIE_ACTIVITE c on om.ID_CATEGORIE=c.ID_CATEGORIE ' +
            'inner join P_SECTION_ACTIVITE sc on c.ID_SECTION_ACTIVITE=sc.ID_SECTION ' +
            'inner join P_PROPRIETAIRE p on om.ID_PROPRIETAIRE=p.ID_PROPRIETAIRE ' +
            'inner join P_TYPE_TRANSPORT t on om.ID_TYPE_TRANSPORT=t.ID_TYPE_TRANSPORT ' +
            'inner join T_STATUT_ORDRE_MISSION s on om.ID_STATUT=s.ID_STATUT_ORDRE_MISSION ' +
            'where om.DATE_HEURE_SAISIE between \'' + datedebut + '\' and \'' + datefin + '\' ' + req +
            ' ) as A left join P_CHAUFFEUR ch on A.Id_Chauffeur=ch.ID_CHAUFFEUR ' +
            'left join A_UTILISATEUR u on A.Id_agent= u.ID_UTILISATEUR left join  A_UTILISATEUR u1 on A.Id_Chauffeur=u1.ID_UTILISATEUR  ' + req1 +
            ' ORDER BY A.DATE_HEURE_SAISIE desc'
    },
}


