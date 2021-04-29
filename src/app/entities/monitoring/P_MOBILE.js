/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('P_MOBILE', {
    ID_MOBILE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    MEI: {
      type: DataTypes.STRING,
      allowNull: true
    },
    Ref: {
      type: DataTypes.STRING,
      allowNull: true
    },
    DATE_MISE_PROD: {
      type: DataTypes.DATE,
      allowNull: true
    },
    AUTORISER: {
      type: DataTypes.BOOLEAN,
      allowNull: true
    },
    DETRUITS: {
      type: DataTypes.BOOLEAN,
      allowNull: true
    },
    DATE_FIN_UTILISATION: {
      type: DataTypes.DATE,
      allowNull: true
    },
    DATE_DESTRUCTION: {
      type: DataTypes.DATE,
      allowNull: true
    },
    ID_SITE: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'P_SITE',
        key: 'ID_SITE'
      }
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
    tableName: 'P_MOBILE'
  });
};
