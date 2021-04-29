/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_RUBRIQUE', {
    ID_RUBRIQUE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    T_R_ID_RUBRIQUE: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'A_RUBRIQUE',
        key: 'ID_RUBRIQUE'
      }
    },
    ID_MODULE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'A_MODULE',
        key: 'ID_MODULE'
      }
    },
    LIB_RUBRIQUE: {
      type: DataTypes.STRING,
      allowNull: false
    },
    ACTIF_RB: {
      type: DataTypes.BOOLEAN,
      allowNull: false
    },
    INTERFACE: {
      type: DataTypes.STRING,
      allowNull: true
    },
    TITRE: {
      type: DataTypes.STRING,
      allowNull: true
    },
    ICON: {
      type: DataTypes.STRING,
      allowNull: true
    },
    TRIE: {
      type: DataTypes.INTEGER,
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
    tableName: 'A_RUBRIQUE'
  });
};
