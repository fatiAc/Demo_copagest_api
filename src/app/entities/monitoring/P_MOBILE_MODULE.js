/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('P_MOBILE_MODULE', {
    ID_MOBILE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'P_MOBILE',
        key: 'ID_MOBILE'
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
    AUTORISER: {
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
    tableName: 'P_MOBILE_MODULE'
  });
};
