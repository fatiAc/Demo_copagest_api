/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_UTILISATEUR', {
    ID_UTILISATEUR: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true
    },
    MATRICULE: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    MPASSE: {
      type: DataTypes.STRING,
      allowNull: false
    },
    ID_SITE: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: '(NULL)'
    },
    ACTIF: {
      type: DataTypes.BOOLEAN,
      allowNull: true
    },
    SOLDE: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    NOM: {
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
    ID_DERICTION: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    ID_GLPI: {
      type: DataTypes.INTEGER,
      allowNull: true
    }
  }, {
    tableName: 'A_UTILISATEUR'
  });
};
