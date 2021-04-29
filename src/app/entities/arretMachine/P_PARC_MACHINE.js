/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('P_PARC_MACHINE', {
        ID_PARC_MACHINE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            primaryKey: true,
            comment: "null",
            autoIncrement: true
        },
        PARC: {
            type: DataTypes.STRING(50),
            allowNull: true,
            comment: "null"
        },
        ID_SESSION_APPLICATIF_USER: {
            type: DataTypes.INTEGER,
            allowNull: true,
            comment: "null"
        },
        POSTE: {
            type: DataTypes.STRING(128),
            allowNull: true,
            comment: "null"
        },
        SESSION_WINDOWS: {
            type: DataTypes.STRING(128),
            allowNull: true,
            comment: "null"
        },
        NOM_UTILISATEUR: {
            type: DataTypes.STRING(128),
            allowNull: true,
            comment: "null"
        },
        DATETIME_OP: {
            type: DataTypes.DATE,
            allowNull: true,
            comment: "null"
        }
    }, {
        tableName: 'P_PARC_MACHINE'
    });
};
