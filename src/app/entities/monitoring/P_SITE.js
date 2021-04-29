/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('P_SITE', {
    REF_SITE: {
      type: DataTypes.STRING,
      allowNull: false
    },
    SITE: {
      type: DataTypes.STRING,
      allowNull: true
    },
    ID_AGENCE: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    ID_SITE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    TEL_SITE: {
      type: DataTypes.STRING,
      allowNull: true
    },
    FAX_SITE: {
      type: DataTypes.STRING,
      allowNull: true
    },
    ADRESSE_SITE: {
      type: DataTypes.STRING,
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
    },
    ID_CHEF_AGENCE: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'A_UTILISATEUR',
        key: 'ID_UTILISATEUR'
      }
    },
    ID_DIRECTEUR_REGIONAL: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'A_UTILISATEUR',
        key: 'ID_UTILISATEUR'
      }
    },
    ID_DIRECTEUR_COMMERCIAL: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'A_UTILISATEUR',
        key: 'ID_UTILISATEUR'
      }
    }
  }, {
    tableName: 'P_SITE'
  });
};
