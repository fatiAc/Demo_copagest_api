/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('AM_TYPE_ARRET', {
        ID_TYPE_ARRET: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        LIBELLE: {
            type: DataTypes.STRING(100),
            allowNull: false,
            comment: "null"
        },
        CODE_COLEUR: {
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
        tableName: 'AM_TYPE_ARRET'
    });
};
