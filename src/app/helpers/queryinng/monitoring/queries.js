'use strict';

module.exports = {

    getUsersMagasinier: () => {
        return `SELECT ID_UTILISATEUR, NOM, Matricule FROM A_UTILISATEUR AU INNER JOIN
                    [10.7.3.131].COPAGGTIME.DBO.T_AGENT TAG ON TAG.Id_Agent = AU.ID_UTILISATEUR
                    INNER JOIN
                    [10.7.3.131].COPAGGTIME.DBO.T_FONCTION TF ON TAG.Id_Fonction = TF.Id_Fonction
                    WHERE Nom_Fonction LiKE '%Magasinier%' AND AU.Actif = 1 ORDER BY NOM`
    },

    getAllUser: () => {
        return `SELECT 
	ID_UTILISATEUR, MATRICULE, NOM 
FROM 
	A_UTILISATEUR LEFT OUTER JOIN P_SITE ON A_UTILISATEUR.ID_SITE = P_SITE.ID_SITE	
WHERE 
	A_UTILISATEUR.ACTIF = 1 AND ((REF_SITE NOT LIKE '4%' AND REF_SITE NOT LIKE '3%') OR (REF_SITE IS NULL))
ORDER BY MATRICULE DESC  `
    },

    findAllUsersBySite: (idSite) => {
        let cond = ''

        if (idSite === '0' || idSite === 'null') {
            cond = ' AND A_UTILISATEUR.ID_SITE IS null';
        } else {
            cond = ' AND A_UTILISATEUR.ID_SITE = ' + idSite;
        }

        return `SELECT 
	                ID_UTILISATEUR, MATRICULE, NOM 
                FROM 
	                A_UTILISATEUR LEFT OUTER JOIN P_SITE ON A_UTILISATEUR.ID_SITE = P_SITE.ID_SITE	
                WHERE 
	                A_UTILISATEUR.ACTIF = 1  
	                ${cond}
                ORDER BY 
                    MATRICULE DESC  `
    }

};

