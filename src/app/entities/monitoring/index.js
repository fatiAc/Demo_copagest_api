'use strict';

// Entity Connection
let dbintegrale = require('../../../../env/entitiy_connection')('dbintegrale');

// All entities module
let ChampEntity = dbintegrale.import('./A_CHAMP');
let ChampRubriqueEntity = dbintegrale.import('./A_CHAMP_RUBRIQUE');
let DroitProfilEntity = dbintegrale.import('./A_DROIT_PROFIL');
let ModuleEntity = dbintegrale.import('./A_MODULE');
let ProfilEntity = dbintegrale.import('./A_PROFIL');
let RubriqueEntity = dbintegrale.import('./A_RUBRIQUE');
let UserEntity = dbintegrale.import('./A_UTILISATEUR');
let UserModuleEntity = dbintegrale.import('./A_UTILISATEUR_MODULE');
let GroupeEntity = dbintegrale.import('./A_GROUPE');
let UserGroupeEntity = dbintegrale.import('./A_UTILISATEUR_GROUPE');
let SessionApplicatifEntity = dbintegrale.import('./A_SESSION_APPLICATIF');
let MobileEntity = dbintegrale.import('./P_MOBILE');
let MobileModuleEntity = dbintegrale.import('./P_MOBILE_MODULE');
let SiteEntity = dbintegrale.import('./P_SITE');


// Associations between entities
ChampEntity.belongsToMany(RubriqueEntity, {through: ChampRubriqueEntity, foreignKey: 'ID_CHAMP'});
RubriqueEntity.belongsToMany(ChampEntity, {through: ChampRubriqueEntity, foreignKey: 'ID_RUBRIQUE'});

ProfilEntity.belongsToMany(ChampRubriqueEntity, {through: DroitProfilEntity, foreignKey: 'ID_PROFIL'});
ChampRubriqueEntity.belongsToMany(ProfilEntity, {through: DroitProfilEntity, foreignKey: 'ID_AFFECT_RBCH'});

ProfilEntity.belongsToMany(UserEntity, {through: UserModuleEntity, foreignKey: 'ID_PROFIL'});
UserEntity.belongsToMany(ProfilEntity, {through: UserModuleEntity, foreignKey: 'ID_UTILISATEUR'});

ModuleEntity.belongsToMany(UserEntity, {through: UserModuleEntity, foreignKey: 'ID_MODULE'});
UserEntity.belongsToMany(ModuleEntity, {through: UserModuleEntity, foreignKey: 'ID_UTILISATEUR'});

GroupeEntity.belongsToMany(UserEntity, {through: UserGroupeEntity, foreignKey: 'ID_GRP'});
UserEntity.belongsToMany(GroupeEntity, {through: UserModuleEntity, foreignKey: 'ID_UTILISATEUR'});

ProfilEntity.belongsTo(ModuleEntity, {foreignKey: 'ID_MODULE', targetKey: 'ID_MODULE'});
GroupeEntity.belongsTo(ModuleEntity, {foreignKey: 'ID_MODULE', targetKey: 'ID_MODULE'});
ChampEntity.belongsTo(ModuleEntity, {foreignKey: 'ID_MODULE', targetKey: 'ID_MODULE'});
RubriqueEntity.belongsTo(ModuleEntity, {foreignKey: 'ID_MODULE', targetKey: 'ID_MODULE'});

UserEntity.belongsTo(SiteEntity, {foreignKey: 'ID_SITE', targetKey: 'ID_SITE', as: 'ST'});


// Export this entities with connection
module.exports = {
    ChampEntity,
    ChampRubriqueEntity,
    DroitProfilEntity,
    MobileEntity,
    MobileModuleEntity,
    ModuleEntity,
    UserEntity,
    UserModuleEntity,
    ProfilEntity,
    RubriqueEntity,
    GroupeEntity,
    UserGroupeEntity,
    SessionApplicatifEntity,
    SiteEntity
};
