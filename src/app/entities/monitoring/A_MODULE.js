/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_MODULE', {
    ID_MODULE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    LIB_MODULE: {
      type: DataTypes.STRING,
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
    tableName: 'A_MODULE'
  });
};
