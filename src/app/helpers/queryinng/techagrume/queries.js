'use strict';

module.exports = {
    getGroupeVariete: () => {
        return `SELECT * FROM Goupe_variete`
    },

    getVarieteByCodeGroupe: (codegroupe) => {
        return `SELECT * FROM Variete WHERE CodeGroupe =`+codegroupe
    },

    getEstimationByGroupeVariete: (codegroupe) => {
        return `SELECT
                       Goupe_variete.CodeGroupe,Goupe_variete.Libelle,     
                       SUM(( Estimation.Qte_Est *  1000) ) AS sommeEstimationGroupe     
            
                   FROM Estimation,Variete,Goupe_variete,Adherent,verger
            
                   WHERE Variete.CodeVar = Estimation.CodeVar
                   AND  Goupe_variete.CodeGroupe= Variete.CodeGroupe
                   AND  Estimation.CodeVerger = Verger.CodeVerger
                   AND Verger.Code_Adherent = Adherent.Code_Adherent
                   AND Estimation.Code_Compagne =  (SELECT TOP (1) Code_Compagne FROM Compagne WHERE Actif = 1) 
                   
                   AND Variete.CodeGroupe = ${codegroupe}
            
                   GROUP BY Goupe_variete.CodeGroupe, Goupe_variete.Libelle`
    },

    getEstimationByVariete:(codevariete) => {
        return `
    SELECT
        Variete.CodeVar,
        SUM(( Estimation.Qte_Est *  1000) ) AS sommeEstimationVariete

    FROM Estimation,Variete,Goupe_variete,Adherent,verger

    WHERE Variete.CodeVar = Estimation.CodeVar
        AND  Goupe_variete.CodeGroupe= Variete.CodeGroupe
        AND  Estimation.CodeVerger = Verger.CodeVerger
        AND Verger.Code_Adherent = Adherent.Code_Adherent
        AND Estimation.Code_Compagne =  (SELECT TOP (1) Code_Compagne FROM Compagne WHERE Actif = 1)
        AND Variete.CodeVar = ${codevariete}

    GROUP BY Variete.CodeVar`
    },

    getEstimationByVarieteEtAdherentEtGroupeVariete: (codeGroupe,codeVariete ,codeProducteur) => {
        let requete = `
           SELECT
               SUM(( Estimation.Qte_Est *  1000) ) AS sommeEst,    
               Adherent.Code_Adherent AS Code_Adherent,
               Adherent.Nom AS Nom,
               Adherent.Code_Agrume AS Code_Agrume
           FROM Verger, Estimation, Adherent, Variete, Goupe_variete Ag
               
           WHERE Ag.CodeGroupe = Variete.CodeGroupe
           AND Variete.CodeVar = Estimation.CodeVar
           AND Adherent.Code_Adherent = Verger.Code_Adherent
           AND Verger.CodeVerger = Estimation.CodeVerger
           AND Estimation.Code_Compagne =  (SELECT TOP (1) Code_Compagne FROM Compagne WHERE Actif = 1) 
          `;

        if (codeGroupe !== 'null') {
            requete += `AND Variete.CodeGroupe = ${codeGroupe} `;
        }
        if (codeVariete !== 'null') {
            requete += ` AND Estimation.CodeVar = ${codeVariete} `;
        }
        if (codeProducteur !== 'null') {
            requete += ` AND Adherent.Code_Adherent = ${codeProducteur}`;
        }

        requete += ` GROUP BY Adherent.Code_Adherent, Adherent.Nom, Adherent.Code_Agrume
                 ORDER BY Adherent.Code_Agrume`;

        return requete;
    },

    getEstimationByVarieteEtAdherentEtGroupeVarieteGroupByVerger: (codeGroupe,codeVariete ,codeProducteur) => {
        let requete = `
               SELECT
                   Estimation.CodeVerger AS CodeVerger,   
                   SUM(( Estimation.Qte_Est *  1000) ) AS sommeEst, 
                   verger.Ref AS Ref, 
                   Adherent.Code_Adherent AS Code_Adherent, 
                   Adherent.Nom AS Nom, 
                   Adherent.Code_Agrume AS Code_Agrume    
            
               FROM Verger, Estimation, Adherent, Variete, Goupe_variete Ag
            
               WHERE Ag.CodeGroupe = Variete.CodeGroupe
               AND Variete.CodeVar = Estimation.CodeVar
               AND Adherent.Code_Adherent = Verger.Code_Adherent
               AND Verger.CodeVerger = Estimation.CodeVerger
               AND Estimation.Code_Compagne =  (SELECT TOP (1) Code_Compagne FROM Compagne WHERE Actif = 1) 
               `;

        if (codeGroupe !== 'null') {
            requete += ` AND Variete.CodeGroupe = ${codeGroupe} `;
        }
        if (codeVariete !== 'null') {
            requete += ` AND Estimation.CodeVar = ${codeVariete} `;
        }
        if (codeProducteur !== 'null') {
            requete += ` AND Adherent.Code_Adherent = ${codeProducteur}`;
        }

        requete += ` GROUP BY Estimation.CodeVerger, Verger.Ref, Adherent.Code_Adherent, Adherent.Nom, Adherent.Code_Agrume
                 ORDER BY verger.Ref`;
        return requete
    }
};
