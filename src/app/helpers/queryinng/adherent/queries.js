'use strict';

module.exports = {
    getAllAdherent: () => {
        return `
        SELECT
           P_Adherent.CodeAdherent AS CodeAdherent,
           P_Adherent.Code_TypeAd AS Code_TypeAd, 
           P_Adherent.Nom AS Nom,    
           P_Adherent.Code_Lait AS Code_Lait,     
           P_Adherent.Code_Agrume AS Code_Agrume
        FROM 
            P_Adherent 
        WHERE 
            P_Adherent.Code_TypeAd IN (1, 2, 3, 11, 5)`
    },
    getAllAdherentBySearshNameOrCodeAgrume: (searshMotif) => {
        let requete = `
                SELECT
                   P_Adherent.CodeAdherent AS CodeAdherent,
                   P_Adherent.Code_TypeAd AS Code_TypeAd, 
                   P_Adherent.Nom AS Nom,    
                   P_Adherent.Code_Lait AS Code_Lait,     
                   P_Adherent.Code_Agrume AS Code_Agrume
                FROM 
                    P_Adherent 
                WHERE 
                    P_Adherent.Code_TypeAd IN (1, 2, 3, 11, 5) 
        `;

        requete += (isNaN(searshMotif)) ? ` AND P_Adherent.Nom LIKE '${searshMotif}%'` : `AND P_Adherent.CodeAdherent = ${searshMotif}`;
        return requete
    },
};
