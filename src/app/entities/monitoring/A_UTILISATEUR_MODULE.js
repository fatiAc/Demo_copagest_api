/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_UTILISATEUR_MODULE', {
    ID_UTILISATEUR: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'A_UTILISATEUR',
        key: 'ID_UTILISATEUR'
      }
    },
    ID_MODULE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'A_MODULE',
        key: 'ID_MODULE'
      }
    },
    ID_PROFIL: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'A_PROFIL',
        key: 'ID_PROFIL'
      }
    },
    ACTIVE: {
      type: DataTypes.BOOLEAN,
      allowNull: false
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
    tableName: 'A_UTILISATEUR_MODULE'
  });
};
