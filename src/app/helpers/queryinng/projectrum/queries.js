'use strict';

module.exports = {

    getAppProjet: () => {
        return `SELECT application.LIBELLE AS appLibelle, projet.LIBELLE AS projetLibelle, application.ID_MODULE, projet.ID_PROJET FROM 
                GP_MODULE application INNER JOIN GP_PROJET projet ON projet.ID_PROJET = application.ID_PROJET
                ORDER BY application.ID_MODULE DESC`
    },

    getAllSprints: () => {
        return `SELECT ID_SPRINT, sprint.LIBELLE, sprint.ID_MODULE, DATE_DEBUT_PLANIFIER, DATE_FIN_PLANIFIER, TAUX_REALISATION, COEFFICIENT_JOCKER_PLANING, NBR_TOTAL_POINT_JOCKER_PLANING, FRAIS_TOTAL,
                     NBR_TOTAL_HEUR_REALISATION, app.LIBELLE AS appLibelle, projet.ID_PROJET FROM GP_SPRINT sprint
                      INNER JOIN GP_MODULE app ON app.ID_MODULE = sprint.ID_MODULE
                      INNER JOIN GP_PROJET projet on projet.ID_PROJET = app.ID_PROJET
                      ORDER BY ID_SPRINT DESC`
    },

    getAllUsersHistory: () => {
        return `SELECT [ID_USER_STORY],[POINT_JOCKER_PLANING], [FRAIS_UNITAIRE],userHistory.[DESCRIPTION],
                      userHistory.[COEFFICIENT_JOCKER_PLANING],userHistory.[DATE_DEBUT],userHistory.[DATE_FIN],
                      usr.NOM AS DEVELOPPEUR, app.LIBELLE AS appLibelle,[ID_SPRINT],[ID_DEVELOPPEUR],
                      tache.TYPE_TACHE,app.ID_MODULE, projet.ID_PROJET FROM GP_USER_STORY userHistory
                      LEFT OUTER JOIN A_UTILISATEUR usr on usr.ID_UTILISATEUR = userHistory.ID_DEVELOPPEUR
                      LEFT OUTER JOIN GP_MODULE app on app.ID_MODULE = userHistory.ID_MODULE
                      LEFT OUTER JOIN GP_TYPE_TACHE tache on tache.ID_TYPE_TACHE = userHistory.ID_TYPE_TACHE
                      LEFT OUTER JOIN GP_PROJET projet on projet.ID_PROJET = app.ID_PROJET 
                        ORDER BY ID_USER_STORY DESC`
    },

    getAllProject: (ouvert) => {
        let req = `
        SELECT
            ISNULL(gp.clot,0) AS CLOT,gp.date_debut as DATE_DEBUT, gp.date_fin as DATE_FIN ,gp.ID_PROJET, gp.LIBELLE, gtp.TYPE_PROJET, gp.CLIENT,
            gp.DESCRIPTION, AU_SC.NOM AS SCRUM_MASTER, AU_TL.NOM AS TECHNIQUE_LEADER,
            gtp.ID_TYPE_PROJET, AU_SC.ID_UTILISATEUR AS ID_SCRUM_MASTER, AU_TL.ID_UTILISATEUR AS ID_LEADER_TECHNIQUE, AU_PO.ID_UTILISATEUR AS ID_PO
            
            , ISNULL(SUM((CASE WHEN gus.ID_SPRINT IS NOT NULL AND gus.DATE_FIN IS NULL THEN gus.POINT_JOCKER_PLANING END)),0) AS TOTAL_PLANIFIE_TO_DO
			, ISNULL(SUM(gus.POINT_JOCKER_PLANING),0) AS TOTAL_BACKLOG_PLANIFIER
			, ISNULL(COUNT((CASE WHEN ISNULL(gus.POINT_JOCKER_PLANING,0) = 0 THEN gus.ID_USER_STORY END)),0) TOTAL_US_NON_PLANIFIER
			, ISNULL(SUM((CASE WHEN gus.ID_SPRINT IS NOT NULL AND gus.DATE_FIN IS NOT NULL THEN gus.POINT_JOCKER_PLANING END)),0) AS TOTAL_PLANIFIE_DONE
        FROM
            dbo.GP_PROJET gp INNER JOIN dbo.GP_TYPE_PROJET gtp ON gp.ID_TYPE_PROJET = gtp.ID_TYPE_PROJET
            INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR AU_SC ON AU_SC.ID_UTILISATEUR = GP.SCRUM_MASTER
            INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR AU_TL ON AU_TL.ID_UTILISATEUR = GP.TECHNIQUAL_LEADER
            INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR AU_PO ON AU_PO.ID_UTILISATEUR = GP.PRODUCT_OWNER
                    LEFT OUTER JOIN dbo.GP_MODULE ga ON gp.ID_PROJET = ga.ID_PROJET
                LEFT OUTER JOIN dbo.GP_USER_STORY gus ON ga.ID_MODULE = gus.ID_MODULE
                LEFT OUTER JOIN dbo.GP_SPRINT gs ON gus.ID_SPRINT = gs.ID_SPRINT 
	    	`;
        if (ouvert) {
            req += ` WHERE ISNULL(gp.clot,0) = 0`
        }

        req += ` GROUP BY
		    gp.date_debut,gp.date_fin,gp.clot, 
            gp.ID_PROJET, gp.LIBELLE, gtp.TYPE_PROJET, gp.CLIENT, gp.DESCRIPTION, AU_SC.NOM, AU_TL.NOM ,
            gtp.ID_TYPE_PROJET, AU_SC.ID_UTILISATEUR , AU_TL.ID_UTILISATEUR , AU_PO.ID_UTILISATEUR
            ORDER BY gp.ID_PROJET DESC 
        `
        return req;
    },

    getProjetById: (idProjet) => {
        return `
            SELECT
                gpp.ID_PROJET, gpp.LIBELLE AS PROJET , gtp.TYPE_PROJET, DESCRIPTION
            FROM
                GP_PROJET gpp INNER JOIN dbo.GP_TYPE_PROJET gtp
                    ON gpp.ID_TYPE_PROJET = gtp.ID_TYPE_PROJET 
            WHERE 
                gpp.ID_PROJET = ` + idProjet
    },

    getDetProjetById: (idProjet) => {
        return ` 
    SELECT
        ga.LIBELLE AS APPLICATION, (CASE WHEN gs.LIBELLE IS NULL THEN 'NON AFFECTER' ELSE gs.LIBELLE END) AS SPRINT,
        cast(COUNT(gus.ID_USER_STORY) AS float) AS NBR_US,
        ROUND((COUNT((CASE WHEN gus.ID_USER_STORY_PREVIOUS IS NOT NULL THEN gus.ID_USER_STORY END)) / (CASE WHEN cast(COUNT(gus.ID_USER_STORY) AS float) = 0 THEN 1 ELSE cast(COUNT(gus.ID_USER_STORY) AS float) END)) * 100, 2) AS TAUX_RETRO,
        ROUND(AVG(gus.POINT_JOCKER_PLANING),2) AS MOY_COMPLEXITE, gs.COEFFICIENT_JOCKER_PLANING AS COEFICIENT,
        SUM(ISNULL(gus.POINT_JOCKER_PLANING,0) * ISNULL(gs.COEFFICIENT_JOCKER_PLANING,0)) AS TOTAL_HEURES
    FROM
        GP_PROJET gpp INNER JOIN dbo.GP_TYPE_PROJET gtp
            ON gpp.ID_TYPE_PROJET = gtp.ID_TYPE_PROJET
        LEFT OUTER JOIN dbo.GP_APPLICATION ga
            ON gpp.ID_PROJET = ga.ID_PROJET
        LEFT OUTER JOIN dbo.GP_USER_STORY gus
            ON ga.ID_APPLICATION = gus.ID_APPLICATION
        LEFT OUTER JOIN dbo.GP_SPRINT gs
            ON gs.ID_SPRINT = gus.ID_SPRINT
    WHERE
        gpp.ID_PROJET = ` + idProjet + `
    GROUP BY
        gpp.ID_PROJET, gpp.LIBELLE , gtp.TYPE_PROJET, ga.LIBELLE ,gs.LIBELLE, gs.COEFFICIENT_JOCKER_PLANING , gpp.DESCRIPTION
`
    },

    getStatutsProjetById: (idProjet) => {
        return ` 
        SELECT
            ROUND((SUM((CASE WHEN gus.DATE_FIN IS NOT NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END) * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0))) / (CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) * 100,2) AS Avancement, 
            ROUND((SUM((CASE WHEN gus.ID_USER_STORY_PREVIOUS IS NOT NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END) * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0))) / (CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) * 100,2) AS RETARD, 
            ROUND(AVG(ISNULL(gus.POINT_JOCKER_PLANING,0)),2) AS MOY_POINT_US, 
            COUNT(gus.ID_USER_STORY) AS NBR_USER_STORY, 
            ROUND((CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) / 8.0,2) AS JHPlanifier ,
	        (CASE WHEN SUM((CASE WHEN gus.ID_SPRINT IS NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END)) IS NULL THEN 0 ELSE SUM((CASE WHEN gus.ID_SPRINT IS NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END)) END) AS POINT_NPLANIFIER
        FROM 
            GP_PROJET gpp INNER JOIN dbo.GP_APPLICATION ga 
                ON gpp.ID_PROJET = ga.ID_PROJET AND gpp.ID_PROJET = ` + idProjet + `
            LEFT OUTER JOIN dbo.GP_USER_STORY gus 
                ON ga.ID_APPLICATION = gus.ID_APPLICATION 
            LEFT OUTER JOIN dbo.GP_SPRINT gs 
                ON gs.ID_SPRINT = gus.ID_SPRINT `
    },

    getEquipeProjetById: (idProjet) => {
        return `
                SELECT 
                    au.ID_UTILISATEUR, au.NOM 
                FROM 
                    dbo.GP_EQUIPE_PROJET gep INNER JOIN BD_INTEGRALE_PROD.dbo.A_UTILISATEUR au 
                        ON gep.ID_MEMBRE_EQUIPE = au.ID_UTILISATEUR 
                WHERE 
                    ID_PROJET = ` + idProjet
    },

    getStatutsEquipeProjetById: (idProjet) => {
        return `
            SELECT 
                au.NOM,
                ROUND((SUM((CASE WHEN gus.DATE_FIN IS NOT NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END) * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0))) / (CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) * 100,2) AS Avancement, 
                ROUND((SUM((CASE WHEN gus.ID_USER_STORY_PREVIOUS IS NOT NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END) * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0))) / (CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) * 100,2) AS RETARD, 
                ROUND(AVG(ISNULL(gus.POINT_JOCKER_PLANING,0)),2) AS MOY_POINT_US, 
                COUNT(gus.ID_USER_STORY) AS NBR_USER_STORY, 
                ROUND((CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) / 8.0,2) AS JHPlanifier 
            FROM 
                GP_PROJET gpp INNER JOIN dbo.GP_APPLICATION ga 
                    ON gpp.ID_PROJET = ga.ID_PROJET AND gpp.ID_PROJET = ` + idProjet + `
                INNER JOIN dbo.GP_USER_STORY gus 
                    ON ga.ID_APPLICATION = gus.ID_APPLICATION AND gus.ID_DEVELOPPEUR IS NOT NULL
                INNER JOIN dbo.GP_SPRINT gs 
                    ON gs.ID_SPRINT = gus.ID_SPRINT 
                INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au 
                    ON au.ID_UTILISATEUR = gus.ID_DEVELOPPEUR
            GROUP BY   
                au.NOM`
    },

    getStatutsEquipeDSI: () => {

        return `
            SELECT
                TA.ID_UTILISATEUR,TA.ID_GLPI, TA.NOM,
                ISNULL(TB.Avancement,0) AS Avancement,ISNULL(TB.RETARD,0) AS RETARD,ISNULL(TB.MOY_EFFORT_PROJET,0) AS MOY_EFFORT_PROJET,
                ROUND(((ISNULL(TB.JH_SCRUM,0) + ISNULL(TC.NbrHeurTask,0)) / TA.JHTONOW)*100,2) AS OCCUPATION,
                ROUND((ISNULL(TB.JH_SCRUM,0) / (ISNULL(TB.JH_SCRUM,0) + ISNULL(TC.NbrHeurTask,0))) * 100,2) AS OCCUPATION_MODE_PROJET,
                ISNULL(TE.EFFORT_TL,0) AS EFFORT_TL, ISNULL(TD.EFFORT_SM,0) AS EFFORT_SM, ISNULL(TB.NBR_USER_STORY,0) NBR_USER_STORY
            FROM
                (
                    SELECT
                        ID_UTILISATEUR,ID_GLPI, NOM,
                        (SELECT COUNT(*) AS NBR_JOUR FROM GP_CALENDER WHERE DATE BETWEEN '20191001' AND '20200930' AND FERIER = 0) AS JHANNUELLE,
                        (SELECT COUNT(*) AS NBR_JOUR FROM GP_CALENDER WHERE DATE BETWEEN '20191001' AND cast(sysdatetime() as date) AND FERIER = 0) AS JHTONOW
                    FROM 
                        BD_INTEGRALE_PROD.DBO.A_UTILISATEUR WHERE ID_GLPI IS NOT NULL
                ) TA
                LEFT OUTER JOIN
                (
                    SELECT 
                        au.ID_UTILISATEUR,
                        ROUND((SUM((CASE WHEN gus.DATE_FIN IS NOT NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END) * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0))) / (CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) * 100,2) AS Avancement,
                        ROUND((SUM((CASE WHEN gus.ID_USER_STORY_PREVIOUS IS NOT NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END) * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0))) / (CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) * 100,2) AS RETARD,
                        ROUND(AVG(ISNULL(gus.POINT_JOCKER_PLANING,0)),2) AS MOY_EFFORT_PROJET,
                        COUNT(gus.ID_USER_STORY) AS NBR_USER_STORY,
                        ROUND((CASE WHEN SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) IS NULL THEN 1 ELSE SUM(gus.POINT_JOCKER_PLANING * ISNULL(gs.COEFFICIENT_JOCKER_PLANING, 0)) END) / 8.0,2) AS JH_SCRUM
                    FROM
                        GP_PROJET gpp INNER JOIN dbo.GP_APPLICATION ga
                            ON gpp.ID_PROJET = ga.ID_PROJET
                        INNER JOIN dbo.GP_USER_STORY gus
                            ON ga.ID_APPLICATION = gus.ID_APPLICATION AND gus.ID_DEVELOPPEUR IS NOT NULL
                        INNER JOIN dbo.GP_SPRINT gs
                            ON gs.ID_SPRINT = gus.ID_SPRINT
                        INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au 
                            ON au.ID_UTILISATEUR = gus.ID_DEVELOPPEUR
                    GROUP BY 
                        au.NOM, ID_UTILISATEUR
                ) TB
                    ON TA.ID_UTILISATEUR = TB.ID_UTILISATEUR
                LEFT OUTER JOIN
                (
                    SELECT 
                        * 
                    FROM 
                        openquery(MYSQL,'
                                            select
                                                gu.id, firstname, realname, cast((SUM(gtt.actiontime)/60)/60/8 as decimal(38,2))  NbrHeurTask
                                            from
                                                glpi_tickets gt INNER JOIN glpi_tickettasks gtt ON gt.id = gtt.tickets_id
                                                INNER JOIN glpi_users gu ON gu.id = gtt.users_id_tech
                                                    AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                                            WHERE
                                                gtt.date BETWEEN 20191001 AND 20200930 GROUP BY gu.id, firstname, realname ORDER BY firstname
                                        '
                                    )
                ) TC 
                    ON TC.id = TA.ID_GLPI
                LEFT OUTER JOIN
                (
                    SELECT
                        SCRUM_MASTER, ROUND(SUM(ISNULL(gus.POINT_JOCKER_PLANING,0))/8,2) AS  EFFORT_SM
                    FROM
                        GP_PROJET gpp INNER JOIN dbo.GP_APPLICATION ga
                            ON gpp.ID_PROJET = ga.ID_PROJET
                        INNER JOIN dbo.GP_USER_STORY gus
                            ON ga.ID_APPLICATION = gus.ID_APPLICATION
                        INNER JOIN dbo.GP_SPRINT gs
                            ON gs.ID_SPRINT = gus.ID_SPRINT
                    GROUP BY 
                        gpp.SCRUM_MASTER
                ) TD
                    ON TA.ID_UTILISATEUR = TD.SCRUM_MASTER
                LEFT OUTER JOIN
                (
                    SELECT
                        TECHNIQUAL_LEADER, ROUND(SUM(ISNULL(gus.POINT_JOCKER_PLANING,0))/8,2) AS EFFORT_TL
                    FROM
                        GP_PROJET gpp INNER JOIN dbo.GP_APPLICATION ga
                            ON gpp.ID_PROJET = ga.ID_PROJET
                        INNER JOIN dbo.GP_USER_STORY gus
                            ON ga.ID_APPLICATION = gus.ID_APPLICATION
                        INNER JOIN dbo.GP_SPRINT gs
                            ON gs.ID_SPRINT = gus.ID_SPRINT
                    GROUP BY 
                        gpp.TECHNIQUAL_LEADER
                ) TE
                    ON TA.ID_UTILISATEUR = TE.TECHNIQUAL_LEADER
            `
    },

    getBurnDownChart: (idSprint) => {
        return ` 
            SELECT 
                TB.ID - 1 AS X, TB.DATE, TB.NBR_US AS Y, TB.ID - 1 RX, 0 RY 
            FROM 
                ( 
                    SELECT 
                        ROW_NUMBER() OVER (ORDER BY (SELECT NULL) ) as ID , TA.DATE, TA.NBR_US
                    FROM 
                        (
                            SELECT 
                                T.DATE, (SELECT COUNT(gus.ID_USER_STORY) FROM dbo.GP_USER_STORY gus WHERE gus.ID_SPRINT = ` + idSprint + `) - COUNT(gus.ID_USER_STORY) AS NBR_US 
                            FROM 
                                (SELECT gpc.DATE FROM dbo.GP_SPRINT gs INNER JOIN GP_Calender gpc ON gpc.DATE BETWEEN  gs.DATE_DEBUT_PLANIFIER AND gs.DATE_FIN_PLANIFIER 
                                WHERE ID_SPRINT IN (` + idSprint + `)) T 
                            LEFT OUTER JOIN 
                            dbo.GP_USER_STORY gus ON gus.DATE_FIN <= T.[DATE] AND gus.ID_SPRINT = ` + idSprint + ` GROUP BY T.DATE
                        ) TA
                ) TB `
    },

    getSprintsInfo: (idProjet) => {
        return ` 
            SELECT 
                '#'+CAST(gs.ID_SPRINT AS VARCHAR(12))+' - '+ gs.LIBELLE AS VALUESP,gs.ID_SPRINT, gs.LIBELLE 
                , ga.LIBELLE AS APPLICATIONLIB, gp.LIBELLE AS PROJETLIB, gs.DATE_DEBUT_PLANIFIER AS DATE_DEBUT, gs.DATE_FIN_PLANIFIER AS DATE_FIN,
                Equipes = STUFF (( 
                    SELECT DISTINCT ' - '+NOM FROM dbo.GP_USER_STORY gustuff INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au
                    ON au.ID_UTILISATEUR = gustuff.ID_DEVELOPPEUR WHERE gustuff.ID_SPRINT = gs.ID_SPRINT
                    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'') 
            FROM 
                dbo.GP_SPRINT gs INNER JOIN dbo.GP_APPLICATION ga ON gs.ID_APPLICATION = ga.ID_APPLICATION 
                INNER JOIN dbo.GP_PROJET gp ON ga.ID_PROJET = gp.ID_PROJET 
            WHERE 
                gp.ID_PROJET = ` + idProjet + ` 
            GROUP BY 
                gs.ID_SPRINT, gs.LIBELLE,  ga.LIBELLE, gp.LIBELLE, gs.DATE_DEBUT_PLANIFIER, gs.DATE_FIN_PLANIFIER `
    },

    getSprintsEnCours: () => {
        return ` 
            SELECT 
                '#'+CAST(gs.ID_SPRINT AS VARCHAR(12))+' - '+ gs.LIBELLE AS VALUESP,gs.ID_SPRINT, gs.LIBELLE 
                , ga.LIBELLE AS APPLICATIONLIB, gp.LIBELLE AS PROJETLIB,gp.ID_PROJET, gs.DATE_DEBUT_PLANIFIER AS DATE_DEBUT, gs.DATE_FIN_PLANIFIER AS DATE_FIN,
                Equipes = STUFF (( 
                    SELECT DISTINCT ' - '+NOM FROM dbo.GP_USER_STORY gustuff INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au
                    ON au.ID_UTILISATEUR = gustuff.ID_DEVELOPPEUR WHERE gustuff.ID_SPRINT = gs.ID_SPRINT
                    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'') ,
                COUNT((CASE WHEN gus.DATE_FIN IS NULL THEN gus.ID_USER_STORY END)) AS NBR_USER_NON_TERMINER
            FROM 
                dbo.GP_SPRINT gs INNER JOIN dbo.GP_APPLICATION ga ON gs.ID_APPLICATION = ga.ID_APPLICATION 
                INNER JOIN dbo.GP_PROJET gp ON ga.ID_PROJET = gp.ID_PROJET 
                INNER JOIN GP_USER_STORY gus ON gus.ID_SPRINT = gs.ID_SPRINT
            GROUP BY 
                gs.ID_SPRINT, gs.LIBELLE,  ga.LIBELLE, gp.LIBELLE, gs.DATE_DEBUT_PLANIFIER, gs.DATE_FIN_PLANIFIER, gp.ID_PROJET
            HAVING 
                COUNT((CASE WHEN gus.DATE_FIN IS NULL THEN gus.ID_USER_STORY END)) > 0 `
    },

    getGant: (idprojet) => {
        return
        ' SELECT gs.ID_SPRINT, gs.LIBELLE ' +
        '    , gs.DATE_DEBUT_PLANIFIER AS DATE_DEBUT, gs.DATE_FIN_PLANIFIER AS DATE_FIN, ' +
        '    Equipes = STUFF (( ' +
        '        SELECT DISTINCT ' - '+NOM FROM dbo.GP_USER_STORY gustuff INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au ' +
        ' ON au.ID_UTILISATEUR = gustuff.ID_DEVELOPPEUR WHERE gustuff.ID_SPRINT = gs.ID_SPRINT ' +
        ' FOR XML PATH(\'\'), TYPE).value(\'.\', \'NVARCHAR(MAX)\'),2,1,\'\') , ' +
        ' ROUND((CAST(SUM(ISNULL((CASE WHEN gus.DATE_FIN IS NOT NULL THEN gus.POINT_JOCKER_PLANING ELSE 0 END),0) * gs.COEFFICIENT_JOCKER_PLANING ) AS FLOAT) /CAST(SUM(ISNULL(gus.POINT_JOCKER_PLANING,0) * gs.COEFFICIENT_JOCKER_PLANING ) AS FLOAT)*100),2) AS AVANCEMENT ' +
        ' FROM dbo.GP_SPRINT gs INNER JOIN dbo.GP_APPLICATION ga ON gs.ID_APPLICATION = ga.ID_APPLICATION ' +
        ' INNER JOIN dbo.GP_PROJET gp ON ga.ID_PROJET = gp.ID_PROJET ' +
        ' INNER JOIN GP_USER_STORY gus ON gus.ID_SPRINT = gs.ID_SPRINT ' +
        ' WHERE gp.ID_PROJET = ' + idprojet +
        ' GROUP BY gs.ID_SPRINT, gs.LIBELLE, gs.DATE_DEBUT_PLANIFIER, gs.DATE_FIN_PLANIFIER '
    },

    getUserStoriesByFilter: (idprojet, iddeveloppeur, idapplication, idsprint, terminer, retro, encours, nonplanifie) => {
        let query =
            ' SELECT ROUND(CAST(((CASE WHEN gs.COEFFICIENT_JOCKER_PLANING IS NULL THEN 0 ELSE gs.COEFFICIENT_JOCKER_PLANING END) * gus.POINT_JOCKER_PLANING) as float) / 8,2) AS JH, gus.POINT_JOCKER_PLANING,gus.ID_USER_STORY, gus.DESCRIPTION, gs.Libelle AS SPRINT, gs.DATE_DEBUT_PLANIFIER, gs.DATE_FIN_PLANIFIER,\n' +
            '         ga.LIBELLE AS APPLICATION, au. nom, gus.ID_DEVELOPPEUR, \n' +
            '         (CASE WHEN gus.ID_USER_STORY_PREVIOUS IS NULL THEN \'NON RETRO\' ELSE \'RETRO\' END) AS RETRO, FORMAT(gus.DATE_DEBUT,\'yyyy-MM-dd, hh:mm tt\') AS DATE_DEBUT, FORMAT(gus.DATE_FIN,\'yyyy-MM-dd, hh:mm tt\') AS DATE_FIN' +
            '         ,(CASE WHEN gus.DATE_FIN IS NOT NULL THEN \'Terminer\' ELSE NULL END) AS terminer\n' +
            '         ,(CASE WHEN gus.DATE_FIN IS NULL AND gus.DATE_DEBUT IS NOT NULL THEN \'ENCOUR\' ELSE NULL END) AS encour\n' +
            '         ,(CASE WHEN gus.DATE_DEBUT IS NULL THEN \'Non Planifier\' ELSE NULL END) as planifier\n' +
            '         ,projet.SCRUM_MASTER, projet.ID_PROJET, ga.ID_APPLICATION, gus.ID_SPRINT' +
            '         FROM dbo.GP_USER_STORY gus' +
            '         LEFT OUTER JOIN dbo.GP_SPRINT gs ON gs.ID_SPRINT = gus.ID_SPRINT ' +
            '         INNER JOIN dbo.GP_APPLICATION ga ON gus.ID_APPLICATION = ga.ID_APPLICATION ' +
            '         INNER JOIN dbo.GP_PROJET projet ON projet.ID_PROJET = ga.ID_PROJET  \n' +
            '         LEFT OUTER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au ON au.ID_UTILISATEUR = gus.ID_DEVELOPPEUR  WHERE 1 = 1 ';
        if (idprojet > 0) {
            query += ' AND ga.ID_PROJET = ' + idprojet;
        }
        if (iddeveloppeur > 0) {
            query += ' AND gus.ID_DEVELOPPEUR = ' + iddeveloppeur;
        }
        if (idapplication > 0) {
            query += ' AND  gus.ID_APPLICATION = ' + idapplication;
        }
        if (idsprint > 0) {
            query += ' AND  gs.ID_SPRINT = ' + idsprint;
        }
        if (terminer === 'true') {
            query += ' AND ( gus.DATE_FIN IS NOT NULL) ';
        }
        if (retro === 'true') {
            query += ' AND gus.ID_USER_STORY_PREVIOUS IS NOT NULL ';
        }
        if (encours === 'true') {
            query += ' AND gus.DATE_FIN IS NULL AND gus.DATE_DEBUT IS NOT NULL ';
        }
        if (nonplanifie === 'true') {
            query += ' AND gus.DATE_DEBUT IS NULL ';
        }
        query += ' ORDER BY gus.ID_USER_STORY ASC ';

        return query
    },

    getTasks: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req =
            `
            
(SELECT 
                gus.ID_USER_STORY , gus.DESCRIPTION, gus.date_debut, gus.date_fin,  au.NOM, (CASE WHEN gus.ID_USER_STORY_PREVIOUS IS NULL THEN 0 ELSE 1 END) AS RETARD, 
                gus.DATE_CREATION_SYSTEME, cast('projet' as varchar(12)) AS TYPETACHE , ga.LIBELLE AS application, gpp.LIBELLE AS LIBELLE_PROJET 
            
            FROM 
             GP_PROJET gpp INNER JOIN dbo.GP_APPLICATION ga 
             ON gpp.ID_PROJET = ga.ID_PROJET 
             INNER JOIN dbo.GP_USER_STORY gus 
             ON ga.ID_APPLICATION = gus.ID_APPLICATION AND gus.ID_DEVELOPPEUR IS NOT NULL 
             INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au ON au.ID_UTILISATEUR = gus.ID_DEVELOPPEUR 
             LEFT OUTER JOIN dbo.GP_SPRINT gs 
             ON gs.ID_SPRINT = gus.ID_SPRINT
             WHERE gus.DATE_DEBUT BETWEEN '` + datedebut + `' AND '` + datefin + `' OR gus.DATE_FIN BETWEEN '` + datedebut + `' AND '` + datefin + `')  
			 
			 UNION
(SELECT 
                        id, cast(task as varchar(max)), datedebut, solvedate as datefin,intervenant,cast(0 as int),datedebut, typetask, application,cast('Non Definie' as varchar(12))
                    FROM 
                        openquery(MYSQL,'
                                            select
                                                gt.date, CONCAT(gt.name, " : ", gt.content) as task,gt.id , CONCAT(gu.firstname," " , gu.realname) as intervenant, gt.date as datedebut, gt.solvedate, gs.name as application, gt.type,(case when gt.type = 1 then "incident" else "demande" end) as typetask
                                            from
                                                glpi_tickets gt 
												INNER JOIN glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
												INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                                    AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
												LEFT OUTER JOIN glpi_items_tickets git ON git.tickets_id = gt.id and git.itemtype = "software"
												LEFT OUTER JOIN glpi_softwares gs ON gs.id = git.items_id 
                                            WHERE
                                                (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `) OR (gt.solvedate BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)
                                        '
                                    ))
            `;
        return req;
    },

    getGantTasks: (idProjet) => {
        return `SELECT gs.ID_SPRINT, gs.LIBELLE, gs.DATE_DEBUT_PLANIFIER, gs.DATE_FIN_PLANIFIER, gus.ID_USER_STORY, (CASE WHEN gus.DATE_DEBUT IS NULL THEN gs.DATE_DEBUT_PLANIFIER ELSE gus.DATE_DEBUT END) AS DATE_DEBUT_US, 
         (CASE WHEN gus.DATE_FIN IS NULL THEN gs.DATE_FIN_PLANIFIER ELSE gus.DATE_FIN END) AS DATE_FIN_US, gus.DESCRIPTION, (CASE WHEN gus.DATE_FIN IS NULL THEN 0 ELSE 100 END) AS AVANECEMENT, 
         ROUND((CAST(SUM(ISNULL((CASE WHEN guss.DATE_FIN IS NOT NULL THEN guss.POINT_JOCKER_PLANING ELSE 0 END),0) * gs.COEFFICIENT_JOCKER_PLANING ) AS FLOAT) / 
         CAST(SUM(ISNULL(guss.POINT_JOCKER_PLANING,0) * gs.COEFFICIENT_JOCKER_PLANING ) AS FLOAT)*100),2) AS AVANCEMENT_SPRINT, au.NOM AS DEVELOPPEUR, EQUIPE =  STUFF (( 
         SELECT DISTINCT ' - '+NOM FROM dbo.GP_USER_STORY gustuff INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au ON au.ID_UTILISATEUR = gustuff.ID_DEVELOPPEUR WHERE gustuff.ID_SPRINT = gs.ID_SPRINT 
         FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),2,1,'')  FROM GP_SPRINT gs INNER JOIN GP_APPLICATION ga ON gs.ID_APPLICATION = ga.ID_APPLICATION 
     INNER JOIN GP_USER_STORY gus ON gus.ID_SPRINT = gs.ID_SPRINT 
     INNER JOIN GP_USER_STORY guss ON guss.ID_SPRINT = gs.ID_SPRINT 
     INNER JOIN BD_INTEGRALE_PROD.DBO.A_UTILISATEUR au ON au.ID_UTILISATEUR = gus.ID_DEVELOPPEUR 
     WHERE 
     ID_PROJET =  ` + idprojet + `
     GROUP BY 
     gs.ID_SPRINT, gs.LIBELLE, gs.DATE_DEBUT_PLANIFIER, gs.DATE_FIN_PLANIFIER, 
        gus.ID_USER_STORY, (CASE WHEN gus.DATE_DEBUT IS NULL THEN gs.DATE_DEBUT_PLANIFIER ELSE gus.DATE_DEBUT END), 
         (CASE WHEN gus.DATE_FIN IS NULL THEN gs.DATE_FIN_PLANIFIER ELSE gus.DATE_FIN END) , gus.DESCRIPTION, 
             (CASE WHEN gus.DATE_FIN IS NULL THEN 0 ELSE 100 END) , au.NOM`;
    },

    getEquipeProjet: (idProjet) => {
        return `SELECT ID_UTILISATEUR, NOM  FROM GP_EQUIPE_PROJET GPEP INNER JOIN A_UTILISATEUR AU ON 
                GPEP.ID_MEMBRE_EQUIPE = AU.ID_UTILISATEUR WHERE ID_PROJET = ` + idProjet;
    },

    isHaveIncompleteTask: (idProjet, idDeveleoppeur) => {
        return `SELECT COUNT(*) AS tasks FROM GP_USER_STORY usrStory
                    INNER JOIN GP_SPRINT sprint on sprint.ID_SPRINT = usrStory.ID_SPRINT
                    INNER JOIN GP_APPLICATION app ON app.ID_APPLICATION = sprint.ID_APPLICATION
                    INNER JOIN GP_PROJET proj ON proj.ID_PROJET = app.ID_PROJET
                    WHERE proj.ID_PROJET = ${idProjet} AND  ID_DEVELOPPEUR = ${idDeveleoppeur} AND usrStory.DATE_FIN IS NULL AND usrStory.DATE_DEBUT IS NOT NULL `;
    },

    getticketsnonresolutlabels: () => {
        return `SELECT nbrticket, iduser, firstname, realname FROM openquery(MYSQL,'
                                                select
                                                    count(gt.id) as nbrticket, gu.id as iduser, gu.firstname, gu.realname
                                                from
                                                    glpi_tickets gt
                                                    INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                                                    INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                                        AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                                                WHERE
                                                    solvedate IS NULL  AND gt.is_deleted = 0
                                                GROUP BY
                                                    gu.id , gu.firstname, gu.realname ')`
    },

    getcumuleticketsouverts:(datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req =
        `            
                SELECT 
	                GP_CALENDER.date, (
						SELECT 
							count(id) 
						FROM (
							SELECT 
								id, dateouverture, iduser, firstname, realname, solvedate 
							FROM 
								openquery(MYSQL,'
											select
												gt.id, DATE(gt.date) as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate
											from
												glpi_tickets gt 
												INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
												INNER JOIN glpi_users gu ON gu.id = gtu.users_id
													AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
											WHERE
												(gt.date BETWEEN 20180101 AND ` + yearf+""+monthf+""+datef+ `)  AND gt.is_deleted = 0 '
								)
						) t
					WHERE
						dateouverture <= GP_CALENDER.date AND (solvedate > GP_CALENDER.date OR solvedate IS NULL)
				    ) as cumuleticketsnosolved
                FROM 
	                GP_CALENDER 
                WHERE 
	                date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef+ `'
        `
        return req;
    },

    getheureintervention:(datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
            SELECT 
                WEEKNUMBER, YEARDATE, NUMWEEK,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
            FROM (
                SELECT 
	                CONCAT(firstname,' ',realname) AS INTERVENANT, WEEKNUMBER, ISNULL(chargeheurebydev,0) AS chargeheurebydev ,  YEARDATE, NUMWEEK
                FROM 
	                (select 
		                iduser, firstname, realname, WEEKNUMBER , YEARDATE, NUMWEEK
	                from
		                (SELECT 
			                iduser, firstname, realname FROM openquery(MYSQL,'
				                select 
				                    gu.id as iduser, gu.firstname, gu.realname 
				                from 
				                    glpi_users gu 
				                where 
				                    gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		                ) t_user 
			            cross join
		                (SELECT 
			                DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , YEAR(date) YEARDATE, DATENAME(ww,date) AS NUMWEEK
		                FROM 
			                GP_CALENDER 
			            WHERE 
			                date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		            ) t_calendar
	            ) T_USER_DATE
	            LEFT OUTER JOIN
	            (SELECT  
		            weekintervention,(SUM(cast(actiontime as float))/60)/60 AS chargeheurebydev, iduser 
	            FROM
		            (SELECT 
			            id, cast(YEAR(dateintervantion) as varchar(4))+'-'+cast(DATENAME(ww,dateintervantion) as varchar(2)) as weekintervention , iduser, actiontime 
		            FROM 
		                openquery(MYSQL,'
			                            select 
			                                gt.id,gu.id as iduser, gtt.date as dateintervantion, gtt.actiontime 
			                            from 
				                            glpi_tickets gt INNER JOIN glpi_tickettasks gtt ON gt.id = gtt.tickets_id 
				                            INNER JOIN glpi_users gu ON gu.id = gtt.users_id_tech 
				                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
			                            WHERE 
				                            (gtt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `  AND gt.is_deleted = 0 )
				    ')
		        ) t 
		        GROUP BY 
		            weekintervention, iduser
	        ) T_TICKET_WEEKLY_USER
	            ON T_TICKET_WEEKLY_USER.weekintervention = T_USER_DATE.WEEKNUMBER AND T_TICKET_WEEKLY_USER.iduser = T_USER_DATE.iduser
            ) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(chargeheurebydev)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY  YEARDATE ASC, CAST(NUMWEEK as int) ASC
        `
        return req
    },

    getticketouvert:(datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
            SELECT 
                WEEKNUMBER, YEARDATE, NUMWEEK,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT 
	CONCAT(firstname,' ',realname) AS INTERVENANT, WEEKNUMBER, ISNULL(NOMBRETICKETOUVERT,0) AS NOMBRETICKETOUVERT 
	, yeardate, numweek
FROM 
	(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
	(SELECT  
		ouvertweeknumber,count(id) AS NOMBRETICKETOUVERT, iduser 
	FROM
		(SELECT 
			id, cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) as ouvertweeknumber , 
			iduser, firstname, realname, cast(YEAR(solvedate) as varchar(4))+'-'+cast(DATENAME(ww,solvedate) as varchar(2)) as solvetweeknumber 
		FROM openquery(MYSQL,'
                                            select
                                                gt.id, gt.date, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate
                                            from
												glpi_tickets gt 
												INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
												INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                                    AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                                            WHERE
                                                (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `  AND gt.is_deleted = 0 ) 
                                        '
                                    )
		) t GROUP BY ouvertweeknumber, iduser
	) T_TICKET_WEEKLY_USER
	ON T_TICKET_WEEKLY_USER.ouvertweeknumber = T_USER_DATE.WEEKNUMBER AND T_TICKET_WEEKLY_USER.iduser = T_USER_DATE.iduser
	
	) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NOMBRETICKETOUVERT)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY  YEARDATE ASC, CAST(NUMWEEK as int) ASC
        `
        return req
    },

    getticketsresolut:(datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
            SELECT 
                WEEKNUMBER, YEARDATE, NUMWEEK,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT 
	CONCAT(firstname,' ',realname) AS INTERVENANT, WEEKNUMBER, ISNULL(NOMBRETICKETSOLVE,0) AS NOMBRETICKETSOLVE 
	,yeardate, numweek
FROM 
	(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER 
			, year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef+ `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
	(SELECT  
		solvetweeknumber,count(id) AS NOMBRETICKETSOLVE, iduser 
	FROM
		(SELECT 
			id, cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) as ouvertweeknumber , 
			iduser, firstname, realname, cast(YEAR(solvedate) as varchar(4))+'-'+cast(DATENAME(ww,solvedate) as varchar(2)) as solvetweeknumber 
		FROM openquery(MYSQL,'
                               select
                                    gt.id, gt.date, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate
                               from
									glpi_tickets gt 
									INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
									INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                        AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                               WHERE
                                    (gt.solvedate BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `  AND gt.is_deleted = 0 ) 
                                        '
                                    )
		) t GROUP BY solvetweeknumber, iduser
	) T_TICKET_WEEKLY_USER
	ON T_TICKET_WEEKLY_USER.solvetweeknumber = T_USER_DATE.WEEKNUMBER AND T_TICKET_WEEKLY_USER.iduser = T_USER_DATE.iduser
	
	) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NOMBRETICKETSOLVE)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY  YEARDATE ASC, CAST(NUMWEEK as int) ASC
        `
        return req
    },

    getqualitetickets:(datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
SELECT 
	WEEKNUMBER, YEARDATE, WEEKNUM,

	[R. F.AITAADDI] RFAITAADDI,[R. S.HOUSNI] RSHOUSNI,[R. F.ELGUERMOUMI] RFELGUERMOUMI,[R. H.ELAIDI] RHELAIDI,[R. T.MAJID] RTMAJID,
	[R. A.BOUDA] RABOUDA,[R. M.ELBERZIZ] RMELBERZIZ,[R. S.ELGUARAH] RSELGUARAH,[R. K.AITABDELOUAHD] RKAITABDELOUAHD,[R. M.HAKEM] RMHAKEM,[R. A.AITOUMZIL] RAAITOUMZIL,
	[R. Z.AITAADDI] RZAITAADDI,[R. M.OULCAID] RMOULCAID,[R. I.BOUGROUM] RIBOUGROUM,[R. S.MARAR] AS RSMARAR,[R. E.BOUBDIH] REBOUBDIH,[R. A.BELFAQIR] AS RABELFAQIR,
	([R. F.AITAADDI]+[R. S.HOUSNI]+[R. F.ELGUERMOUMI]+[R. H.ELAIDI]+[R. T.MAJID]+[R. A.BOUDA]+[R. M.ELBERZIZ]+[R. S.ELGUARAH]+
	[R. K.AITABDELOUAHD]+[R. M.HAKEM]+[R. A.AITOUMZIL]+[R. Z.AITAADDI]+[R. M.OULCAID]+[R. I.BOUGROUM]+[R. S.MARAR]+
	[R. E.BOUBDIH]+[R. A.BELFAQIR]) AS RGLOBAL,

	[O. F.AITAADDI] AS OFAITAADDI,[O. S.HOUSNI] OSHOUSNI,[O. F.ELGUERMOUMI] OFELGUERMOUMI,[O. H.ELAIDI] OHELAIDI,[O. T.MAJID] AS OTMAJID,
	[O. A.BOUDA] OABOUDA,[O. M.ELBERZIZ] OMELBERZIZ,[O. S.ELGUARAH] OSELGUARAH,[O. K.AITABDELOUAHD] OKAITABDELOUAHD,[O. M.HAKEM] OMHAKEM,[O. A.AITOUMZIL] OAAITOUMZIL,
	[O. Z.AITAADDI] AS OZAITAADDI,[O. M.OULCAID] OMOULCAID,[O. I.BOUGROUM] OIBOUGROUM,[O. S.MARAR] OSMARAR,[O. E.BOUBDIH] OEBOUBDIH,[O. A.BELFAQIR] OABELFAQIR,
	([O. F.AITAADDI]+[O. S.HOUSNI]+[O. F.ELGUERMOUMI]+[O. H.ELAIDI]+[O. T.MAJID]+[O. A.BOUDA]+[O. M.ELBERZIZ]+[O. S.ELGUARAH]+[O. K.AITABDELOUAHD]+[O. M.HAKEM]+[O. A.AITOUMZIL]+[O. Z.AITAADDI]+[O. M.OULCAID]+[O. I.BOUGROUM]+[O. S.MARAR]+[O. E.BOUBDIH]+[O. A.BELFAQIR]) AS OGLOBAL
FROM
(

SELECT  
	intervenant, yeardate, weeknum, WEEKNUMBER, NOMBRETICKET
FROM
(
SELECT 
	T_USER_DATE.iduser, concat('R. ',substring(firstname,0,2),'.',replace(replace(realname,' ',''),'-','')) as intervenant, WEEKNUMBER, ISNULL(NOMBRETICKETSOLVE,0) AS NOMBRETICKET,
	yeardate, weeknum 
FROM 
	(select 
		iduser, firstname, realname, WEEKNUMBER , yeardate, weeknum
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , 
			year(date) yeardate, cast(DATENAME(ww, date) as varchar(2)) as weeknum
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
	(SELECT  
		solvetweeknumber,count(id) AS NOMBRETICKETSOLVE, iduser 
	FROM
		(SELECT 
			id, cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) as ouvertweeknumber , 
			iduser, firstname, realname, cast(YEAR(solvedate) as varchar(4))+'-'+cast(DATENAME(ww,solvedate) as varchar(2)) as solvetweeknumber 
		FROM openquery(MYSQL,'
                               select
                                    gt.id, gt.date, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate
                               from
									glpi_tickets gt 
									INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
									INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                        AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                               WHERE
                                    (gt.solvedate BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0
                                        '
                                    )
		) t GROUP BY solvetweeknumber, iduser
	) T_TICKET_WEEKLY_USER
	ON T_TICKET_WEEKLY_USER.solvetweeknumber = T_USER_DATE.WEEKNUMBER AND T_TICKET_WEEKLY_USER.iduser = T_USER_DATE.iduser

UNION 


SELECT 
	T_USER_DATE.iduser, concat('O. ',substring(firstname,0,2),'.',replace(replace(realname,' ',''),'-','')) as intervenant, WEEKNUMBER, ISNULL(NOMBRETICKETOUVERT,0) AS NOMBRETICKET ,
	yeardate, weeknum 
FROM 
	(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, weeknum 
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER ,
			year(date) yeardate, cast(DATENAME(ww,date) as varchar(2)) weeknum 
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
	(SELECT  
		ouvertweeknumber,count(id) AS NOMBRETICKETOUVERT, iduser 
	FROM
		(SELECT 
			id, cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) as ouvertweeknumber , 
			iduser, firstname, realname, cast(YEAR(solvedate) as varchar(4))+'-'+cast(DATENAME(ww,solvedate) as varchar(2)) as solvetweeknumber 
		FROM openquery(MYSQL,'
                                            select
                                                gt.id, gt.date, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate
                                            from
												glpi_tickets gt 
												INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
												INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                                    AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                                            WHERE
                                                (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0  
                                        '
                                    )
		) t GROUP BY ouvertweeknumber, iduser
	) T_TICKET_WEEKLY_USER
	ON T_TICKET_WEEKLY_USER.ouvertweeknumber = T_USER_DATE.WEEKNUMBER AND T_TICKET_WEEKLY_USER.iduser = T_USER_DATE.iduser
) T




) ORIGINAL_QEURY
PIVOT
            (
					SUM(NOMBRETICKET)
                FOR INTERVENANT IN (
		                [O. Z.AITAADDI],[R. S.MARAR],[O. T.MAJID],[O. F.AITAADDI],[R. A.BELFAQIR],
						[O. S.HOUSNI],[O. A.BOUDA],[O. S.ELGUARAH],[R. T.MAJID],[O. M.ELBERZIZ],[O. A.AITOUMZIL],[R. Z.AITAADDI],[R. A.BOUDA],
						[R. S.HOUSNI],[O. I.BOUGROUM],[O. K.AITABDELOUAHD],[R. M.OULCAID],[R. M.HAKEM],[R. F.ELGUERMOUMI],[O. S.MARAR],
						[O. M.OULCAID],[O. M.HAKEM],[O. H.ELAIDI],[O. E.BOUBDIH],[R. K.AITABDELOUAHD],[R. F.AITAADDI],[R. I.BOUGROUM],
						[O. F.ELGUERMOUMI],[R. A.AITOUMZIL],[R. S.ELGUARAH],[R. H.ELAIDI],[R. E.BOUBDIH],[R. M.ELBERZIZ],[O. A.BELFAQIR]
                )
            ) AS PIVOTED_Table			
ORDER BY cast(yeardate as int), cast(weeknum as int)
        `
        return req
    },

    getallopentickets:(datedebut, datefin) =>{
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req =
        `
    SELECT
        nbrticket, iduser, firstname, realname
    FROM
    openquery(MYSQL,'
    select
    count(gt.id) as nbrticket, gu.id as iduser, gu.firstname, gu.realname
from
glpi_tickets gt
INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
INNER JOIN glpi_users gu ON gu.id = gtu.users_id
AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
WHERE
date between ` + yeard+""+monthd+""+dated + ` and ` + yearf+""+monthf+""+datef + `  AND gt.is_deleted = 0
GROUP BY
gu.id , gu.firstname, gu.realname '
)`
        return req
    },

    gettempsinterventionglobal:(datedebut, datefin) =>{
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req =
            `
                SELECT 
	                weeknumber,yeardate, weeknum,Unjours,deuxjours,cinqjours,huitjours,traisejours,supatraisejours,nonresolut 
                FROM                    
                (
                SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					cast(year(dateouverture) as int) yeardate,  cast(DATENAME(ww, dateouverture) as int) weeknum,
                    (COUNT((CASE WHEN cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 <= 1 THEN '1' END)) / CAST(COUNT(id) as float))*100 AS Unjours,
                    (COUNT((CASE WHEN cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 1 AND 2 THEN '2' END)) / CAST(COUNT(id) as float))*100 AS deuxjours,
                    (COUNT((CASE WHEN cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 2 AND 5 THEN '2-5' END)) / CAST(COUNT(id) as float))*100 AS cinqjours,
                    (COUNT((CASE WHEN cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 5 AND 8 THEN '5-8' END)) / CAST(COUNT(id) as float))*100 AS huitjours,
                    (COUNT((CASE WHEN cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 8 AND 13 THEN '8-13' END)) / CAST(COUNT(id) as float))*100 AS traisejours,
                    (COUNT((CASE WHEN (cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 > 13) THEN '>13' END)) / CAST(COUNT(id) as float))*100 AS supatraisejours,
                    (COUNT((CASE WHEN solvedate is null THEN 'Not solved' END)) / CAST(COUNT(id) as float))*100  AS nonresolut
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)
                    ')
                GROUP BY
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture)
					) T
					ORDER BY
                    yeardate,  weeknum
                `;
        return req;
    },

    gettempintervunjours: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
                SELECT 
                WEEKNUMBER, yeardate, numweek,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT CONCAT(firstname,' ' ,realname) AS INTERVENANT, T_USER_DATE.WEEKNUMBER, ISNULL(NBRTICKET, 0) AS NBRTICKET,yeardate, numweek FROM
(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
                (SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					count(*) AS NBRTICKET, iduser
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0
                    ')
				WHERE cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 <= 1
                GROUP BY 
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture), firstname, realname, iduser
					) T ON T.weeknumber = T_USER_DATE.WEEKNUMBER AND T.iduser = T_USER_DATE.iduser
) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NBRTICKET)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY CAST(yeardate AS INT), CAST(numweek AS INT)

        `
        return req;
    },

    gettempintervdeuxjours: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
                SELECT 
                WEEKNUMBER, yeardate, numweek,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT CONCAT(firstname,' ' ,realname) AS INTERVENANT, T_USER_DATE.WEEKNUMBER, ISNULL(NBRTICKET, 0) AS NBRTICKET,yeardate, numweek FROM
(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
                (SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					count(*) AS NBRTICKET, iduser
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0
                    ')
				WHERE 
				cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 1 AND 2
                GROUP BY 
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture), firstname, realname, iduser
					) T ON T.weeknumber = T_USER_DATE.WEEKNUMBER AND T.iduser = T_USER_DATE.iduser
) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NBRTICKET)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY CAST(yeardate AS INT), CAST(numweek AS INT)

        `
        return req;
    },

    gettempintervcinqjours: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
                SELECT 
                WEEKNUMBER, yeardate, numweek,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT CONCAT(firstname,' ' ,realname) AS INTERVENANT, T_USER_DATE.WEEKNUMBER, ISNULL(NBRTICKET, 0) AS NBRTICKET,yeardate, numweek FROM
(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
                (SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					count(*) AS NBRTICKET, iduser
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0
                    ')
				WHERE 
				cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 2 AND 5
                GROUP BY 
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture), firstname, realname, iduser
					) T ON T.weeknumber = T_USER_DATE.WEEKNUMBER AND T.iduser = T_USER_DATE.iduser
) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NBRTICKET)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY CAST(yeardate AS INT), CAST(numweek AS INT)

        `
        return req;
    },

    gettempintervhuitjours: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
                SELECT 
                WEEKNUMBER, yeardate, numweek,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT CONCAT(firstname,' ' ,realname) AS INTERVENANT, T_USER_DATE.WEEKNUMBER, ISNULL(NBRTICKET, 0) AS NBRTICKET,yeardate, numweek FROM
