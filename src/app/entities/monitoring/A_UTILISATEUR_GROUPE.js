/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_UTILISATEUR_GROUPE', {
    ID_UTILISATEUR: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'A_UTILISATEUR',
        key: 'ID_UTILISATEUR'
      }
    },
    ID_GRP: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'A_GROUPE',
        key: 'ID_GRP'
      }
    },
    CONSULTER_TOUS: {
      type: DataTypes.BOOLEAN,
      allowNull: false
    },
    DEFAULT_GRP: {
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
    tableName: 'A_UTILISATEUR_GROUPE'
  });
};
