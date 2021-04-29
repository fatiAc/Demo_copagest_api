const moment = require('moment');

module.exports = {

    getDateTimeFormatAttacher: () => {
        return moment(new Date()).format('YYYYMMDDHHmmss')
    },

    getDateTimeFormat: () => {
        return moment(new Date()).format('YYYY-MM-DD HH:mm:ss')
    },

    getFullDateFormat: () => {
        return moment(new Date()).format('YYYY-MM-DD')
    },

    getAllDaysOfMonth: (date) => {
        const month = date.getUTCMonth();
        date.setDate(1);
        let days = [];
        while (date.getUTCMonth() == month) {
            days.push(moment(new Date(date.getFullYear(), month, date.getUTCDate())).format('YYYY-MM-DD'));
            date.setDate(date.getUTCDate() + 1);
        }
        return days;
    },

    getDatesBetweenTwoDates: (dateMin, dateMax) => {
        if (dateMin < dateMax) {
            let dates = [dateMin];
            let isOK = false;
            while (!isOK) {
                const lastPushedDate = dates[dates.length - 1];
                if (lastPushedDate < dateMax) {
                    const date = new Date(lastPushedDate);
                    dates.push(moment(date.setDate(date.getUTCDate() + 1)).format('YYYY-MM-DD'))
                } else isOK = true
            }
            return dates;
        } else return [];
    }


};
