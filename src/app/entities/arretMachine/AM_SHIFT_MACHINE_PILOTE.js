/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('AM_SHIFT_MACHINE_PILOTE', {
        ID: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true,
            comment: "null"
        },
        ID_SHIFT: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'P_SHIFT',
                key: 'ID_SHIFT'
            }
        },
        ID_MACHINE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'P_MACHINE',
                key: 'ID_MACHINE'
            }
        },
        ID_PILOTE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'A_UTILISATEUR',
                key: 'ID_UTILISSATEUR'
            }
        }
    }, {
        tableName: 'AM_SHIFT_MACHINE_PILOTE'
    });
};