(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
                (SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					count(*) AS NBRTICKET, iduser
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0 
                    ')
				WHERE 
				cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 5 AND 8
                GROUP BY 
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture), firstname, realname, iduser
					) T ON T.weeknumber = T_USER_DATE.WEEKNUMBER AND T.iduser = T_USER_DATE.iduser
) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NBRTICKET)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY CAST(yeardate AS INT), CAST(numweek AS INT)

        `
        return req;
    },

    gettempintervtraisejours: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
                SELECT 
                WEEKNUMBER, yeardate, numweek,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT CONCAT(firstname,' ' ,realname) AS INTERVENANT, T_USER_DATE.WEEKNUMBER, ISNULL(NBRTICKET, 0) AS NBRTICKET,yeardate, numweek FROM
(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
                (SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					count(*) AS NBRTICKET, iduser
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0
                    ')
				WHERE 
				cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 BETWEEN 8 AND 13
                GROUP BY 
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture), firstname, realname, iduser
					) T ON T.weeknumber = T_USER_DATE.WEEKNUMBER AND T.iduser = T_USER_DATE.iduser
) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NBRTICKET)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY CAST(yeardate AS INT), CAST(numweek AS INT)

        `
        return req;
    },

    gettempintervsuojours: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
                SELECT 
                WEEKNUMBER, yeardate, numweek,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT CONCAT(firstname,' ' ,realname) AS INTERVENANT, T_USER_DATE.WEEKNUMBER, ISNULL(NBRTICKET, 0) AS NBRTICKET,yeardate, numweek FROM
