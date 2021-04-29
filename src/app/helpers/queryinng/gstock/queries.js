'use strict';

module.exports = {
    getprixarticle:() => {
        return `            
	SELECT NULL AS ID_ARTICLE, NULL AS CLE_AX, NULL AS LIBELLE, NULL AS ID_UNITE_STOCK, NULL AS REF_UNITE,
	    NULL AS PRIX_UNITE, NULL AS DATE_DEBUT, NULL AS DATE_FIN,
	    NULL AS DATE_HEURE_SAISIE, NULL AS ID_OP_SAISIE, NULL AS NOM, NULL AS ID_PRIX
    UNION
    SELECT PA.ID_ARTICLE, CLE_AX, LIBELLE, ID_UNITE_STOCK, REF_UNITE
		,PRIX_UNITE,DATE_DEBUT,DATE_FIN
		,DATE_HEURE_SAISIE,ID_OP_SAISIE, AU.NOM,ID_PRIX
	FROM ST_PRIX_PRODUCTION_ARTICLE STPPA INNER JOIN P_ARTICLE PA ON STPPA.ID_ARTICLE = PA.ID_ARTICLE
		INNER JOIN P_UNITE PU ON PU.ID_UNITE = STPPA.ID_UNITE_STOCK
		INNER JOIN A_UTILISATEUR AU ON AU.ID_UTILISATEUR = STPPA.ID_OP_SAISIE

        `;
    },

    getMaxDateFinPrixByArt:(ID_ARTICLE) => {
        return `
        SELECT
        MAX(DATE_FIN) AS MAX_DATE_FIN
        FROM
        ST_PRIX_PRODUCTION_ARTICLE
        WHERE
        ID_ARTICLE = `+ID_ARTICLE
    },
  // -------**** Inventaire Journalier***----------

    findMesEntrepot:(idMagasinier) => {
        return `
        SELECT 
            P_ENTREPOT.ID_ENTREPOT, P_ENTREPOT.REF_ENTREPOT+' | '+P_ENTREPOT.ENTREPOT AS ENTREPOT, P_ENTREPOT.REF_ENTREPOT 
        FROM 
            ST_ENTREPOT_MAGASINIER inner join P_ENTREPOT 
                ON ST_ENTREPOT_MAGASINIER.ID_ENTREPOT = P_ENTREPOT.ID_ENTREPOT
        WHERE 
            CREATE_PHYSICAL_INV = 1 AND ID_MAGASINIER = ${idMagasinier}
        `;
    },

    findallEntrepots: () => {
        return 'SELECT E.ID_ENTREPOT , E.ENTREPOT ,p.NBR_ARTICLE,P.NBR_JOURS_RELANCE '+
        ' FROM P_ENTREPOT  E LEFT  JOIN ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX P '+
        ' ON E.ID_ENTREPOT=P.ID_ENTREPOT ' +
            ' WHERE ENTREPOT NOT LIKE \'%VAN%\' ORDER BY E.ENTREPOT '
    },

    findEntrepotParametres: () => {
        return 'SELECT E.ID_ENTREPOT , E.ENTREPOT  FROM P_ENTREPOT  E '+
        ' INNER JOIN ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX P '+
        ' ON E.ID_ENTREPOT=P.ID_ENTREPOT ' +
            ' where p.NBR_ARTICLE>0 AND P.NBR_JOURS_RELANCE>0 '+
        ' ORDER BY E.ENTREPOT'
    },

    findarticles: (nbrArt,ref_entrepot,nbrJr, idEntrepot) => {
        let req =
            `
                SELECT
                    DISTINCT top(${nbrArt}) newid(), P_ARTICLE.ID_ARTICLE, CLE_AX AS CLE_ARTICLE_AX, LIBELLE, 0 AS NBR
                FROM
                    STOCKERP INNER JOIN P_ARTICLE
                        ON STOCKERP.ITEMID = P_ARTICLE.CLE_AX
                WHERE 
                    warehouse = '${ref_entrepot}'
                order by 
                    newid()
            `
        return req;
    },

    findarticlesInventaire: (ID_INVENTAIRE) => {
        return `
                select 
	                IA.ID_ARTICLE,A.LIBELLE, 
	                A.CLE_AX AS CLE_ARTICLE_AX,
	                concat(cast(IA.DATE_TIME_GENERATION as date),' ', convert(varchar, IA.DATE_TIME_GENERATION, 108)) DATE_TIME_GENERATION,
	                au.NOM ,
	                STI.REF_INVENTAIRE,
	                (
		                select count (distinct NUM_LOT )
		                from 
			                ST_DT_INVENTAIRE D 
		                where 
			                ID_INVENTAIRE = ${ID_INVENTAIRE} and D.CLE_ARTICLE=IA.ID_ARTICLE 
	                )as NBR, STI.ID_INVENTAIRE
                from 
	                ST_INVENTAIRE_ARTICLES IA INNER JOIN [BD_INTEGRALE_PROD].dbo.P_ARTICLE A ON IA.ID_ARTICLE=A.ID_ARTICLE
	                inner join A_UTILISATEUR au ON IA.ID_OP_GENERATION = au.ID_UTILISATEUR
	                INNER JOIN ST_INVENTAIRE STI 
		            ON STI.ID_INVENTAIRE = ${ID_INVENTAIRE} AND STI.ID_INVENTAIRE = IA.ID_INVENTAIRE
                ORDER BY 
	                IA.CLE_ARTICLE_AX
            `;
    },

    terminerInvenataire: (idoper,IdInventaire) => {
        let req = `
            EXEC dbo.MAIL_AUTO  
                @idInventaire=` + IdInventaire + `, @idoper=` + idoper;
        return req
    },

    GetDetailInventaireByTypeDateEntrepot: (IDTYPE,DATEINV,IDENTR) => {
        return  `
        SELECT ar.LIBELLE,
            NUM_LOT,
            QUANTITE,
            ST_DT_INVENTAIRE.DATE_INVENTAIRE,
            REF_INVENTAIRE,
            ST_INVENTAIRE.ID_ETAT_INVENTAIRE,
            en.ENTREPOT
        FROM ST_DT_INVENTAIRE,
            ST_INVENTAIRE,
            BD_INTEGRALE_PROD.dbo.P_ARTICLE ar,
            BD_INTEGRALE_PROD.dbo.P_ENTREPOT en,
            dbo.ST_ETAT_INVENTAIRE
        WHERE CLE_ARTICLE = ar.ID_ARTICLE
            AND en.ID_ENTREPOT = ST_DT_INVENTAIRE.ID_ENTREPOT
            AND ST_ETAT_INVENTAIRE.ID_ETAT_INVENTAIRE = ST_INVENTAIRE.ID_ETAT_INVENTAIRE
            AND ST_DT_INVENTAIRE.ID_TYPE_INVENTAIRE = ST_INVENTAIRE.ID_TYPE_INVENTAIRE
            AND ST_DT_INVENTAIRE.DATE_INVENTAIRE = ST_INVENTAIRE.DATE_INVENTAIRE
            AND ST_DT_INVENTAIRE.ID_ENTREPOT = ST_INVENTAIRE.ID_ENTREPOT
            AND ST_DT_INVENTAIRE.ID_TYPE_INVENTAIRE = ${IDTYPE}
            AND ST_DT_INVENTAIRE.DATE_INVENTAIRE = '${DATEINV}'
            AND ST_DT_INVENTAIRE.ID_ENTREPOT = ${IDENTR}
          `
    },

    GetDetailInventaireByTypeDateEntrepotArticle: (IDTYPE,DATEINV,IDENTR,CLEART) => {
        return  `
        SELECT ar.LIBELLE,
            NUM_LOT,
            QUANTITE,
            ST_DT_INVENTAIRE.DATE_INVENTAIRE,
            REF_INVENTAIRE,
            ST_INVENTAIRE.ID_ETAT_INVENTAIRE,
            en.ENTREPOT,
            ST_DT_INVENTAIRE.CLE_ARTICLE
        FROM ST_DT_INVENTAIRE,
            ST_INVENTAIRE,
            BD_INTEGRALE_PROD.dbo.P_ARTICLE ar,
            BD_INTEGRALE_PROD.dbo.P_ENTREPOT en,
            dbo.ST_ETAT_INVENTAIRE
        WHERE CLE_ARTICLE = ar.ID_ARTICLE
            AND en.ID_ENTREPOT = ST_DT_INVENTAIRE.ID_ENTREPOT
            AND ST_ETAT_INVENTAIRE.ID_ETAT_INVENTAIRE = ST_INVENTAIRE.ID_ETAT_INVENTAIRE
            AND ST_DT_INVENTAIRE.ID_TYPE_INVENTAIRE = ST_INVENTAIRE.ID_TYPE_INVENTAIRE
            AND ST_DT_INVENTAIRE.DATE_INVENTAIRE = ST_INVENTAIRE.DATE_INVENTAIRE
            AND ST_DT_INVENTAIRE.ID_ENTREPOT = ST_INVENTAIRE.ID_ENTREPOT
            AND ST_DT_INVENTAIRE.ID_TYPE_INVENTAIRE = ${IDTYPE}
            AND ST_DT_INVENTAIRE.DATE_INVENTAIRE = '${DATEINV}'
            AND ST_DT_INVENTAIRE.ID_ENTREPOT = ${IDENTR}
            AND ST_DT_INVENTAIRE.CLE_ARTICLE = ${CLEART}
          `
    },

    GetInventaireByDateDebutDateFin: (DATEDEBUT,DATEFIN, idMag,isConsultAll) => {
        let req = '';

        if( isConsultAll = '0' ) {
            req =
                `
        SELECT 
        ID_INVENTAIRE,
            REF_INVENTAIRE,
            ENTREPOT,
            DATE_INVENTAIRE,
            ETAT_INVENTAIRE,
            NOM,
            STI.ID_TYPE_INVENTAIRE,
            STI.ID_ENTREPOT,
            STI.ID_ETAT_INVENTAIRE,
            STTI.TYPE_INVENTAIRE 
		FROM 
	ST_ENTREPOT_MAGASINIER STEM 
	INNER JOIN ST_INVENTAIRE STI 
		ON STEM.ID_ENTREPOT = STI.ID_ENTREPOT AND CREATE_PHYSICAL_INV = 1 AND ID_MAGASINIER = `+idMag+`
	INNER JOIN ST_TYPE_INVENTAIRE STTI
		ON STTI.ID_TYPE_INVENTAIRE = STI.ID_TYPE_INVENTAIRE
	INNER JOIN ST_ETAT_INVENTAIRE STEI 
		ON STI.ID_ETAT_INVENTAIRE = STEI.ID_ETAT_INVENTAIRE
	INNER JOIN A_UTILISATEUR AU
		ON AU.ID_UTILISATEUR = STI.ID_RESPONSABLE_INVENTAIRE
    INNER JOIN P_ENTREPOT PE 
		ON PE.ID_ENTREPOT = STI.ID_ENTREPOT
	WHERE DATE_INVENTAIRE
            BETWEEN '`+DATEDEBUT+`' AND '`+DATEFIN+`' 
          `;
        }
        else {
            req = `
            SELECT 
            ID_INVENTAIRE,
            REF_INVENTAIRE,
            ENTREPOT,
            DATE_INVENTAIRE,
            ETAT_INVENTAIRE,
            NOM,
            STI.ID_TYPE_INVENTAIRE,
            STI.ID_ENTREPOT,
            STI.ID_ETAT_INVENTAIRE,
            STTI.TYPE_INVENTAIRE 
		FROM 
	ST_INVENTAIRE STI 
	INNER JOIN ST_TYPE_INVENTAIRE STTI
		ON STTI.ID_TYPE_INVENTAIRE = STI.ID_TYPE_INVENTAIRE
	INNER JOIN ST_ETAT_INVENTAIRE STEI 
		ON STI.ID_ETAT_INVENTAIRE = STEI.ID_ETAT_INVENTAIRE
	INNER JOIN A_UTILISATEUR AU
		ON AU.ID_UTILISATEUR = STI.ID_RESPONSABLE_INVENTAIRE
    INNER JOIN P_ENTREPOT PE 
		ON PE.ID_ENTREPOT = STI.ID_ENTREPOT
	WHERE DATE_INVENTAIRE
            BETWEEN '`+DATEDEBUT+`' AND '`+DATEFIN+`'
            `
        }
        return  req;
    },

    getaffectationMagasinier: (isAffRespMag, isAffEquipComptMag, idMagasinier) => {
        if (isAffRespMag === '1') {
            return `
                SELECT
                    ID_UTILISATEUR, NOM, Matricule , PE.ID_ENTREPOT, PE.ENTREPOT
                FROM
	                ST_ENTREPOT_MAGASINIER STEM INNER JOIN A_UTILISATEUR AU ON STEM.ID_MAGASINIER = AU.ID_UTILISATEUR
	                INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = STEM.ID_ENTREPOT
                WHERE 
                    CREATE_PHYSICAL_INV = `+isAffRespMag+`
                ORDER BY
	                Matricule
            `
        } else if (isAffEquipComptMag == '1') {
            return `
                SELECT  
                    ID_UTILISATEUR, NOM, Matricule , PE.ID_ENTREPOT, PE.ENTREPOT
                FROM 
	                ST_ENTREPOT_MAGASINIER STEM_MAG INNER JOIN ST_ENTREPOT_MAGASINIER STEM_EQCMP
		                ON STEM_MAG.ID_ENTREPOT = STEM_EQCMP.ID_ENTREPOT
	                INNER JOIN A_UTILISATEUR AU 
	                    ON STEM_EQCMP.ID_MAGASINIER = AU.ID_UTILISATEUR
	                INNER JOIN P_ENTREPOT PE 
	                    ON PE.ID_ENTREPOT = STEM_MAG.ID_ENTREPOT
                WHERE STEM_MAG.CREATE_PHYSICAL_INV = 1 AND STEM_MAG.ID_MAGASINIER = ${idMagasinier}
                    AND STEM_EQCMP.CREATE_PHYSICAL_INV = 0
            `
        }
    },

    GetInventaireByUser: (IDUSER, ID_TYPE_INVENTAIRE) => {
        if (Number(ID_TYPE_INVENTAIRE) === 1) {
            return  `
        SELECT 
            ID_INVENTAIRE,
            REF_INVENTAIRE,
            ENTREPOT,
            cast(DATE_INVENTAIRE as date) DATE_INVENTAIRE,
            ETAT_INVENTAIRE,
            NOM,
            STTI.ID_TYPE_INVENTAIRE,
            STI.ID_ENTREPOT 
		FROM 
	        ST_ENTREPOT_MAGASINIER STEM 
	        INNER JOIN ST_INVENTAIRE STI 
		        ON STEM.ID_ENTREPOT = STI.ID_ENTREPOT AND ID_MAGASINIER = `+IDUSER+` 
	        INNER JOIN ST_TYPE_INVENTAIRE STTI
		        ON STTI.ID_TYPE_INVENTAIRE = STI.ID_TYPE_INVENTAIRE AND STTI.ID_TYPE_INVENTAIRE = ${ID_TYPE_INVENTAIRE}
	        INNER JOIN ST_ETAT_INVENTAIRE STEI 
		        ON STI.ID_ETAT_INVENTAIRE = STEI.ID_ETAT_INVENTAIRE AND STI.ID_ETAT_INVENTAIRE = 1
	        INNER JOIN A_UTILISATEUR AU
		        ON AU.ID_UTILISATEUR = STI.ID_RESPONSABLE_INVENTAIRE
            INNER JOIN P_ENTREPOT PE 
		        ON PE.ID_ENTREPOT = STI.ID_ENTREPOT
		    ORDER BY STI.DATE_SAISIE DESC
          `
        } else {
            return  `
        SELECT 
            ID_INVENTAIRE,
            REF_INVENTAIRE,
            ENTREPOT,
            cast(DATE_INVENTAIRE as date) DATE_INVENTAIRE,
            ETAT_INVENTAIRE,
            NOM,
            STTI.ID_TYPE_INVENTAIRE,
            STI.ID_ENTREPOT 
		FROM 
	        ST_INVENTAIRE STI  
	        INNER JOIN ST_TYPE_INVENTAIRE STTI
		        ON STTI.ID_TYPE_INVENTAIRE = STI.ID_TYPE_INVENTAIRE AND STTI.ID_TYPE_INVENTAIRE = ${ID_TYPE_INVENTAIRE}
	        INNER JOIN ST_ETAT_INVENTAIRE STEI 
		        ON STI.ID_ETAT_INVENTAIRE = STEI.ID_ETAT_INVENTAIRE AND STI.ID_ETAT_INVENTAIRE = 1
	        INNER JOIN A_UTILISATEUR AU
		        ON AU.ID_UTILISATEUR = STI.ID_RESPONSABLE_INVENTAIRE
            INNER JOIN P_ENTREPOT PE 
		        ON PE.ID_ENTREPOT = STI.ID_ENTREPOT
		    ORDER BY STI.DATE_SAISIE DESC
          `
        }
    },

    getinventairephysiquebydateentrepot: (idMagasinier) => {
        return `
        SELECT 
            pe.ID_ENTREPOT, pe.ENTREPOT, REF_INVENTAIRE, concat(CAST(STI.DATE_SAISIE as date),' ',convert(varchar(8), getdate(), 108)) AS DATE_SAISIE,  AU.NOM, cast(date_inventaire as date) date_inventaire 
        FROM 
            P_ENTREPOT PE INNER JOIN 
            ST_ENTREPOT_MAGASINIER STEM ON PE.ID_ENTREPOT = STEM.ID_ENTREPOT AND ID_MAGASINIER = `+idMagasinier+` AND CREATE_PHYSICAL_INV = 1
            INNER JOIN ST_INVENTAIRE STI ON STI.ID_ENTREPOT = STEM.ID_ENTREPOT AND ID_TYPE_INVENTAIRE = 1
            LEFT OUTER JOIN A_UTILISATEUR AU ON AU.ID_UTILISATEUR = STI.ID_OP_SAISIE
        `
    },

    GetDetailInventaireByInvArticle(idtype,dateInv ,identrepot, idArticle) {
        let datedebutDate = new Date(dateInv)
        let dated = ("0" + datedebutDate.getDate()).slice(-2);
        let monthd = ("0" + (datedebutDate.getMonth() + 1)).slice(-2);
        let yeard = datedebutDate.getFullYear();

        return `
                SELECT
                    CLE_AX_ARTICLE, NUM_LOT, QUANTITE, LIBELLE, DATE_SAISIE, P_ARTICLE.ID_ARTICLE, AU.NOM AS OPERATEUR, pu.REF_UNITE, QTE_COEFFICIENT, pustock.REF_UNITE AS REF_UNITE_STOCK, ID_UNITE_INV
                FROM
                    ST_DT_INVENTAIRE INNER JOIN P_ARTICLE
                        ON ST_DT_INVENTAIRE.CLE_ARTICLE = P_ARTICLE.ID_ARTICLE
					INNER JOIN A_UTILISATEUR AU 
						ON AU.ID_UTILISATEUR = ST_DT_INVENTAIRE.ID_OP_SAISIE
					INNER JOIN P_UNITE pu 
						ON pu.ID_UNITE = ST_DT_INVENTAIRE.ID_UNITE_INV
					INNER JOIN P_UNITE pustock 
						ON pustock.ID_UNITE = ST_DT_INVENTAIRE.ID_UNITE_STOCK  
                WHERE
                    ID_ENTREPOT = ${identrepot} AND DATE_INVENTAIRE = '${yeard}-${monthd}-${dated}' AND ID_TYPE_INVENTAIRE = ${idtype} AND CLE_ARTICLE = ${idArticle} 
                ORDER BY
                    DATE_SAISIE DESC
               `;
    },

    getdetinventaire(ID_INVENTAIRE) {
        return `
                SELECT
                    CLE_AX_ARTICLE, NUM_LOT, QUANTITE, LIBELLE, 
                    CONCAT(CAST(DATE_SAISIE AS DATE), ' ', CONVERT(time(0), DATE_SAISIE, 120)) AS DATE_SAISIE, 
                    P_ARTICLE.ID_ARTICLE, AU.NOM AS OPERATEUR, pu.REF_UNITE, QTE_COEFFICIENT, pustock.REF_UNITE AS REF_UNITE_STOCK, 
                    ISNULL(ST_DT_INVENTAIRE.ACTIF, 0) AS ACTIF
                FROM
                    ST_DT_INVENTAIRE INNER JOIN P_ARTICLE
                        ON ST_DT_INVENTAIRE.CLE_ARTICLE = P_ARTICLE.ID_ARTICLE
					INNER JOIN A_UTILISATEUR AU 
						ON AU.ID_UTILISATEUR = ST_DT_INVENTAIRE.ID_OP_SAISIE
					INNER JOIN P_UNITE pu 
						ON pu.ID_UNITE = ST_DT_INVENTAIRE.ID_UNITE_INV
					INNER JOIN P_UNITE pustock 
						ON pustock.ID_UNITE = ST_DT_INVENTAIRE.ID_UNITE_STOCK  
                WHERE
                    ID_INVENTAIRE = ${ID_INVENTAIRE} 
                ORDER BY
                    DATE_SAISIE DESC
               `;
    },

    gettoptendetinventaireByUser(IDUSER,ID_INVENTAIRE) {
        return `SELECT
                    TOP 10 CLE_AX_ARTICLE, NUM_LOT, QUANTITE, LIBELLE, 
                    concat(cast(DATE_SAISIE as date),' ', convert(time(0), DATE_SAISIE, 118)) as DATE_SAISIE, 
                    P_ARTICLE.ID_ARTICLE, pu.REF_UNITE, QTE_COEFFICIENT, pustock.REF_UNITE AS REF_UNITE_STOCK
                    , ID_UNITE_INV  , ID_INVENTAIRE, ID_DT_INVENTAIRE, ISNULL(ST_DT_INVENTAIRE.ACTIF,0) AS ACTIF  
                FROM
                    ST_DT_INVENTAIRE INNER JOIN P_ARTICLE
                        ON ST_DT_INVENTAIRE.CLE_ARTICLE = P_ARTICLE.ID_ARTICLE
					INNER JOIN P_UNITE pu ON pu.ID_UNITE = ST_DT_INVENTAIRE.ID_UNITE_INV
					INNER JOIN P_UNITE pustock ON pustock.ID_UNITE = ST_DT_INVENTAIRE.ID_UNITE_STOCK  
                WHERE 
                     ID_OP_SAISIE = ${IDUSER} AND ST_DT_INVENTAIRE.ID_INVENTAIRE = ${ID_INVENTAIRE} 
                ORDER BY 
                    DATE_SAISIE DESC`;
    },

    getarticleembalagebymachine(codeMachine){
        return `
        SELECT CLE_AX, LIBELLE, ABREVIATION, (CASE WHEN ISNULL(SAAM.ID_MACHINE,0) >= 1 THEN 1 ELSE 0 END) AS isAffected  FROM
        P_ARTICLE PA LEFT OUTER JOIN ST_AFFECTATION_ARTICLE_MACHINE SAAM
        ON SAAM.ID_ARTICLE = PA.ID_ARTICLE AND ID_MACHINE = ${codeMachine}
        WHERE  CATEGORIE like '%emb%'
        `;
    },

    getArticleByMachine(codeMachine, ref_entrepot) {
            return `
            	SELECT
                    itemid, itemdesc, qnt, warehouse, valeur_stok, inventbatchid , pa.ID_ARTICLE, ID_UNITE, REF_UNITE
                FROM
                    STOCKERP as v
                    INNER JOIN P_ARTICLE pa ON pa.CLE_AX = v.itemid
                    INNER JOIN P_UNITE pu ON pu.ID_UNITE = pa.UNITE_STOCK
					 INNER JOIN ST_AFFECTATION_ARTICLE_MACHINE saam on saam.ID_ARTICLE = pa.ID_ARTICLE 
                WHERE
                    warehouse LIKE '${ref_entrepot}' 
					AND ID_MACHINE = ${codeMachine}
					`
    },

    findByNameArticle(art){
        return `
            SELECT 
                P_ARTICLE.ID_ARTICLE, CLE_AX, LIBELLE, ABREVIATION , UNITE_STOCK, REF_UNITE
            FROM 
                P_ARTICLE INNER JOIN P_UNITE pu ON pu.ID_UNITE = UNITE_STOCK
            WHERE 
                LIBELLE LIKE '%${art}%' OR ABREVIATION LIKE '%${art}%' OR CLE_AX LIKE '%${art}%'
            ORDER BY LIBELLE DESC
            `
    },

    findArticleByTransEntrepot(art, entrepot){
        return `
            SELECT
	            DISTINCT P_ARTICLE.ID_ARTICLE, CLE_AX, LIBELLE, ABREVIATION , UNITE_STOCK, REF_UNITE, 
	            (CASE WHEN ISNULL(stk.itemdesc,'') = '' THEN 0 ELSE 1 END) AS ONSTK
            FROM
	            P_ARTICLE INNER JOIN P_UNITE pu ON pu.ID_UNITE = UNITE_STOCK
	            LEFT OUTER JOIN STOCKERP STK ON STK.ITEMID = P_ARTICLE.CLE_AX AND warehouse LIKE '${entrepot}'
            WHERE
	            (LIBELLE LIKE '%${art}%' OR ABREVIATION LIKE '%${art}%' OR CLE_AX LIKE '%${art}%') 
            ORDER BY 
	            (CASE WHEN ISNULL(stk.itemdesc,'') = '' THEN 0 ELSE 1 END) DESC, LIBELLE ASC
            `
        },

    findAllEntrepotBySite(idSite){
        let cond = ''
        if (idSite === 'null' || idSite === '0' ) {
            cond = ' ID_SITE IS NOT NULL ';
        } else {
            cond = ' ID_SITE = ' + idSite;
        }

        return `
            SELECT ID_ENTREPOT, ENTREPOT, REF_ENTREPOT, ID_SITE 
            FROM 
                P_ENTREPOT 
            WHERE 
                ENTREPOT NOT LIKE  '%VAN%'  AND ${cond}
        `;
    },

    deleteAffectationmachinearticle(codemachine, codearticle) {
        return `
            DELETE FROM ST_AFFECTATION_ARTICLE_MACHINE WHERE ID_MACHINE = ${codemachine} 
            AND ID_ARTICLE = (SELECT ID_ARTICLE FROM P_ARTICLE WHERE CLE_AX = '${codearticle}')
            `
    },

    setAffectationmachinearticle(codemachine, codearticle) {
        return `
            INSERT INTO ST_AFFECTATION_ARTICLE_MACHINE(ID_ARTICLE, ID_MACHINE)
            VALUES((SELECT ID_ARTICLE FROM P_ARTICLE WHERE CLE_AX = '${codearticle}'), ${codemachine})
            `
    },

    getUniteConvByArticle(idArticle){
        return `
            SELECT UNITE_STOCK, 1 QTE, UNITE FROM P_ARTICLE INNER JOIN P_UNITE ON P_UNITE.ID_UNITE = P_ARTICLE.UNITE_STOCK 
            WHERE P_ARTICLE.ID_ARTICLE = ${idArticle}
            UNION
            SELECT ID_UNITE_TO, QTE, UNITE FROM P_CONVERSION_UNITE INNER JOIN P_UNITE ON P_CONVERSION_UNITE.ID_UNITE_TO = P_UNITE.ID_UNITE 
            WHERE P_CONVERSION_UNITE.ID_ARTICLE = ${idArticle} AND ID_UNITE_FROM = 
            (SELECT UNITE_STOCK FROM P_ARTICLE WHERE ID_ARTICLE = ${idArticle})
            `
    },

    getUniteConvBymachine(codeMachine){
        return `
			SELECT 
				UNITE_STOCK AS ID_UNITE, 1 QTE, UNITE AS REF_UNITE
			from 
				ST_CONSOMMATION_MACHINE_ARTICLE INNER JOIN P_ARTICLE 
					ON ST_CONSOMMATION_MACHINE_ARTICLE.ID_ARTICLE = P_ARTICLE.ID_ARTICLE 
						AND ST_CONSOMMATION_MACHINE_ARTICLE.ID_UNITE_MESURE_DEBRANCHEMENT IS NULL
						AND ST_CONSOMMATION_MACHINE_ARTICLE.ID_MACHINE = ${codeMachine}
				INNER JOIN P_UNITE ON P_UNITE.ID_UNITE = P_ARTICLE.UNITE_STOCK 
			UNION

			SELECT 
				ID_UNITE_TO AS ID_UNITE, QTE, UNITE AS REF_UNITE
			FROM 
				ST_CONSOMMATION_MACHINE_ARTICLE INNER JOIN P_ARTICLE 
					ON ST_CONSOMMATION_MACHINE_ARTICLE.ID_ARTICLE = P_ARTICLE.ID_ARTICLE 
						AND ST_CONSOMMATION_MACHINE_ARTICLE.ID_UNITE_MESURE_DEBRANCHEMENT IS NULL
						AND ST_CONSOMMATION_MACHINE_ARTICLE.ID_MACHINE = ${codeMachine}
				INNER JOIN P_CONVERSION_UNITE 
					ON P_CONVERSION_UNITE.ID_ARTICLE = ST_CONSOMMATION_MACHINE_ARTICLE.ID_ARTICLE AND ID_UNITE_FROM = P_ARTICLE.UNITE_STOCK
				INNER JOIN P_UNITE 
					ON P_CONVERSION_UNITE.ID_UNITE_TO = P_UNITE.ID_UNITE 
            `
    },

    getAllConsommationByMachine(codeMachine){
        return `
            SELECT 
				TOP 100
	            PA.ID_ARTICLE, ID_CONSOMMATION, PA.CLE_AX, PA.LIBELLE AS ARTICLE, PM.LIBELLE AS MACHINE, PUSTK.REF_UNITE AS UNITESTK, AU.NOM, 
	            AU.MATRICULE, concat(CAST(DATE_HEURE_SAISIE AS DATE),' ', DATEPART(HOUR,DATE_HEURE_SAISIE),':', DATEPART(MINUTE,DATE_HEURE_SAISIE)) DATE_HEURE_SAISIE,PUCONS.REF_UNITE AS UNITECONS, COEFFICIENT, 
	            PE.REF_ENTREPOT, PS.LIBELLE AS SHIFT, QTE_CONSUM , ST_MOTIF_CONSOMMATION_ARTICLE.MOTIF_CONSOMMATION_MP, 
				AU2.NOM AS PiloteDebranchement, concat(CAST(DATE_HEURE_SAISIE_DEBRANCHEMENT AS DATE),' ', DATEPART(HOUR,DATE_HEURE_SAISIE_DEBRANCHEMENT),':', DATEPART(MINUTE,DATE_HEURE_SAISIE_DEBRANCHEMENT)) DATE_HEURE_SAISIE_DEBRANCHEMENT, QTE_CONSUM_FINAL, PU2.REF_UNITE AS UNITECONS_FINAL, LOT
	        FROM 
	            ST_CONSOMMATION_MACHINE_ARTICLE STCMA INNER JOIN P_MACHINE PM
		            ON STCMA.ID_MACHINE = PM.ID_MACHINE AND PM.ID_MACHINE = ${codeMachine}
	            INNER JOIN A_UTILISATEUR AU 
	                ON AU.ID_UTILISATEUR = STCMA.ID_PILOTE 
	            INNER JOIN P_UNITE PUSTK 
	                ON PUSTK.ID_UNITE = STCMA.ID_UNITE_STOCK
	            INNER JOIN P_UNITE PUCONS 
	                ON PUCONS.ID_UNITE = STCMA.ID_UNITE_CONSOMMATION
	            INNER JOIN P_ENTREPOT PE 
	                ON PE.ID_ENTREPOT = STCMA.ID_ENTREPOT
	            INNER JOIN P_SHIFT PS 
	                ON PS.ID_SHIFT = STCMA.ID_SHIFT
	            INNER JOIN P_ARTICLE PA 
	                ON PA.ID_ARTICLE = STCMA.ID_ARTICLE
				LEFT OUTER JOIN A_UTILISATEUR AU2 
				    ON AU2.ID_UTILISATEUR = STCMA.ID_PILOTE_DEBRANCHEMENT
				LEFT OUTER JOIN P_UNITE PU2 
				    ON PU2.ID_UNITE = STCMA.ID_UNITE_MESURE_DEBRANCHEMENT
				LEFT OUTER JOIN ST_MOTIF_CONSOMMATION_ARTICLE ON ST_MOTIF_CONSOMMATION_ARTICLE.ID_MOTIF_CONSOMMATION_MP = STCMA.ID_MOTIF_CONSOMMATION_MP 
		    WHERE
		        STCMA.ACTIF = 1
	        ORDER BY 
	            DATE_HEURE_SAISIE 
	        DESC
	                `
    },

    finconsommation(unite, qte, pilote, idConsommation, coefficient, ID_MOTIF_CONSOMMATION_MP) {
        return `
            UPDATE 
                ST_CONSOMMATION_MACHINE_ARTICLE 
            SET 
                DATE_HEURE_SAISIE_DEBRANCHEMENT = SYSDATETIME(),
                ID_UNITE_MESURE_DEBRANCHEMENT = ${unite},
                QTE_CONSUM_FINAL = ${qte},
                ID_PILOTE_DEBRANCHEMENT = ${pilote} ,
                COEFFICIENT_CONV_FINAL = ${coefficient} , 
                ID_MOTIF_CONSOMMATION_MP = ${ID_MOTIF_CONSOMMATION_MP}
            WHERE 
                ID_CONSOMMATION = ${idConsommation}
        `
    },

    getConfigEntrepot(idEntrepot) {
        return `
            SELECT STPICF.* , REF_ENTREPOT FROM ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX STPICF
            INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = STPICF.ID_ENTREPOT WHERE PE.ID_ENTREPOT = ${idEntrepot}        
        `
    },

    getinvcontrole(){
        return `
            SELECT 
	            pe.ID_ENTREPOT, pe.ENTREPOT, REF_INVENTAIRE, concat(CAST(STI.DATE_SAISIE as date),' ',convert(varchar(8), STI.DATE_SAISIE, 108)) AS DATE_SAISIE,  AU.NOM, cast(date_inventaire as date) date_inventaire, ID_INVENTAIRE,
	            ETAT_INVENTAIRE
            FROM 
	            P_ENTREPOT PE INNER JOIN ST_INVENTAIRE STI ON STI.ID_ENTREPOT = PE.ID_ENTREPOT 
    	        AND ID_TYPE_INVENTAIRE = 2
	    		INNER JOIN ST_ETAT_INVENTAIRE ON ST_ETAT_INVENTAIRE.ID_ETAT_INVENTAIRE = STI.ID_ETAT_INVENTAIRE
                LEFT OUTER JOIN A_UTILISATEUR AU ON AU.ID_UTILISATEUR = STI.ID_OP_SAISIE
            ORDER BY 
                STI.DATE_SAISIE DESC
            `
    }
};
