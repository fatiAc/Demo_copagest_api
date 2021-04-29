/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('AM_ARRET_MACHINE', {
        ID_ARRET_MACHINE: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true,
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
        ID_TYPE_ARRET: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null",
            references: {
                model: 'AM_TYPE_ARRET',
                key: 'ID_TYPE_ARRET'
            }
        },
        DATESYS: {
            type: DataTypes.STRING(100),
            allowNull: true,
            comment: "null"
        },
        DATE_ARRET: {
            type: DataTypes.DATE,
            allowNull: false,
            comment: "null"
        },
        DUREE_ARRET_MINUTE: {
            type: DataTypes.INTEGER,
            allowNull: false,
            comment: "null"
        },
        ID_SHIFT_MACHINE_PILOTE: {
            type: DataTypes.BIGINT,
            allowNull: false,
            comment: "null",
            references: {
                model: 'AM_SHIFT_MACHINE_PILOTE',
                key: 'ID'
            }
        },
        ID_EVENEMENT_FABRICATION: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'AM_EVENEMENT_FABRICATION',
                key: 'ID_EVENEMENT'
            }
        }
    }, {
        tableName: 'AM_ARRET_MACHINE'
    });
};
