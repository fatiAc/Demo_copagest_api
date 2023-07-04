create table dbo.AM_EVENEMENT_MACHINE
(
    ID_EVENEMENT_FABRICATION smallint not null,
    ID_MACHINE               int      not null,
    primary key (ID_EVENEMENT_FABRICATION, ID_MACHINE)
)
go


create table dbo.A_CHAMP
(
    ID_CHAMP                   int identity
        constraint PK_T_CHAMP
            primary key,
    LIB_CHAMP                  nvarchar(100) not null,
    ABRV_CHAMP                 nvarchar(100) not null
        constraint constraint_unique_abreviation_champ
            unique,
    ACTION_CHAMP               nvarchar(100),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

create table dbo.A_POSTE
(
    ID_POSTE              int identity
        constraint PK_A_POSTE
            primary key,
    POSTE_TRAVAIL         varchar(128) not null,
    ID_SESSION_APPLICATIF int
)
go

create table dbo.A_PROJET
(
    ID_PROJET             int identity
        constraint PK_A_PROJET
            primary key,
    DATE_HEURE_CREATION   datetime
        constraint DF_A_PROJET_DATE_HEURE_CREATION default getdate(),
    ID_OP                 int,
    ID_SESSION_APPLICATIF int,
    LIBELLE               varchar(512),
    DESCRIPTION           varchar(1028),
    VERSION_ACTUELLE      varchar(50)
)
go

create table dbo.A_SESSION_WINDOWS
(
    ID_SESSION                 int identity
        constraint PK_A_SESSION
            primary key,
    SESSION_LDAP               varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

create table dbo.A_TYPE_MODULE
(
    ID_TYPE_MODULE int identity
        constraint PK_A_TYPE_MODULE
            primary key,
    TYPE_MODULE    varchar(50)
)
go

create table dbo.A_MODULE
(
    ID_MODULE                  int identity
        constraint PK_T_MODULE
            primary key,
    LIB_MODULE                 nvarchar(100) not null,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_PROJET                  int
        constraint FK_A_MODULE_A_PROJET
            references dbo.A_PROJET,
    ID_TYPE_MODULE             int
        constraint FK_A_MODULE_A_TYPE_MODULE
            references dbo.A_TYPE_MODULE
)
go

create table dbo.A_GROUPE
(
    ID_GRP                     int identity
        constraint PK_T_GROUPE
            primary key,
    ID_MODULE                  int not null
        constraint FK_T_GROUPE_T_MODULE
            references dbo.A_MODULE,
    LIB_GRP                    nvarchar(100),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go


create table dbo.A_PROFIL
(
    ID_PROFIL                  int identity
        constraint PK_T_PROFIL
            primary key,
    ID_MODULE                  int           not null
        constraint FK_T_PROFIL_T_MODULE
            references dbo.A_MODULE,
    LIB_PROFIL                 nvarchar(100) not null,
    DESC_PROFIL                nvarchar(300),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ABRV                       varchar(56)
)
go

create table dbo.A_RUBRIQUE
(
    ID_RUBRIQUE                int identity
        constraint PK_T_RUBRIQUE
            primary key,
    T_R_ID_RUBRIQUE            int
        constraint FK_T_RUBRIQUE_T_RUBRIQUE
            references dbo.A_RUBRIQUE,
    ID_MODULE                  int           not null
        constraint FK_T_RUBRIQUE_T_MODULE
            references dbo.A_MODULE,
    LIB_RUBRIQUE               nvarchar(100) not null,
    ACTIF_RB                   bit           not null,
    INTERFACE                  nvarchar(250),
    TITRE                      varchar(128),
    ICON                       varchar(128),
    TRIE                       int,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ABRV                       varchar(128)
        constraint UNIQABRV
            unique
)
go

create table dbo.A_CHAMP_RUBRIQUE
(
    ID_AFFECT_RBCH             int identity
        constraint PK_T_CHAMP_RUBRIQUE
            primary key,
    ID_CHAMP                   int not null
        constraint FK_T_CHAMP_RUBRIQUE_T_CHAMP
            references dbo.A_CHAMP
            on delete cascade,
    ID_RUBRIQUE                int not null
        constraint FK_T_CHAMP_RUBRIQUE_T_RUBRIQUE
            references dbo.A_RUBRIQUE
            on delete cascade,
    DATE_CREATION_ARBCH        datetime2 default sysdatetime(),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

create table dbo.A_DROIT_PROFIL
(
    ID_AFFECT_RBCH             int not null
        constraint FK_T_DROIT_PROFIL_T_CHAMP_RUBRIQUE
            references dbo.A_CHAMP_RUBRIQUE
            on delete cascade,
    ID_PROFIL                  int not null
        constraint FK_T_DROIT_PROFIL_T_PROFIL
            references dbo.A_PROFIL
            on delete cascade,
    DATE_CREATION_DROIT        datetime2 default sysdatetime(),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    constraint PK_T_DROIT_PROFIL
        primary key (ID_AFFECT_RBCH, ID_PROFIL)
)
go
    
create table dbo.A_UTILISATEUR
(
    ID_UTILISATEUR             int                                                         not null
        constraint PK_T_UTILISATEUR
            primary key,
    MATRICULE                  int
        constraint UNIQUE_MATRICULE
            unique,
    MPASSE                     nvarchar(125)                                               not null,
    ID_SITE                    int      default 217,
    ACTIF                      bit,
    SOLDE                      float,
    NOM                        varchar(50),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime default sysdatetime(),
    ID_DERICTION               int,
    ID_GLPI                    int,
    EMAIL                      varchar(max),
    SysStartTime               datetime2
        constraint DF_SysStartUt default sysutcdatetime()                                  not null,
    SysEndTime                 datetime2
        constraint DF_SysEndUt default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create table dbo.AM_EFFET_FABRICATION
(
    ID_EFFET     smallint identity
        constraint PK_AM_EFFET_FABRICATION
            primary key,
    LIBELLE      varchar(100) not null,
    CODE_COULEUR varchar(100) not null,
    ID_OPERATEUR int          not null
        constraint FK_AM_EFFET_FABRICATION_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATESYS      datetime
        constraint DF_AM_EFFET_FABRICATION_DATESYS default getdate()
)
go

create table dbo.AM_EVENEMENT_FABRICATION
(
    ID_EVENEMENT smallint identity
        constraint PK_AM_EVENEMENT_FABRICATION
            primary key,
    LIBELLE      varchar(100) not null,
    ID_OPERATEUR int          not null
        constraint FK_AM_EVENEMENT_FABRICATION_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATESYS      datetime
        constraint DF_AM_EVENEMENT_FABRICATION_DATESYS default getdate(),
    CODE_COULEUR varchar(100) not null
)
go

create table dbo.AM_TYPE_ARRET
(
    ID_TYPE_ARRET smallint identity
        constraint PK_AM_TYPE_ARRET
            primary key,
    LIBELLE       varchar(100) not null,
    CODE_COLEUR   varchar(100) not null,
    ID_OPERATEUR  int          not null
        constraint FK_AM_TYPE_ARRET_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATESYS       datetime
        constraint DF_AM_TYPE_ARRET_DATESYS default getdate()
)
go

create table dbo.AM_ARRET_MACHINE
(
    ID_ARRET_MACHINE         bigint identity
        constraint PK_AM_ARRET_MACHINE
            primary key,
    ID_OPERATEUR             int      not null
        constraint FK_AM_ARRET_MACHINE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATESYS                  datetime
        constraint DF_AM_ARRET_MACHINE_DATESYS default getdate(),
    DATE_ARRET               datetime not null,
    DUREE_ARRET_MINUTE       smallint not null,
    ID_SHIFT_MACHINE_PILOTE  bigint   not null,
    ID_TYPE_ARRET            smallint not null
        constraint FK_AM_ARRET_MACHINE_AM_TYPE_ARRET
            references dbo.AM_TYPE_ARRET,
    ID_EVENEMENT_FABRICATION smallint not null
        constraint FK_AM_ARRET_MACHINE_AM_EVENEMENT_FABRICATION
            references dbo.AM_EVENEMENT_FABRICATION
)
go

create table dbo.A_RESPONSABLE_USER_PROFIL
(
    ID_PROFIL      int not null
        constraint FK_A_RESPONSABLE_USER_PROFIL_A_PROFIL
            references dbo.A_PROFIL,
    ID_UTILISATEUR int not null
        constraint FK_A_RESPONSABLE_USER_PROFIL_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ACTIF          bit,
    DATE_CREATION  datetime
        constraint DF_A_RESPONSABLE_USER_PROFIL_DATE_CREATION default getdate(),
    ID_USER_PROFIL int identity
        constraint PK_A_RESPONSABLE_USER_PROFIL_1
            primary key,
    constraint UNIQ
        unique (ID_PROFIL, ID_UTILISATEUR)
)
go

create table dbo.A_SESSION_APPLICATIF
(
    ID_SESSION_APPLICATIF      int identity
        constraint PK_A_SESSION_APPLICATIF
            primary key,
    ID_UTILISATEUR             int
        constraint FK_A_SESSION_APPLICATIF_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_PROJET                  int
        constraint FK_A_SESSION_APPLICATIF_GP_PROJET
            references dbo.A_PROJET,
    ID_SESSION_WINDOWS         int
        constraint FK_A_SESSION_APPLICATIF_A_SESSION_WINDOWS
            references dbo.A_SESSION_WINDOWS,
    ID_POSTE                   int
        constraint FK_A_SESSION_APPLICATIF_A_POSTE
            references dbo.A_POSTE,
    DATE_OUVERTURE_SESSION     datetime,
    DATE_FERMETURE_SESSION     datetime,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go


create table dbo.A_UTILISATEUR_GROUPE
(
    ID_UTILISATEUR             int not null
        constraint FK_T_UTILISATEUR_GROUPE_T_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_GRP                     int not null
        constraint FK_T_UTILISATEUR_GROUPE_T_GROUPE
            references dbo.A_GROUPE,
    CONSULTER_TOUS             bit not null,
    DEFAULT_GRP                bit not null,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    constraint PK_T_UTILISATEUR_GROUPE
        primary key (ID_UTILISATEUR, ID_GRP)
)
go

create table dbo.A_UTILISATEUR_MODULE
(
    ID_UTILISATEUR             int not null
        constraint FK_A_UTILISATEUR_MODULE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_MODULE                  int not null
        constraint FK_A_UTILISATEUR_MODULE_A_MODULE
            references dbo.A_MODULE,
    ID_PROFIL                  int not null
        constraint FK_A_UTILISATEUR_MODULE_A_PROFIL
            references dbo.A_PROFIL,
    ACTIVE                     bit not null,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime default sysdatetime(),
    constraint PK_A_UTILISATEUR_MODULE
        primary key (ID_UTILISATEUR, ID_MODULE, ID_PROFIL)
)
go
