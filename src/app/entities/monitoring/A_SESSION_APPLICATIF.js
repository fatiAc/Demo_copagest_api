/* jshint indent: 2 */

module.exports = function (sequelize, DataTypes) {
    return sequelize.define('A_SESSION_APPLICATIF', {
        ID_SESSION_APPLICATIF: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        ID_UTILISATEUR: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'A_UTILISATEUR',
                key: 'ID_UTILISATEUR'
            }
        },
        ID_PROJET: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'A_MODULE',
                key: 'ID_MODULE'
            }
        },
        ID_SESSION_WINDOWS: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'A_SESSION_WINDOWS',
                key: 'ID_SESSION'
            }
        },
        ID_POSTE: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'A_POSTE',
                key: 'ID_POSTE'
            }
        },
        DATE_OUVERTURE_SESSION: {
            type: DataTypes.DATE,
            allowNull: true
        },
        DATE_FERMETURE_SESSION: {
            type: DataTypes.DATE,
            allowNull: true
        },
        ID_SESSION_APPLICATIF_USER: {
            type: DataTypes.INTEGER,
            allowNull: true
        },
        POSTE: {
            type: DataTypes.STRING,
            allowNull: true
        },
        SESSION_WINDOWS: {
            type: DataTypes.STRING,
            allowNull: true
        },
        NOM_UTILISATEUR: {
            type: DataTypes.STRING,
            allowNull: true
        },
        DATETIME_OP: {
            type: DataTypes.DATE,
            allowNull: true
        }
    }, {
        tableName: 'A_SESSION_APPLICATIF',
        hasTrigger: true
    });
};
