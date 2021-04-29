/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('P_MACHINE', {
        ID_MACHINE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null"
        },
        LIBELLE: {
            type: DataTypes.STRING(100),
            allowNull: false,
            comment: "null"
        },
        ID_MACHINE_SIEGE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null"
        },
        ID_PARC_MACHINE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null"
        },
        ACTIF: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            comment: "null"
        }
    }, {
        tableName: 'P_MACHINE'
    });
};
