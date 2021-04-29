/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('AM_EVENEMENT_FABRICATION', {
        ID_EVENEMENT: {
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
        CODE_COULEUR: {
            type: DataTypes.STRING(100),
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
        tableName: 'AM_EVENEMENT_FABRICATION'
    });
};