(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
                (SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					count(*) AS NBRTICKET, iduser
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0
                    ')
				WHERE 
				(cast(DATEDIFF(hh, dateouverture, solvedate) as float)/24 > 13)
                GROUP BY 
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture), firstname, realname, iduser
					) T ON T.weeknumber = T_USER_DATE.WEEKNUMBER AND T.iduser = T_USER_DATE.iduser
) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NBRTICKET)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY CAST(yeardate AS INT), CAST(numweek AS INT)

        `
        return req;
    },

    gettempintervnonresolut: (datedebut, datefin) => {
        let datedebutDate = new Date(datedebut)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();


        let datefinDate = new Date(datefin)
        let datef = ("0" + datefinDate.getDate()).slice(-2);
        let monthf = ("0" + (datefinDate.getMonth() + 1)).slice(-2);
        let yearf = datefinDate.getFullYear();

        let req = `
                SELECT 
                WEEKNUMBER, yeardate, numweek,
                [Fatima ez-zahra AIT AADDI] AS FatimaezzahraAITAADDI,[Saad HOUSNI] AS SaadHOUSNI,
		        [Fatima ELGUERMOUMI] AS FatimaELGUERMOUMI,[Hassan ELAIDI] AS HassanELAIDI,[Tarik MAJID] AS TarikMAJID,
		        [Abderrazaq BOUDA] AS AbderrazaqBOUDA,[Mourad ELBERZIZ] AS MouradELBERZIZ,[Soufian EL GUARAH] AS SoufianELGUARAH,
		        [Khadija AIT ABDELOUAHD] AS KhadijaAITABDELOUAHD,[Moad HAKEM] AS MoadHAKEM,[Ayoub AIT OUMZIL] AS AyoubAITOUMZIL,
		        [Zakaria AIT AADDI] AS ZakariaAITAADDI,[Mohamed OULCAID] AS MohamedOULCAID,[Ilyasse BOUGROUM] AS IlyasseBOUGROUM,
		        [Soufiane MARAR] AS SoufianeMARAR,[Elmahdi BOUBDIH] AS ElmahdiBOUBDIH,[Abdelhafid BELFAQIR] AS AbdelhafidBELFAQIR
