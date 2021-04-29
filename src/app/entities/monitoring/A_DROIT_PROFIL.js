/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('A_DROIT_PROFIL', {
    ID_AFFECT_RBCH: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      references: {
        model: 'A_CHAMP_RUBRIQUE',
        key: 'ID_AFFECT_RBCH'
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
    DATE_CREATION_DROIT: {
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
    tableName: 'A_DROIT_PROFIL'
  });
};
