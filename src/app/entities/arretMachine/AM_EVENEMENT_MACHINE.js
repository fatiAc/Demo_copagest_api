/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('AM_EVENEMENT_MACHINE', {
        ID_EVENEMENT_FABRICATION: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            comment: "null"
        },
        ID_MACHINE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            comment: "null"
        }
    }, {
        tableName: 'AM_EVENEMENT_MACHINE'
    });
};