FROM (
SELECT CONCAT(firstname,' ' ,realname) AS INTERVENANT, T_USER_DATE.WEEKNUMBER, ISNULL(NBRTICKET, 0) AS NBRTICKET,yeardate, numweek FROM
(select 
		iduser, firstname, realname, WEEKNUMBER ,yeardate, numweek
	from
		(SELECT 
			iduser, firstname, realname FROM openquery(MYSQL,'
				select gu.id as iduser, gu.firstname, gu.realname from glpi_users gu where 
				gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)  ')
		) t_user 
			cross join
		(SELECT 
			DISTINCT cast(YEAR(date) as varchar(4))+'-'+cast(DATENAME(ww,date) as varchar(2)) AS WEEKNUMBER , year(date) yeardate, DATENAME(ww,date) as numweek
		FROM 
			GP_CALENDER WHERE date BETWEEN '` + yeard+""+monthd+""+dated + `' and '` + yearf+""+monthf+""+datef + `'
		) t_calendar
	) T_USER_DATE
	LEFT OUTER JOIN
                (SELECT
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)) as weeknumber,
					count(*) AS NBRTICKET, iduser
                FROM
                    openquery(MYSQL,'
                        select
                            gt.id, gt.date as dateouverture, gu.id as iduser, gu.firstname, gu.realname, gt.solvedate as solvedate
                        from
                            glpi_tickets gt
                            INNER join glpi_tickets_users gtu ON gtu.tickets_id = gt.id AND gtu.type = 2
                            INNER JOIN glpi_users gu ON gu.id = gtu.users_id
                                AND gu.id IN (829,1958,1289,1957,1157,2112,1288,1058,1287,869,1956,836,1062,2110,2113,2142,2133)
                        WHERE
                            (gt.date BETWEEN ` + yeard+""+monthd+""+dated + ` AND ` + yearf+""+monthf+""+datef + `)  AND gt.is_deleted = 0
                    ')
				WHERE 
				solvedate is null
                GROUP BY 
                    concat(year(dateouverture),'-',DATENAME(ww, dateouverture)), year(dateouverture), DATENAME(ww, dateouverture), firstname, realname, iduser
					) T ON T.weeknumber = T_USER_DATE.WEEKNUMBER AND T.iduser = T_USER_DATE.iduser
) ORIGINAL_QEURY
            PIVOT
            (
	            SUM(NBRTICKET)
                FOR INTERVENANT IN (
		                [Fatima ez-zahra AIT AADDI],[Saad HOUSNI],[Fatima ELGUERMOUMI],[Hassan ELAIDI],[Tarik MAJID],[Abderrazaq BOUDA],
		                [Mourad ELBERZIZ],[Soufian EL GUARAH],[Khadija AIT ABDELOUAHD],[Moad HAKEM],[Ayoub AIT OUMZIL],[Zakaria AIT AADDI],
		                [Mohamed OULCAID],[Ilyasse BOUGROUM],[Soufiane MARAR],[Elmahdi BOUBDIH],[Abdelhafid BELFAQIR]
                )
            ) AS PIVOTE_HEURE_INTERVENTION
			ORDER BY CAST(yeardate AS INT), CAST(numweek AS INT)

        `
        return req;
    },

};

