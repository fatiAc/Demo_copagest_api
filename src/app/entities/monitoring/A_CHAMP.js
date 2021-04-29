/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_CHAMP', {
    ID_CHAMP: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ID_MODULE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'A_MODULE',
        key: 'ID_MODULE'
      }
    },
    LIB_CHAMP: {
      type: DataTypes.STRING,
      allowNull: false
    },
    ACTION_CHAMP: {
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
    }
  }, {
    tableName: 'A_CHAMP'
  });
};
