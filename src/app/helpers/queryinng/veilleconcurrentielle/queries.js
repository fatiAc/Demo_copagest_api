'use strict';

module.exports = {
    findByCritaria: (date, actionID, operatorID) => {
        let query = `SELECT detected_action.ID AS detectedActionID, PRODUCT AS product, convert(varchar(10), DATE_SAISIE, 120) AS dateSaisie
                        ,userr.NOM AS userName,operator.NAME AS operatorName,action.NAME AS actionName,site.SITE AS site, action_field.NAME AS fieldName,
                        detail_detected_action.DETAIL_VALUE AS detailValue,action_field.TYPE AS fieldType FROM VC_DETECTED_ACTION detected_action
                        INNER JOIN VC_DETAIL_DETECTED_ACTION detail_detected_action on detected_action.ID = detail_detected_action.DETECTED_ACTION_ID
                        INNER JOIN VC_ACTION action ON detected_action.ACTION_ID = action.ID
                        INNER JOIN VC_ACTION_FIELD action_field ON detail_detected_action.ACTION_FIELD_ID = action_field.ID
                        INNER JOIN VC_OPERATOR operator ON detected_action.OPERATOR_ID = operator.ID
                        INNER JOIN A_UTILISATEUR userr ON detected_action.USER_ID = userr.ID_UTILISATEUR
                        INNER JOIN P_SITE site ON detected_action.SITE_ID = site.ID_SITE
                        WHERE 1=1`;

        query += date != null && date !== '' && date !== 'null' ? ` AND convert(varchar(10), DATE_SAISIE, 120) = '${date}'` : ``;
        query += actionID != -1 ? ` AND detected_action.ACTION_ID = ${actionID}` : ``;
        query += operatorID != -1 ? ` AND detected_action.OPERATOR_ID = ${operatorID}` : ``;
        query += ` ORDER BY DATE_SAISIE DESC`;

        return query;
    },
};
