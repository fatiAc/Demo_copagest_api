/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('P_SHIFT', {
        ID_SHIFT: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true,
            comment: "null"
        },
        LIBELLE: {
            type: DataTypes.STRING(100),
            allowNull: false,
            comment: "null"
        },
        HEURE_DEBUT: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null"
        },
        HEURE_FIN: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null"
        },
        NBR_HEURE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null"
        },
        ID_OPERATEUR: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null",
            references: {
                model: 'A_UTILISATEUR',
                key: 'ID_UTILISATEUR'
            }
        },
        DATESYS: {
            type: DataTypes.STRING(100),
            allowNull: true,
            comment: "null"
        }
    }, {
        tableName: 'P_SHIFT'
    });
};
