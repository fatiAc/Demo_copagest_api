'use strict';

module.exports = {

    /**
     * @description Return response successfully from server with data
     * @param data (object)
     * @returns {{data: object | null | [] | *, message: string}}
     */
    successfully: (data = null) => {
        return {
            statusCode: 200,
            message: 'Opération succés',
            data: data
        }
    },

    /**
     * @description Return response successfully from server with data
     * @param statusCode
     * @param message
     * @param data
     * @return {{data: *, message: string, statusCode: number}}
     */
    makeResponse: (data = null, statusCode = 200, message = 'Opération succés') => {
        return {
            statusCode: statusCode,
            message: message,
            data: data
        }
    },

    /**
     * @description Return response failed from server whith message of error
     * @param message (string)
     * @returns {{message: string}}
     */
    failed: (message = "Erreur inconnue", statusCode = 500) => {
        return {
            statusCode: statusCode,
            message: message,
            data: null
        }
    }
};
