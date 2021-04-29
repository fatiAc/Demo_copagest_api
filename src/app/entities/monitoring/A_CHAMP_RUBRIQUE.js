/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_CHAMP_RUBRIQUE', {
    ID_AFFECT_RBCH: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    ID_CHAMP: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'A_CHAMP',
        key: 'ID_CHAMP'
      }
    },
    ID_RUBRIQUE: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'A_RUBRIQUE',
        key: 'ID_RUBRIQUE'
      }
    },
    DATE_CREATION_ARBCH: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: '(sysdatetime())'
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
    tableName: 'A_CHAMP_RUBRIQUE'
  });
};
