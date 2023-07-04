create table dbo.AM_EVENEMENT_MACHINE
(
    ID_EVENEMENT_FABRICATION smallint not null,
    ID_MACHINE               int      not null,
    primary key (ID_EVENEMENT_FABRICATION, ID_MACHINE)
)
go

create table dbo.ARTICLEENPALETTE
(
    CODE_ARTICLE float
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

CREATE trigger [dbo].[TR_A_CHAMP]
    on dbo.A_CHAMP
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_CHAMP'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_CHAMP on dbo.A_CHAMP
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

CREATE trigger [dbo].[TR_A_SESSION_WINDOWS]
    on DBO.A_SESSION_WINDOWS
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_SESSION_WINDOWS'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_SESSION_WINDOWS on dbo.A_SESSION_WINDOWS
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

CREATE trigger [dbo].[TR_A_GROUPE]
    on DBO.A_GROUPE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_GROUPE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_GROUPE on dbo.A_GROUPE
go

CREATE trigger [dbo].[TR_A_MODULE]
    on DBO.A_MODULE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_MODULE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_MODULE on dbo.A_MODULE
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

CREATE trigger [dbo].[TR_A_PROFIL]
    on DBO.A_PROFIL
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_PROFIL'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_PROFIL on dbo.A_PROFIL
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

CREATE trigger [dbo].[TR_A_CHAMP_RUBRIQUE]
    on DBO.A_CHAMP_RUBRIQUE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_CHAMP_RUBRIQUE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_CHAMP_RUBRIQUE on dbo.A_CHAMP_RUBRIQUE
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

CREATE trigger [dbo].[TR_A_DROIT_PROFIL]
    on DBO.A_DROIT_PROFIL
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_DROIT_PROFIL'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_DROIT_PROFIL on dbo.A_DROIT_PROFIL
go

CREATE trigger [dbo].[TR_A_RUBRIQUE]
    on DBO.A_RUBRIQUE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_RUBRIQUE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_RUBRIQUE on dbo.A_RUBRIQUE
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

CREATE trigger [dbo].[TR_A_SESSION_APPLICATIF]
    on DBO.A_SESSION_APPLICATIF
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_SESSION_APPLICATIF'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_SESSION_APPLICATIF on dbo.A_SESSION_APPLICATIF
go

create index INDEXMATRICULEUTILISATEUR
    on dbo.A_UTILISATEUR (MATRICULE)
go

create index INDEXMATRICULE
    on dbo.A_UTILISATEUR (MATRICULE) include (ID_UTILISATEUR)
go

create index IDSITEINDEX
    on dbo.A_UTILISATEUR (ID_SITE, ID_UTILISATEUR)
go

create index SITEIDINDEX
    on dbo.A_UTILISATEUR (ID_SITE) include (ID_UTILISATEUR)
go

create index SITEINDEX
    on dbo.A_UTILISATEUR (ID_SITE)
go

CREATE trigger [dbo].[TR_A_UTILISATEUR]
    on dbo.A_UTILISATEUR
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_UTILISATEUR'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_UTILISATEUR on dbo.A_UTILISATEUR
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

CREATE trigger [dbo].[TR_A_UTILISATEUR_GROUPE]
    on DBO.A_UTILISATEUR_GROUPE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_UTILISATEUR_GROUPE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_UTILISATEUR_GROUPE on dbo.A_UTILISATEUR_GROUPE
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

CREATE trigger [dbo].[TR_A_UTILISATEUR_MODULE]
    on DBO.A_UTILISATEUR_MODULE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'A_UTILISATEUR_MODULE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_A_UTILISATEUR_MODULE on dbo.A_UTILISATEUR_MODULE
go

create table dbo.CA_FEEDBACK
(
    CODE_FEEDBACK int identity
        constraint PK_CA_Client_Center_Feedback
            primary key,
    LIBELLE       nvarchar(250)
)
go

create table dbo.CA_CLIENT_FEEDBACK
(
    CODE_FEEDBACK int not null
        constraint FK__CA__Mutlti_Fe__Code___6DC2F6B9
            references dbo.CA_FEEDBACK,
    ID_CLIENT     int not null,
    primary key (CODE_FEEDBACK, ID_CLIENT)
)
go

create table dbo.CA_MOTIF
(
    CODE_MOTIF int identity
        constraint PK_CA_Client_Center_Motif
            primary key,
    LIBELLE    varchar(50)
)
go

create table dbo.CA_CENTER_CLIENT
(
    CODE_CLIENT       int not null,
    NOM               nvarchar(50),
    PATENTE           int,
    CODE_AGENCE       nvarchar(50),
    SOUS_SECTEUR      nvarchar(50),
    LATITTUDE         float,
    LONGITUDE         float,
    TELEPHONE         varchar(50),
    COMMENTAIRE       nvarchar(max),
    ID_MOTIF          int
        constraint FK_CA_Center_Client_Client_Center_Motif
            references dbo.CA_MOTIF,
    ID_CLIENT         int identity
        constraint PK_CA_Center_Client_1
            primary key,
    ADRESSE           varchar(255),
    DATE_HEURE_SAISIE datetime
        constraint DF_CA_Center_Client_DATE_HEURE_SAISIE default sysdatetime(),
    ID_OP_SAISIE      int,
    CLOTURER          bit
        constraint defaultValusOfCloturer default 0,
    OP_CLOTURE        int
        constraint FK__CA_CENTER__OP_CL__0AB43B22
            references dbo.A_UTILISATEUR,
    DATE_CLOTURE      datetime
)
go

create table dbo.CL_MISSION_CONTROLE_ANTI_BIOTH
(
    ID_MISSION             int identity
        constraint PK_CL_MISSION_CONTROLE_ANTI_BIOTH
            primary key,
    ID_CONTROLLEUR_QUALITE int,
    DATETIME_SYS           datetime
        constraint DF_CL_MISSION_CONTROLE_ANTI_BIOTH_DATETIME_SYS default getdate(),
    NUM_ECHANTILLON        varchar(50),
    ID_BACK                int,
    NOM_BACK               varchar(50),
    ID_ADHERENT            int,
    NOM_ADHERENT           varchar(50),
    ID_PRODUCTEUR          int,
    NOM_PRODUCTEUR         varchar(50),
    RES_TEST_ANTI_BIOTH    bit,
    DATETIME_SAISIE        datetime,
    ID_TOURNEE             int,
    TOURNEE                varchar(50),
    DATE_PRISE_ECHANTILLON datetime
)
go

create table dbo.CONVERTION
(
    ID_ARTICLE float,
    ITEMID     nvarchar(255),
    COLISAGE   float,
    [FROM]     float,
    [TO]       float
)
go

create table dbo.Client_Center_Feedback1
(
    Code_Feedback int identity
        constraint PK_Client_Center_Feedback
            primary key,
    Libelle       nvarchar(250)
)
go

create table dbo.Client_Center_Motif1
(
    Code_Motif int identity
        constraint PK_Client_Center_Motif
            primary key,
    Libelle    varchar(50)
)
go

create table dbo.Center_Client1
(
    CodeClient        int not null,
    Nom               nvarchar(50),
    Patente           int,
    Agence            nvarchar(50),
    Secteur           nvarchar(50),
    Latitude          float,
    Long              float,
    Tel1              varchar(50),
    Tel2              varchar(50),
    Commentaire       nvarchar(max),
    Code_Motif        int
        constraint FK_Center_Client_Client_Center_Motif
            references dbo.Client_Center_Motif1,
    Code_Feedback     int
        constraint FK_Center_Client_Client_Center_Feedback
            references dbo.Client_Center_Feedback1,
    ID                int identity
        constraint PK_Center_Client_1
            primary key,
    ADRESSE           varchar(255),
    DATE_HEURE_SAISIE datetime
        constraint DF_Center_Client_DATE_HEURE_SAISIE default sysdatetime(),
    ID_OP_SAISIE      int,
    CODE_AGCE         int
)
go

create table dbo.Client_Center_Feedback_CC1
(
    Code_Feedback int not null
        constraint FK__Mutlti_Fe__Code___6DC2F6B9
            references dbo.Client_Center_Feedback1,
    ID            int not null
        references dbo.Center_Client1,
    primary key (Code_Feedback, ID)
)
go

create table dbo.DELETE_ST_ETAT_INVENTAIRE
(
    ID_ETAT_INVENTAIRE int identity
        constraint PK_ST_ETAT_INVENTAIRE
            primary key,
    ETAT_INVENTAIRE    varchar(50)
)
go

create table dbo.DELETE_ST_INVENTAIRE_ARTICLES
(
    ID_ARTICLE           int not null,
    CLE_ARTICLE_AX       varchar(50),
    DATE_TIME_GENERATION datetime
        constraint DF_ST_INVENTAIRE_ARTICLES_DATE_TIME_GENERATION default getdate(),
    ID_OP_GENERATION     int
        constraint FK_ST_INVENTAIRE_ARTICLES_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_INVENTAIRE        int not null,
    constraint PK_ST_INVENTAIRE_ARTICLES_1
        primary key (ID_ARTICLE, ID_INVENTAIRE)
)
go

create table dbo.DELETE_ST_TYPE_INVENTAIRE
(
    ID_TYPE_INVENTAIRE int identity
        constraint PK_ST_TYPE_INVENTAIRE
            primary key,
    TYPE_INVENTAIRE    varchar(50)
)
go

create table dbo.GC_ACIDITE
(
    ID_ACIDITE int identity
        constraint PK_GC_ACIDITE
            primary key,
    ACIDITE    varchar(50) not null
)
go

create table dbo.GC_BON_REGULARISATION
(
    ID_BON_REG   int identity
        constraint PK_GC_BON_REGULARISATION
            primary key,
    ID_OP_SAISIE int,
    DATE_SAISIE  datetime
        constraint DF_GC_BON_REGULARISATION_DATE_SAISIE default getdate(),
    VALIDE       bit
        constraint DF_GC_BON_REGULARISATION_VALIDE default 0,
    ANNULER      bit
        constraint DF_GC_BON_REGULARISATION_ANNULER default 0
)
go

create table dbo.GC_DECISION
(
    ID_DECISION int identity
        constraint PK_GC_DECISION
            primary key,
    DECISION    varchar(50) not null
)
go

create table dbo.GC_PERIODE
(
    ID_PERIODE       bigint identity
        constraint PK_GC_PERIODE
            primary key,
    DATE_DEBUT       date                           not null,
    DATE_FIN         date                           not null,
    CLOTURER         bit
        constraint DF_GC_PERIODE_CLOTURER default 0 not null,
    CLOTURER_QUALITE bit,
    OP_SAISIE        int
        references dbo.A_UTILISATEUR,
    DATE_SAISIE      datetime
)
go

create table dbo.GC_STABILITE
(
    ID_STABILITE int identity
        constraint PK_GC_STABILITE
            primary key,
    STABILITE    varchar(50) not null
)
go

create table dbo.GC_TYPE_BAC_LAIT
(
    ID_TYPE_BAC_LAIT  int identity
        constraint PK_T_TYPEBAC
            primary key nonclustered,
    TYPE_BAC_LAIT     varchar(254),
    REF_TYPE_BAC_LAIT int
)
go

create table dbo.GC_TYPE_ERREUR
(
    ID_TYPE_ERREUR int         not null
        constraint PK_GC_TYPE_ERREUR_1
            primary key,
    LIBELLE        varchar(50) not null
)
go

create table dbo.GC_DET_BON_REGULARISATION
(
    ID_REGULARISATION     int identity
        constraint PK_GC_DET_BON_REGULARISATION
            primary key,
    ROW_ID                int not null,
    OLD_VALUE             varchar(50),
    NEW_VALUE             varchar(50),
    ID_TYPE_ERREUR        int not null
        constraint FK_GC_DET_BON_REGULARISATION_GC_TYPE_ERREUR
            references dbo.GC_TYPE_ERREUR,
    ID_BON_REGULARISATION int not null
        constraint FK_GC_DET_BON_REGULARISATION_GC_BON_REGULARISATION
            references dbo.GC_BON_REGULARISATION,
    VALID                 bit default NULL,
    OBSERVATION           varchar(max)
)
go

create table dbo.GC_TYPE_NETTOYAGE
(
    ID_TYPE_NETTOYAGE int identity
        constraint PK_GC_TYPE_NETTOYAGE
            primary key,
    LIBELLE           varchar(50)
)
go

create table dbo.GC_TYPE_PRIME
(
    ID_TYPE_PRIME int identity
        constraint PK_GC_TYPE_PRIME
            primary key,
    LIBELLE       nchar(20)
)
go

create table dbo.GC_TYPE_RECEPTION
(
    ID_TYPE_RECEPTION int identity
        constraint PK_GC_TYPE_RECEPTION
            primary key,
    LIBELLE           varchar(50)
)
go

create table dbo.GC_VALIDATEUR_REG
(
    ID_VALIDATEUR int not null
        constraint PK_GC_VALIDATEUR_REG
            primary key,
    ACTIF         bit
        constraint DF_GC_VALIDATEUR_REG_ACTIF default 1,
    OPTIONNEL     bit,
    ID_OP_SAISIE  int
        constraint FK_GC_VALIDATEUR_REG_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_SAISIE   datetime
        constraint DF_GC_VALIDATEUR_REG_DATE_SAISIE default getdate()
)
go

create table dbo.GC_VALIDATION_REG
(
    ID_VALIDATION          int identity
        constraint PK_GC_VALIATION_REG
            primary key,
    DATE_VALIDATION        datetime
        constraint DF_GC_VALIATION_REG_DATE_VALIDATION default getdate(),
    VALIDE                 bit,
    ID_VALIDATEUR          int
        constraint FK_GC_VALIATION_REG_GC_VALIDATEUR_REG
            references dbo.GC_VALIDATEUR_REG,
    DATE_SECOND_VALIDATION datetime,
    ID_BON_REGULARISATION  int
        constraint FK_GC_VALIATION_REG_GC_BON_REGULARISATION
            references dbo.GC_BON_REGULARISATION
)
go

create table dbo.GD_MOTIF_DEPOTAGE
(
    ID_MOTIF          int identity
        primary key,
    LIBELLE           varchar(200),
    ACTIF             bit      default 1,
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    OP_SAISIE         int
        references dbo.A_UTILISATEUR
)
go

create table dbo.GP_CALENDER
(
    ID_CALENDER int identity
        constraint PK_GP_CALENDER
            primary key,
    DATE        date,
    FERIER      bit
)
go

create table dbo.GP_FRAIS_REALISATION
(
    DATE_DEBUT           date,
    DATE_FIN             date,
    FRAIS_REALISATION    float,
    ID_FRAIS_REALISATION int identity
        constraint PK_GP_FRAIS_REALISATION
            primary key
)
go

create table dbo.GP_MOTIF_USER_STORY
(
    ID_MOTIF int identity
        constraint PK_GP_MOTIF_USER_STORY
            primary key,
    MOTIF    varchar(max)
)
go

create table dbo.GP_PHASE_DEV
(
    ID_PHASE     int identity
        constraint PK_GP_PHASE_DEV
            primary key,
    PHASE        varchar(128),
    ABREV        varchar(12),
    [ORDER]      int,
    SysStartTime datetime2
        constraint DF_SysStartGP_PHASE_DEV default sysutcdatetime()                                  not null,
    SysEndTime   datetime2
        constraint DF_SysEndGP_PHASE_DEV default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create table dbo.GP_TYPE_PROJET
(
    ID_TYPE_PROJET int identity
        constraint PK_GP_TYPE_PROJET
            primary key,
    TYPE_PROJET    varchar(512)
)
go

create table dbo.GP_PROJET
(
    ID_PROJET         int identity
        constraint PK_GP_PROJET
            primary key,
    LIBELLE           varchar(512),
    ID_TYPE_PROJET    int
        constraint FK_GP_PROJET_GP_TYPE_PROJET
            references dbo.GP_TYPE_PROJET,
    AVANCEMENT        float,
    RETARD            float,
    CLIENT            varchar(512),
    PRODUCT_OWNER     int,
    SCRUM_MASTER      int,
    TECHNIQUAL_LEADER int,
    DESCRIPTION       varchar(1028),
    DATE_DEBUT        date,
    DATE_FIN          date,
    CLOT              bit
        constraint DF_GP_PROJET_CLOT default 0,
    SysStartTime      datetime2
        constraint DF_SysStartGP_PROJET default sysutcdatetime()                                  not null,
    SysEndTime        datetime2
        constraint DF_SysEndGP_PROJET default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create table dbo.GP_EQUIPE_PROJET
(
    ID_PROJET        int not null
        constraint FK_GP_EQUIPE_PROJET_GP_PROJET
            references dbo.GP_PROJET,
    ID_MEMBRE_EQUIPE int not null,
    DATETIME         datetime,
    ID_OP_SAISIE     int
        constraint FK_GP_EQUIPE_PROJET_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    constraint PK_GP_EQUIPE_PROJET
        primary key (ID_PROJET, ID_MEMBRE_EQUIPE)
)
go

create table dbo.GP_MODULE
(
    ID_MODULE    int identity
        constraint PK_GP_APPLICATION
            primary key,
    LIBELLE      varchar(512),
    ID_PROJET    int
        constraint FK_GP_APPLICATION_GP_PROJET
            references dbo.GP_PROJET,
    SysStartTime datetime2
        constraint DF_SysStartGP_MODULE default sysutcdatetime()                                  not null,
    SysEndTime   datetime2
        constraint DF_SysEndGP_MODULE default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create table dbo.GP_MODULE_TECHNOLOGIE
(
    ID_MODULE                  int
        constraint FK_GP_APPLICATION_TECHNOLOGIE_GP_APPLICATION
            references dbo.GP_MODULE,
    TECHNOLOGIE                varchar(512),
    ID_TECHNOLOGIE_APPLICATION int identity
        constraint PK_GP_APPLICATION_TECHNOLOGIE
            primary key,
    DATETIME                   datetime,
    ID_OP_SAISIE               int
)
go

create table dbo.GP_SPRINT
(
    ID_SPRINT                      int identity
        constraint PK_GP_SPRINT
            primary key,
    DATE_CREATION_SYSTEME          datetime
        constraint DF_GP_SPRINT_DATE_CREATION_SYSTEME default getdate(),
    LIBELLE                        varchar(512),
    ID_MODULE                      int
        constraint FK_GP_SPRINT_GP_APPLICATION
            references dbo.GP_MODULE,
    DATE_DEBUT_PLANIFIER           date,
    DATE_FIN_PLANIFIER             date,
    TAUX_REALISATION               float,
    COEFFICIENT_JOCKER_PLANING     float,
    NBR_TOTAL_POINT_JOCKER_PLANING float,
    FRAIS_TOTAL                    float,
    NBR_TOTAL_HEUR_REALISATION     float,
    SysStartTime                   datetime2
        constraint DF_SysStartGP_SPRINT default sysutcdatetime()                                  not null,
    SysEndTime                     datetime2
        constraint DF_SysEndGP_SPRINT default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create table dbo.GP_RUBRIQUE
(
    ID_RUBRIQUE           int identity
        constraint PK_GP_RUBRIQUE
            primary key,
    LIBELLE               varchar(512),
    ID_SPRINT             int
        constraint FK_GP_RUBRIQUE_GP_SPRINT
            references dbo.GP_SPRINT,
    DATE_CREATION_SYSTEME datetime
)
go

create table dbo.GP_TYPE_REPOS
(
    ID_TYPE_REPOS int identity
        constraint PK_GP_TYPE_REPOS
            primary key,
    TYPE_REPOS    varchar(512)
)
go

create table dbo.GP_REPOS
(
    ID_UTILISATEUR int  not null,
    DATE_DEBUT     date not null,
    DATE_FIN       date not null,
    NBR_HEURE      float,
    ID_TYPE_REPOS  int
        constraint FK_GP_REPOS_GP_TYPE_REPOS
            references dbo.GP_TYPE_REPOS,
    constraint PK_GP_REPOS
        primary key (ID_UTILISATEUR, DATE_DEBUT, DATE_FIN)
)
go

create table dbo.GP_TYPE_TACHE
(
    ID_TYPE_TACHE int identity
        constraint PK_GP_TYPE_TACHE
            primary key,
    TYPE_TACHE    varchar(512)
)
go

create table dbo.GP_USER_STORY
(
    ID_USER_STORY              int identity
        constraint PK_GP_USER_STORY
            primary key,
    DATE_CREATION_SYSTEME      datetime
        constraint DF_GP_USER_STORY_DATE_CREATION_SYSTEME default getdate(),
    DESCRIPTION                varchar(max),
    FRAIS_UNITAIRE             float,
    ID_USER_STORY_PREVIOUS     int
        constraint FK_GP_USER_STORY_GP_USER_STORY
            references dbo.GP_USER_STORY,
    ID_TYPE_TACHE              int
        constraint FK_GP_USER_STORY_GP_TYPE_TACHE
            references dbo.GP_TYPE_TACHE,
    POINT_JOCKER_PLANING       float,
    COEFFICIENT_JOCKER_PLANING float,
    NBR_HEUR_REALISATION       float,
    ID_DEVELOPPEUR             int,
    ID_SPRINT                  int
        constraint FK_GP_USER_STORY_GP_SPRINT
            references dbo.GP_SPRINT,
    ID_MODULE                  int
        constraint FK_GP_USER_STORY_GP_APPLICATION
            references dbo.GP_MODULE,
    DATE_DEBUT                 datetime,
    DATE_FIN                   datetime,
    ORDRE                      int,
    TITRE                      varchar(max),
    OCC                        int
        constraint DF_GP_USER_STORY_OCC default 0,
    TEXT                       varchar(max),
    ID_MOTIF                   int
        constraint FK_GP_USER_STORY_GP_MOTIF_USER_STORY
            references dbo.GP_MOTIF_USER_STORY,
    SysStartTime               datetime2
        constraint DF_SysStartGP_USER_STORY default sysutcdatetime()                                  not null,
    SysEndTime                 datetime2
        constraint DF_SysEndGP_USER_STORY default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create table dbo.GP_JOCKER_PLANING
(
    ID_USER_STORY  int not null
        constraint FK_GP_JOCKER_PLANING_GP_USER_STORY
            references dbo.GP_USER_STORY,
    ID_PROJET      int not null,
    ID_UTILISATEUR int not null,
    REALISATEUR    bit,
    POINT          float,
    COEFICIENT     float,
    constraint PK_GP_JOCKER_PLANING
        primary key (ID_USER_STORY, ID_PROJET, ID_UTILISATEUR),
    constraint FK_GP_JOCKER_PLANING_GP_EQUIPE_PROJET
        foreign key (ID_PROJET, ID_UTILISATEUR) references dbo.GP_EQUIPE_PROJET
)
go

create table dbo.GP_PHASE_US_DEV
(
    ID_PHASE      int                                                                                   not null
        constraint FK_GP_PHASE_US_DEV_GP_PHASE_DEV
            references dbo.GP_PHASE_DEV,
    ID_USER_STORY int                                                                                   not null
        constraint FK_GP_PHASE_US_DEV_GP_USER_STORY
            references dbo.GP_USER_STORY,
    DATE_ADD      datetime
        constraint DF_GP_PHASE_US_DEV_DATE_ADD default getdate()                                        not null,
    ID_OP_SAISIE  int
        constraint FK_GP_PHASE_US_DEV_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ACTIF         bit
        constraint DF_GP_PHASE_US_DEV_ACTIF default 1                                                   not null,
    SysStartTime  datetime2
        constraint DF_SysStartGP_PHASE_US_DEV default sysutcdatetime()                                  not null,
    SysEndTime    datetime2
        constraint DF_SysEndGP_PHASE_US_DEV default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    constraint PK_GP_PHASE_US_DEV
        primary key (ID_PHASE, ID_USER_STORY)
)
go

create table dbo.P_ADHERENT
(
    ID_ADHERENT          int identity
        constraint PK_P_ADHERENT
            primary key,
    ADHERENT             varchar(50),
    CODE_LAIT            varchar(50),
    CODE_AGRUME          varchar(50),
    ACTIF                bit,
    REF_EXTERNE_ADHERENT int,
    SysStartTime         datetime2
        constraint DF_adherent_SysStart default sysutcdatetime()                                  not null,
    SysEndTime           datetime2
        constraint DF_adherent_SysEnd default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create table dbo.P_ARTICLE_2
(
    LIBELLE               varchar(max),
    CLE_AX                varchar(max),
    CATEGORIE             varchar(max),
    ID_ARTICLE            int identity,
    ID_FAMILLE_ARTICLE    int,
    UNITE_VENTE           int,
    UNITE_STOCK           int,
    STOCKABLE             bit,
    VENDABLE              bit,
    PRODUCTABLE           bit,
    GROUPE_TAXE_VENTE     varchar(max),
    ABREVIATION           varchar(max),
    BARRE_CODE            varchar(max),
    UNITE_COMMANDE        int,
    MODELPRIX             varchar(max),
    UNITE_ACHAT           int,
    GROUPTAXEACHAT        varchar(max),
    UNITEPRIXSTOCK        float,
    UNITEPRIXVENTE        float,
    UNITEPRIXACHAT        float,
    GROUPPRODUITNAME      varchar(max),
    TAXENAMEACHAT         varchar(max),
    TAXITEMGROUPACHAT     varchar(max),
    TAXENAMEVENTE         varchar(max),
    TAXITEMGROUPVENTE     varchar(max),
    GROUPEPRODUCT         varchar(max),
    GROUPDIMSUIVI         varchar(max),
    REF_SIEGE             varchar(128),
    ITEMID                varchar(max),
    TAXVENTEVAL           float,
    TAXACHATVAL           float,
    ACTIVITE_ART          varchar(max),
    AGENCE_ART            varchar(max),
    BU_ART                varchar(max),
    CANAL_ART             varchar(max),
    G_ARTICLE_ART         varchar(max),
    INTERCOS_ART          varchar(max),
    PROJET_ART            varchar(max),
    SITE_ART              varchar(max),
    COLOR                 varchar(max),
    CONFIG                varchar(max),
    SIZE                  varchar(max),
    STYLE                 varchar(max),
    VERSION               varchar(max),
    HERARCHYCATEGORIE     varchar(max),
    CODEHERARCHYCATEGORIE varchar(max),
    IS_VARIANTE           bit,
    SHA                   varbinary(600),
    PRODUCTVARIANTNUMBER  varchar(max)
)
go

create table dbo.P_ARTICLE_3
(
    LIBELLE                   varchar(max),
    CLE_AX                    varchar(max),
    MASTERRECID               varchar(max),
    ID_ARTICLE                int identity,
    ID_FAMILLE_ARTICLE        int,
    UNITE_VENTE               int,
    UNITE_STOCK               int,
    ABREVIATION               varchar(max),
    UNITE_COMMANDE            int,
    MODELPRIX                 varchar(max),
    UNITE_ACHAT               int,
    UNITEPRIXSTOCK            float,
    UNITEPRIXVENTE            float,
    UNITEPRIXACHAT            float,
    GROUPPRODUITNAME          varchar(max),
    TAXENAMEACHAT             varchar(max),
    TAXITEMGROUPACHAT         varchar(max),
    TAXENAMEVENTE             varchar(max),
    TAXITEMGROUPVENTE         varchar(max),
    GROUPEPRODUCT             varchar(max),
    GROUPDIMSUIVI             varchar(max),
    REF_SIEGE                 varchar(128),
    ITEMID                    varchar(max),
    TAXVENTEVAL               float,
    TAXACHATVAL               float,
    ACTIVITE_ART              varchar(max),
    AGENCE_ART                varchar(max),
    BU_ART                    varchar(max),
    CANAL_ART                 varchar(max),
    G_ARTICLE_ART             varchar(max),
    INTERCOS_ART              varchar(max),
    PROJET_ART                varchar(max),
    SITE_ART                  varchar(max),
    COLOR                     varchar(max),
    CONFIG                    varchar(max),
    SIZE                      varchar(max),
    STYLE                     varchar(max),
    VERSION                   varchar(max),
    IS_VARIANTE               bit,
    SHA                       varbinary(600),
    SLAVERECID                varchar(max),
    PRODUCTNAME               varchar(max),
    STORAGEDIMENSIONGROUPNAME varchar(max),
    PRODUCTDIMENSIONGROUPNAME varchar(max)
)
go

create table dbo.P_ARTICLE_CATEGORIE_AX
(
    RECID            varchar(56),
    PARENTCATEGORY   varchar(56),
    CODE1            varchar(56),
    NAME1            varchar(56),
    CLEVEL           varchar(56),
    L2RECID          varchar(56),
    L2PARENTCATEGORY varchar(56),
    L2CODE           varchar(56),
    L2NAME           varchar(56),
    L2LEVEL          varchar(56),
    L3RECID          varchar(56),
    L3PARENTCATEGORY varchar(56),
    L3CODE           varchar(56),
    L3NAME           varchar(56),
    L3LEVEL          varchar(56),
    L4RECID          varchar(56),
    L4PARENTCATEGORY varchar(56),
    L4CODE           varchar(56),
    L4NAME           varchar(56),
    L4LEVEL          varchar(56),
    L5RECID          varchar(56),
    L5PARENTCATEGORY varchar(56),
    L5CODE           varchar(56),
    L5NAME           varchar(56),
    L5LEVEL          varchar(56),
    L6RECID          varchar(56),
    L6PARENTCATEGORY varchar(56),
    L6CODE           varchar(56),
    L6NAME           varchar(56),
    L6LEVEL          varchar(56),
    L7RECID          varchar(56),
    L7PARENTCATEGORY varchar(56),
    L7CODE           varchar(56),
    L7NAME           varchar(56),
    L7LEVEL          varchar(56),
    ITEMID           varchar(56),
    SHA              varbinary(600)
)
go

create index index_codebyitem
    on dbo.P_ARTICLE_CATEGORIE_AX (CODE1) include (ITEMID)
go

create table dbo.P_BU
(
    ID_BU                      int identity
        constraint PK_P_BU
            primary key,
    BU                         varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_BU]
    on DBO.P_BU
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_BU'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_BU on dbo.P_BU
go

create table dbo.P_BUDJET_PREVISION_OBJECTIF_TYPE
(
    ID_TYPE_OBJECTIF           int not null
        constraint PK_P_TYPE_OBJECTIF
            primary key,
    TYPE_OBJECTIF              varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_BUDJET_PREVISION_OBJECTIF_TYPE]
    on dbo.P_BUDJET_PREVISION_OBJECTIF_TYPE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_BUDJET_PREVISION_OBJECTIF_TYPE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_BUDJET_PREVISION_OBJECTIF_TYPE on dbo.P_BUDJET_PREVISION_OBJECTIF_TYPE
go

create table dbo.P_CATEGORIE_ARTICLE
(
    ID_CATEGORIE               int identity
        constraint PK_P_CATEGORIE_ARTICLE
            primary key,
    CATEGORIE                  varchar(50),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    REF_SIEGE                  int
)
go

CREATE trigger [dbo].[TR_P_CATEGORIE_ARTICLE]
    on DBO.P_CATEGORIE_ARTICLE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_CATEGORIE_ARTICLE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_CATEGORIE_ARTICLE on dbo.P_CATEGORIE_ARTICLE
go

create table dbo.P_CATEGORIE_VEHICULE
(
    ID_CATEGORIE_VEHICULE         int identity
        constraint PK_P_CATEGORIE_VEHICULE
            primary key,
    CATEGORIE_VEHICULE            varchar(128),
    ID_SESSION_APPLICATIF_USER    int,
    POSTE                         varchar(128),
    SESSION_WINDOWS               varchar(128),
    NOM_UTILISATEUR               varchar(128),
    DATETIME_OP                   datetime,
    ID_CATEGORIE_VEHICULE_EXTERNE int
)
go

CREATE trigger [dbo].[TR_P_CATEGORIE_VEHICULE]
    on DBO.P_CATEGORIE_VEHICULE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_CATEGORIE_VEHICULE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_CATEGORIE_VEHICULE on dbo.P_CATEGORIE_VEHICULE
go

create table dbo.P_DEMANDEUR_EXTERNE
(
    ID_PERSONNE  int identity
        constraint PK_P_DEMANDEUR_EXTERNE
            primary key,
    NOM          varchar(50),
    PRENOM       varchar(50),
    CIN          varchar(50),
    ID_OP_SAISIE int
        constraint FK_P_DEMANDEUR_EXTERNE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_SAISIE  datetime
        constraint DF_P_DEMANDEUR_EXTERNE_DATE_SAISIE default sysdatetime()
)
go

create table dbo.P_EMPLACEMENT
(
    ID_EMPLACEMENT             int identity
        constraint PK_T_EMPLACEMENT
            primary key,
    EMPLACEMENT                varchar(20),
    ID_ENTREPOT                int,
    REF_EMPLACEMENT            varchar(25),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    LIVRAISONDATE              bit,
    ACTIF                      bit default 1,
    REFERENCE                  bit,
    IS_DEFAULT_ISSUE           bit default 0
)
go

CREATE trigger [dbo].[TR_P_EMPLACEMENT]
    on DBO.P_EMPLACEMENT
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_EMPLACEMENT'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_EMPLACEMENT on dbo.P_EMPLACEMENT
go

create table dbo.P_GAMME
(
    ID_GAMME                   int identity
        constraint PK_P_GAMME
            primary key,
    GAMME                      varchar(50) not null,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    REF_SIEGE                  int,
    DISABLED                   bit,
    DATE_HEURE_SAISIE          datetime default getdate()
)
go

CREATE trigger [dbo].[TR_P_GAMME]
    on DBO.P_GAMME
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_GAMME'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_GAMME on dbo.P_GAMME
go

create table dbo.P_GAMME_PRODUIT
(
    ID_GAMME_PRODUIT           int identity
        constraint PK_P_GAMME_PRODUIT
            primary key,
    GAMME_PRODUIT              varchar(50),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_GAMME                   int not null
        constraint FK_P_GAMME_PRODUIT_P_GAMME
            references dbo.P_GAMME,
    REF_SIEGE                  int,
    DISABLED                   bit
)
go

CREATE trigger [dbo].[TR_P_GAMME_PRODUIT]
    on dbo.P_GAMME_PRODUIT
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_GAMME_PRODUIT'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_GAMME_PRODUIT on dbo.P_GAMME_PRODUIT
go

create table dbo.P_GAMME_REMISE
(
    ID_GAMME_REMISE   int identity,
    ID_TRANCHE_REMISE int,
    ID_GAMME          int
        constraint FK_P_GAMME_REMISE_P_GAMME
            references dbo.P_GAMME,
    REMISE            float
)
go

create unique clustered index PK_P_GAMME_REMISE
    on dbo.P_GAMME_REMISE (ID_GAMME_REMISE)
go

CREATE trigger [dbo].[TR_P_GAMME_REMISE]
    on DBO.P_GAMME_REMISE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_GAMME_REMISE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_GAMME_REMISE on dbo.P_GAMME_REMISE
go

create table dbo.P_GROUPE_PRIX
(
    ID_GROUPE_PRIX             int identity
        constraint PK_T_GROUPE_PRIX
            primary key,
    LIBELLE_GROUPE             varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    REF_GROUPE                 varchar(128)
)
go

CREATE trigger [dbo].[TR_P_GROUPE_PRIX]
    on dbo.P_GROUPE_PRIX
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_GROUPE_PRIX'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_GROUPE_PRIX on dbo.P_GROUPE_PRIX
go

create table dbo.P_MARQUE
(
    ID_MARQUE                  int identity
        constraint PK_MARQUE
            primary key,
    MARQUE                     varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_MARQUE_EXTERNE          int
)
go

CREATE trigger [dbo].[TR_P_MARQUE]
    on DBO.P_MARQUE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_MARQUE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_MARQUE on dbo.P_MARQUE
go

create table dbo.P_MODELE
(
    ID_MODELE                  int identity
        constraint PK_P_MODELE
            primary key,
    ID_MARQUE                  int
        constraint FK_P_MODELE_MARQUE
            references dbo.P_MARQUE,
    MODELE                     varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_MODELE_EXTERNE          int
)
go

CREATE trigger [dbo].[TR_P_MODELE]
    on DBO.P_MODELE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_MODELE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_MODELE on dbo.P_MODELE
go

create table dbo.P_NATURE_INFORMATION
(
    ID_NATURE_INFORMATION      int identity
        constraint PK_P_NATURE_INFORMATION
            primary key,
    INFORMATION                varchar(56),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_NATURE_INFORMATION]
    on DBO.P_NATURE_INFORMATION
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_NATURE_INFORMATION'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_NATURE_INFORMATION on dbo.P_NATURE_INFORMATION
go

create table dbo.P_PJ
(
    ID_PJ        int identity
        constraint PK_P_PJ
            primary key,
    PJ_NAME      varchar(max),
    PJ_EXTENSION varchar(50),
    DATE_ADD     datetime
        constraint DF_P_PJ_DATE_ADD default getdate(),
    ID_OP_SAISIE int
        constraint FK_P_PJ_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ACTIF        bit
        constraint DF_P_PJ_ACTIF default 1,
    ROUTE        varchar(max),
    ID_PROJET    int
        constraint FK_P_PJ_GP_PROJET
            references dbo.GP_PROJET,
    ID_MODULE    int
        constraint FK_P_PJ_A_MODULE
            references dbo.GP_MODULE,
    ID_US        int
        constraint FK_P_PJ_GP_USER_STORY
            references dbo.GP_USER_STORY
)
go

create table dbo.P_PRODUCTEUR
(
    ID_PRODUCTEUR         int identity
        constraint PK_P_PRODUCTEUR
            primary key,
    PRODUCTEUR            varchar(50),
    ID_ADHERENT           int
        constraint FK_P_PRODUCTEUR_P_ADHERENT
            references dbo.P_ADHERENT,
    REF_PRODUCTEUR        varchar(50)
        unique,
    ACTIF                 bit,
    REF_EXTERN_PRODUCTEUR int,
    SysStartTime          datetime2
        constraint DF_producteur_SysStart default sysutcdatetime()                                  not null,
    SysEndTime            datetime2
        constraint DF_producteur_SysEnd default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    VERTUELLE             bit,
    COMMANTAIRE_COLLECTE  varchar(255),
    COMMANTAIRE_VERGER    varchar(255)
)
go

create table dbo.P_PROMOTION_TYPE
(
    ID_TYPE_PROMOTION          int identity
        constraint PK_P_PROMOTION_TYPE
            primary key,
    TYPE_PROMOTION             varchar(52),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

create table dbo.P_PROMOTIONS
(
    ID_PROMOTION               int identity
        constraint PK_T_PROMOTIONS
            primary key,
    DESCRIPTION                varchar(128),
    DATE_DEBUT                 date,
    DATE_FIN                   date,
    DATE_HEURS_SAISIE          datetime
        constraint DF_T_PROMOTIONS_DATE_HEURS_SAISIE default getdate(),
    ID_OP_SAISIE               int,
    ID_TYPE_PROMOTION          int
        constraint FK_P_PROMOTIONS_P_PROMOTION_TYPE
            references dbo.P_PROMOTION_TYPE,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_PROMOTION_TYPE]
    on dbo.P_PROMOTION_TYPE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_PROMOTION_TYPE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_PROMOTION_TYPE on dbo.P_PROMOTION_TYPE
go

create table dbo.P_PROPRIETAIRE
(
    ID_PROPRIETAIRE            int identity
        constraint PK_P_PROPRIETAIRE
            primary key,
    PROPRIETAIRE               varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_PROP_EXTERNE            int,
    VENDORACCOUNTNUMBER        varchar(128)
)
go

create table dbo.P_CHAUFFEUR
(
    ID_CHAUFFEUR         int identity
        constraint PK_P_CHAUFFEUR
            primary key,
    NOM_COMPLET          varchar(50),
    ID_UTILISATEUR       int
        constraint FK_P_CHAUFFEUR_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_PROPRIETAIRE      int
        constraint FK_P_CHAUFFEUR_P_PROPRIETAIRE
            references dbo.P_PROPRIETAIRE,
    ID_CHAUFFEUR_EXTERNE int,
    ID_OP_SAISIE         int
        constraint FK_P_CHAUFFEUR_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    DATE_SAISIE          datetime,
    CIN                  varchar(50),
    TEL                  varchar(28)
)
go

CREATE trigger [dbo].[TR_P_PROPRIETAIRE]
    on DBO.P_PROPRIETAIRE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_PROPRIETAIRE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_PROPRIETAIRE on dbo.P_PROPRIETAIRE
go

create table dbo.P_QUAI
(
    ID_QUAI        int identity
        constraint PK_P_QUAI
            primary key,
    REFERENCE      varchar(50),
    ACTIF          bit,
    ID_EMPLACEMENT int
        constraint FK_P_QUAI_P_EMPLACEMENT
            references dbo.P_EMPLACEMENT
)
go

create table dbo.P_QUINZAINE
(
    ID_QUINZAINE int not null
        constraint PK_P_QUINZAINE
            primary key,
    QUINZAINE    varchar(50)
        constraint UNIQUE_QUINZAINE
            unique
)
go

create table dbo.P_REMISE_FACTURE
(
    REMISE_POURCENT            float,
    DESCRIPTION                varchar(1028),
    ID_OP_SAISIE               int
        constraint FK_P_REMISE_FACTURE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_HEUR_SAISIE           datetime
        constraint DF_P_REMISE_FACTURE_DATE_HEUR_SAISIE default getdate(),
    ID_REMISE_FACTURE          int identity
        constraint PK_P_REMISE_FACTURE
            primary key,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

create table dbo.P_REMISE_FACTURE_GAMME
(
    ID_REMISE_FACTURE          int
        constraint FK_P_REMISE_FACTURE_GAMME_P_REMISE_FACTURE
            references dbo.P_REMISE_FACTURE,
    ID_GAMME                   int
        constraint FK_P_REMISE_FACTURE_GAMME_P_GAMME
            references dbo.P_GAMME,
    ID_REMISE_FACTURE_GAMME    int identity
        constraint PK_P_REMISE_FACTURE_GAMME
            primary key,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

create table dbo.P_REMISE_GAMME_PRODUIT
(
    ID_REMISE         bigint not null,
    ID_GAMME_PRODUIT  int    not null,
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    ID_OP_SAISIE      int
        constraint P_REMISE_GAMME_PRODUIT_A_UTILISATEUR_ID_UTILISATEUR_fk
            references dbo.A_UTILISATEUR,
    ANNULER           int      default 0,
    constraint PRIMARY_KEY
        primary key (ID_REMISE, ID_GAMME_PRODUIT),
    constraint P_REMISE_GAMME_PRODUIT_pk
        unique (ID_REMISE, ID_GAMME_PRODUIT)
)
go

create table dbo.P_REMISE_SITE
(
    ID_REMISE         int not null,
    ID_SITE           int not null
        constraint PK_P_REMISE_SITE
            primary key,
    DATE_HEURE_SAISIE datetime,
    ID_OP_SAISIE      int,
    ANNULER           int default 0
)
go

create table dbo.P_SECTEUR_TYPE
(
    ID_TYPE_SECTEUR            int identity
        constraint PK_P_SECTEUR_TYPE
            primary key,
    TYPE_SECTEUR               varchar(50),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_SECTEUR_TYPE]
    on DBO.P_SECTEUR_TYPE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_SECTEUR_TYPE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_SECTEUR_TYPE on dbo.P_SECTEUR_TYPE
go

create table dbo.P_SECTION_ACTIVITE
(
    ID_SECTION         int identity
        constraint PK_P_SECTION_ACTIVITE
            primary key,
    SECTION            varchar(128),
    ID_SECTION_EXTERNE int
)
go

create table dbo.P_CATEGORIE_ACTIVITE
(
    ID_CATEGORIE         int identity
        constraint PK_P_CATEGORIE_ACTIVITE
            primary key,
    CATEGORIE            varchar(50),
    ID_BU                int,
    ID_CATEGORIE_EXTERNE int,
    ID_SECTION_ACTIVITE  int
        constraint FK_P_CATEGORIE_ACTIVITE_P_SECTION_ACTIVITE
            references dbo.P_SECTION_ACTIVITE,
    ABRV                 varchar(56)
)
go

create table dbo.P_CATEGORIE_ACTIVITE_UTILISATEUR
(
    ID_UTILISATEUR int                                                                   not null
        references dbo.A_UTILISATEUR,
    ID_CATEGORIE   int                                                                   not null
        references dbo.P_CATEGORIE_ACTIVITE,
    ID_OP_SAISIE   int,
    DATETIME       datetime
        constraint DF_P_CATEGORIE_ACTIVITE_UTILISATEUR_DATETIME_OP default getdate(),
    ACTIVE         bit
        constraint DF_P_CATEGORIE_ACTIVITE_UTILISATEUR_ACTIVE default 1,
    SysStartTime   datetime2 default getutcdate()                                        not null,
    SysEndTime     datetime2 default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    primary key (ID_UTILISATEUR, ID_CATEGORIE)
)
go

create table dbo.P_SHIFT
(
    ID_SHIFT     int identity
        constraint PK_P_SHIFT
            primary key,
    LIBELLE      varchar(100)                           not null,
    HEURE_DEBUT  tinyint                                not null,
    HEURE_FIN    tinyint                                not null,
    NBR_HEURE    tinyint                                not null,
    ID_OPERATEUR int                                    not null
        constraint FK_P_SHIFT_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATESYS      datetime
        constraint DF_P_SHIFT_DATESYS default getdate() not null
)
go

create table dbo.P_SITE
(
    REF_SITE                   varchar(50) not null,
    SITE                       varchar(50),
    ID_AGENCE                  int,
    ID_SITE                    int identity
        constraint PK_P_SITE
            primary key,
    TEL_SITE                   varchar(50),
    FAX_SITE                   varchar(50),
    ADRESSE_SITE               varchar(50),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_CHEF_AGENCE             int
        constraint FK__P_SITE__ID_CHEF___0A695708
            references dbo.A_UTILISATEUR,
    ID_DIRECTEUR_REGIONAL      int
        constraint FK__P_SITE__ID_DIREC__0B5D7B41
            references dbo.A_UTILISATEUR,
    ID_DIRECTEUR_COMMERCIAL    int
        constraint FK__P_SITE__ID_DIREC__0C519F7A
            references dbo.A_UTILISATEUR,
    BU                         varchar(50),
    ID_TOURNEE_COLLECTE        int,
    ID_CHAMPS_ACCES            int
        constraint FK_P_SITE_A_CHAMP
            references dbo.A_CHAMP,
    REF_SIEGE                  int,
    DROIT_TIMBRE               float
)
go

create table dbo.A_RESPONSABLE_SITE
(
    ID_USER_PROFIL int not null
        constraint FK_A_RESPONSABLE_SITE_A_RESPONSABLE_USER_PROFIL
            references dbo.A_RESPONSABLE_USER_PROFIL,
    ID_SITE        int
        constraint FK_A_RESPONSABLE_SITE_P_SITE
            references dbo.P_SITE,
    DATE_SAISIE    datetime
        constraint DF_A_RESPONSABLE_SITE_DATE_SAISIE default getdate(),
    constraint UNIQSR
        unique (ID_USER_PROFIL, ID_SITE)
)
go

create table dbo.GD_STATION_DEPOTAGE
(
    ID_STATION        int identity
        primary key,
    LIBELLE           varchar(50) not null,
    ACTIF             bit      default 1,
    ID_SITE           int         not null
        references dbo.P_SITE,
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    OP_SAISIE         int
        references dbo.A_UTILISATEUR
)
go

create table dbo.GC_CUVE
(
    ID_CUVE    int identity
        constraint PK_D_CUVE
            primary key,
    LIBELLE    varchar(50),
    ACTIF      bit
        constraint DF_GC_CUVE_ACTIF default 1,
    ID_STATION int
        references dbo.GD_STATION_DEPOTAGE
)
go

create table dbo.GD_LIGNE
(
    ID_LIGNE            int identity
        primary key,
    LIBELLE             varchar(50) not null,
    ACTIF               bit      default 1,
    ID_STATION_DEPOTAGE int
        references dbo.GD_STATION_DEPOTAGE,
    DATE_HEURE_SAISIE   datetime default sysdatetime(),
    OP_SAISIE           int
        references dbo.A_UTILISATEUR
)
go

create table dbo.GD_STATION_AGENT
(
    ID_AGENT          int not null
        constraint FK_GD_STATION_AGENT_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_STATION        int not null
        constraint FK_GD_STATION_AGENT_GD_STATION_DEPOTAGE
            references dbo.GD_STATION_DEPOTAGE,
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    OP_SAISIE         int
        references dbo.A_UTILISATEUR,
    primary key (ID_AGENT, ID_STATION)
)
go

create table dbo.P_ENTREPOT
(
    ID_SITE                             int
        constraint FK_P_ENTREPOT_P_SITE
            references dbo.P_SITE,
    ID_ENTREPOT                         int identity
        constraint PK_T_ENTREPOT
            primary key,
    ENTREPOT                            varchar(128),
    REF_ENTREPOT                        varchar(56)
        constraint UNIQUE_REF_ENTREPOT
            unique,
    ID_SESSION_APPLICATIF_USER          int,
    POSTE                               varchar(128),
    SESSION_WINDOWS                     varchar(128),
    NOM_UTILISATEUR                     varchar(128),
    DATETIME_OP                         datetime,
    ID_OP_SAISIE                        int
        constraint FK_P_ENTREPOT_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_INVENTLOCATIONIDTRANSIT          int
        constraint FK_P_ENTREPOT_P_ENTREPOT
            references dbo.P_ENTREPOT,
    ID_WMSLOCATIONIDDEFAULTISSUE        int
        constraint FK_P_ENTREPOT_P_EMPLACEMENT
            references dbo.P_EMPLACEMENT,
    ID_WMSLOCATIONIDDEFAULTRECEIPT      int
        constraint FK_P_ENTREPOT_P_EMPLACEMENT1
            references dbo.P_EMPLACEMENT,
    ACTIVITE                            varchar(50),
    AGENCE                              varchar(50),
    BU                                  varchar(50),
    CANAL                               varchar(50),
    G_ARTICLE                           varchar(50),
    INTERCOS                            varchar(50),
    PROJET                              varchar(50),
    SITE                                varchar(50),
    AJUSTAXEWITHANALYTIQUE              bit
        constraint DF_P_ENTREPOT_AJUSTAXEWITHANALITIQUE default 0,
    IS_PF                               bit
        constraint DF_P_ENTREPOT_IS_PF default 0,
    LOT_GENERIQUE                       bit
        constraint DF_P_ENTREPOT_LOT_GENERIQUE default 0,
    DLC_GENERIQUE                       bit
        constraint DF_P_ENTREPOT_DLC_GENERIQUE default 0,
    NUM_SERIE_GENERIQUE                 bit
        constraint DF_P_ENTREPOT_NUM_SERIE_GENERIQUE default 0,
    ID_ECART_EMPLACEMENT                int,
    ID_PERTE_EMPLACEMENT                int,
    IS_WMS                              bit default 0,
    LIVRAISONDATE                       bit default 0,
    ID_WMSLOCATIONDEFAULTPREPARATION    int
        references dbo.P_EMPLACEMENT,
    ID_WMSLOCATIONDEFAULTTRANSFORMATION int
        references dbo.P_EMPLACEMENT,
    LIBELLE                             varchar(1),
    ID_PAQUETISATION_EMPLACEMENT        int,
    TYPE                                varchar(128),
    IS_STOCK_REP                        bit,
    DLV_GENERIQUE                       bit,
    UNITE_EMBALAGE_GENERIQUE            bit,
    REF_ARTICLE_GENERIQUE               bit
)
go

create table dbo.DELETE_ST_INVENTAIRE
(
    REF_INVENTAIRE            varchar(50) not null,
    DATE_INVENTAIRE           datetime    not null,
    DATE_SAISIE               datetime
        constraint DF_ST_INVENTAIRE_DATE_SAISIE default getdate(),
    ID_OP_SAISIE              int
        constraint FK_ST_INVENTAIRE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_TYPE_INVENTAIRE        int         not null
        constraint FK_ST_INVENTAIRE_ST_TYPE_INVENTAIRE
            references dbo.DELETE_ST_TYPE_INVENTAIRE,
    ID_ETAT_INVENTAIRE        int
        constraint FK_ST_INVENTAIRE_ST_ETAT_INVENTAIRE
            references dbo.DELETE_ST_ETAT_INVENTAIRE,
    ID_ENTREPOT               int         not null
        constraint FK_ST_INVENTAIRE_P_ENTREPOT
            references dbo.P_ENTREPOT,
    ID_RESPONSABLE_INVENTAIRE int
        constraint FK_ST_INVENTAIRE_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    ID_INVENTAIRE             int identity
        constraint PK_ST_INVENTAIRE
            primary key,
    DATE_ECART_SAISIE         datetime,
    OP_ECART                  int
        constraint FK_ST_INVENTAIRE_A_UTILISATEUR2
            references dbo.A_UTILISATEUR,
    SUM_ECART                 float
)
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.A_UTILISATEUR.ID_UTILISATEUR', 'SCHEMA', 'dbo', 'TABLE',
     'DELETE_ST_INVENTAIRE', 'COLUMN', 'ID_OP_SAISIE'
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.P_ENTREPOT.ID_ENTREPOT', 'SCHEMA', 'dbo', 'TABLE',
     'DELETE_ST_INVENTAIRE', 'COLUMN', 'ID_ENTREPOT'
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.A_UTILISATEUR.ID_UTILISATEUR', 'SCHEMA', 'dbo', 'TABLE',
     'DELETE_ST_INVENTAIRE', 'COLUMN', 'ID_RESPONSABLE_INVENTAIRE'
go

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER BEFOTVALIDATIONCOUNTING
    ON [ST_INVENTAIRE]
    AFTER UPDATE
    AS
BEGIN
    --SELECT * FROM ST_ETAT_INVENTAIRE
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF (SELECT COUNT(*) FROM INSERTED) > 0 AND (SELECT COUNT(*) FROM DELETED) > 0
        BEGIN
            IF ((SELECT id_ETAT_INVENTAIRE FROM INSERTED) != (SELECT id_ETAT_INVENTAIRE FROM DELETED)) AND
               (SELECT id_ETAT_INVENTAIRE FROM INSERTED) = 2 AND
               ((SELECT id_INVENTAIRE FROM INSERTED) = (SELECT id_INVENTAIRE FROM DELETED))
                BEGIN
                    DECLARE @NBR_ARTICLE_NON_COMPTE INT;
                    SET @NBR_ARTICLE_NON_COMPTE = 0;
                    SELECT @NBR_ARTICLE_NON_COMPTE = COUNT(*)
                    FROM [dbo].[INVENTAIRE_STOCK_THEORIQUE]
                    WHERE ID_INVENTAIRE = (SELECT id_INVENTAIRE FROM INSERTED)
                      AND QTE_THEORIQUE > 0
                      AND NBR_DT = 0
                    IF @NBR_ARTICLE_NON_COMPTE > 0
                        BEGIN
                            ROLLBACK
                            DECLARE @MESSAGEERR VARCHAR(516);
                            SET @MESSAGEERR = 'Oups ! Il existe ' + CAST(@NBR_ARTICLE_NON_COMPTE AS VARCHAR(6)) +
                                              ' article(s) non comptés, avec quantités théoriques supérieur à zero'
                            RAISERROR (
                                @MESSAGEERR, -- Message text.
                                16, -- Severity.
                                1 -- State.
                                );
                        END
                END
        END

    -- Insert statements for trigger here

END
go

disable trigger dbo.BEFOTVALIDATIONCOUNTING on dbo.DELETE_ST_INVENTAIRE
go

alter table dbo.P_EMPLACEMENT
    add constraint FK_P_EMPLACEMENT_P_ENTREPOT
        foreign key (ID_ENTREPOT) references dbo.P_ENTREPOT
go

create index REF_ENTREPOT_INDEX
    on dbo.P_ENTREPOT (REF_ENTREPOT)
go

create index ID_ENTREPOT_INDEX
    on dbo.P_ENTREPOT (ID_ENTREPOT)
go

CREATE trigger [dbo].[TR_P_ENTREPOT]
    on dbo.P_ENTREPOT
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_ENTREPOT'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_ENTREPOT on dbo.P_ENTREPOT
go

create table dbo.P_ENTREPOT_ENTREPOT
(
    ID_ENTREPOT      int not null
        constraint FK_P_ENTREPOT_ENTREPOT_P_ENTREPOT
            references dbo.P_ENTREPOT,
    ID_ENTREPOT_DEST int not null
        constraint FK_P_ENTREPOT_ENTREPOT_P_ENTREPOT1
            references dbo.P_ENTREPOT,
    DATETIME         datetime,
    ID_OP            int
        constraint FK_P_ENTREPOT_ENTREPOT_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    CMD_OBLIGATOIR   bit default 0,
    constraint PK_P_ENTREPOT_ENTREPOT
        primary key (ID_ENTREPOT, ID_ENTREPOT_DEST)
)
go

create table dbo.P_INFRASTRUCTURE_TECHNIQUE
(
    ID_INFRASTRUCTURE          int identity
        constraint PK_P_INFRASTRUCTURE_TECHNIQUE
            primary key,
    ADRESSE                    varchar(512),
    LOGIN                      varchar(128),
    MDP                        varchar(128),
    CLE_CRYPTAGE               varchar(128),
    ID_NATURE_INFORMATION      int
        constraint FK_P_INFRASTRUCTURE_TECHNIQUE_P_NATURE_INFORMATION
            references dbo.P_NATURE_INFORMATION,
    DESCRIPTION                varchar(1028),
    ID_SITE                    int
        constraint FK_P_INFRASTRUCTURE_TECHNIQUE_P_SITE
            references dbo.P_SITE,
    ID_MODULE                  int
        constraint FK_P_INFRASTRUCTURE_TECHNIQUE_A_MODULE
            references dbo.A_MODULE,
    ACTIF                      bit,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_INFRASTRUCTURE_TECHNIQUE]
    on DBO.P_INFRASTRUCTURE_TECHNIQUE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_INFRASTRUCTURE_TECHNIQUE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_INFRASTRUCTURE_TECHNIQUE on dbo.P_INFRASTRUCTURE_TECHNIQUE
go

create table dbo.P_MOBILE
(
    ID_MOBILE            int identity
        constraint PK_P_MOBILE
            primary key,
    MEI                  varchar(100),
    Ref                  varchar(50),
    DATE_MISE_PROD       datetime,
    AUTORISER            bit      default 0,
    DETRUITS             bit,
    DATE_FIN_UTILISATION datetime,
    DATE_DESTRUCTION     datetime,
    ID_SITE              int
        constraint FK_P_MOBILE_P_SITE
            references dbo.P_SITE,
    ID_OP_SAISIE         int,
    DATE_HEURE_SAISIE    datetime default sysdatetime()
)
go

create unique index P_MOBILE_MEI_uindex
    on dbo.P_MOBILE (MEI)
go

CREATE trigger [dbo].[TR_P_MOBILE]
    on DBO.P_MOBILE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_MOBILE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_MOBILE on dbo.P_MOBILE
go

create table dbo.P_MOBILE_MODULE
(
    ID_MOBILE                  int not null
        constraint FK_P_MOBILE_MODULE_P_MOBILE
            references dbo.P_MOBILE,
    ID_MODULE                  int not null
        constraint FK_P_MOBILE_MODULE_A_MODULE
            references dbo.A_MODULE,
    AUTORISER                  bit not null,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    primary key (ID_MOBILE, ID_MODULE)
)
go

CREATE trigger [dbo].[TR_P_MOBILE_MODULE]
    on DBO.P_MOBILE_MODULE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_MOBILE_MODULE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_MOBILE_MODULE on dbo.P_MOBILE_MODULE
go

create table dbo.P_PARC_MACHINE
(
    ID_PARC_MACHINE            int identity
        constraint PK_P_PARC_MACHINE
            primary key,
    PARC                       varchar(50),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    CODE_ATELIER_SIEGE         int,
    ID_ENTREPOT_TEMPON         int
        constraint FK_P_PARC_MACHINE_P_ENTREPOT
            references dbo.P_ENTREPOT,
    ID_ENTREPOT_EMBALAGE       int
        constraint FK_P_PARC_MACHINE_P_ENTREPOT1
            references dbo.P_ENTREPOT
)
go

create table dbo.P_FAMILLE_ARTICLE
(
    ID_FAMILLE                 int identity
        constraint PK_T_FAMILLE_ARTICLE
            primary key,
    FAMILLE                    varchar(56),
    POIDS                      float,
    TVA                        int,
    ID_PARC_MACHINE            int
        constraint FK_P_FAMILLE_ARTICLE_P_PARC_MACHINE
            references dbo.P_PARC_MACHINE,
    ID_CATEGORIE_ARTICLE       int
        constraint FK_P_FAMILLE_ARTICLE_P_CATEGORIE_ARTICLE
            references dbo.P_CATEGORIE_ARTICLE,
    ID_GAMME_PRODUIT           int
        constraint FK_P_FAMILLE_ARTICLE_P_GAMME_PRODUIT
            references dbo.P_GAMME_PRODUIT,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    REF_SIEGE                  int,
    DISABLED                   bit
)
go

create table dbo.P_ARTICLE
(
    LIBELLE                          varchar(265),
    CLE_AX                           varchar(128),
    MASTERRECID                      varchar(128),
    ID_ARTICLE                       int identity
        constraint PK_T_ARTICLE
            primary key,
    ID_FAMILLE_ARTICLE               int
        constraint FK_P_ARTICLE_P_FAMILLE_ARTICLE
            references dbo.P_FAMILLE_ARTICLE,
    UNITE_VENTE                      int,
    UNITE_STOCK                      int,
    STOCKABLE                        bit,
    ABREVIATION                      varchar(128),
    BARRE_CODE                       varchar(56),
    UNITE_COMMANDE                   int,
    MODELPRIX                        varchar(156),
    UNITE_ACHAT                      int,
    GROUPTAXEACHAT                   varchar(128),
    UNITEPRIXSTOCK                   float,
    UNITEPRIXVENTE                   float,
    UNITEPRIXACHAT                   float,
    GROUPPRODUITNAME                 varchar(128),
    TAXENAMEACHAT                    varchar(128),
    TAXITEMGROUPACHAT                varchar(128),
    TAXENAMEVENTE                    varchar(128),
    TAXITEMGROUPVENTE                varchar(128),
    GROUPEPRODUCT                    varchar(128),
    GROUPDIMSUIVI                    varchar(128),
    REF_SIEGE                        varchar(128),
    ITEMID                           varchar(56),
    TX_TVA                           float,
    TAXACHATVAL                      float,
    ACTIVITE_ART                     varchar(56),
    AGENCE_ART                       varchar(56),
    BU_ART                           varchar(56),
    CANAL_ART                        varchar(56),
    G_ARTICLE_ART                    varchar(56),
    INTERCOS_ART                     varchar(56),
    PROJET_ART                       varchar(56),
    SITE_ART                         varchar(56),
    COLOR                            varchar(56),
    CONFIG                           varchar(56),
    SIZE                             varchar(56),
    STYLE                            varchar(56),
    VERSION                          varchar(56),
    IS_VARIANTE                      bit,
    SHA                              varbinary(600),
    PRODUCTNAME                      varchar(128),
    SLAVERECID                       varchar(56),
    STORAGEDIMENSIONGROUPNAME        varchar(128),
    PRODUCTDIMENSIONGROUPNAME        varchar(128),
    ANNULER                          bit
        constraint DF_P_ARTICLE_ANNULER default 0,
    VARIANTID                        varchar(56),
    INVENTDIMID                      varchar(56),
    SEARCHNAME                       varchar(56),
    MODELGROUPNAME                   varchar(128),
    STOPPEDSTK                       bit,
    STOPPEDSALES                     bit,
    STOPPEDPURCH                     bit,
    GROUPDIMSUIVINAME                varchar(128),
    STORAGEDIMENSIONGROUPDESCRIPTION varchar(128),
    PMU_GLOBALE                      float
)
go

create index INDEXONANNULER
    on dbo.P_ARTICLE (ANNULER) include (LIBELLE, CLE_AX, MASTERRECID, ID_ARTICLE, ID_FAMILLE_ARTICLE, UNITE_VENTE,
                                        UNITE_STOCK, STOCKABLE, ABREVIATION, BARRE_CODE, UNITE_COMMANDE, MODELPRIX,
                                        UNITE_ACHAT, GROUPTAXEACHAT, UNITEPRIXSTOCK, UNITEPRIXVENTE, UNITEPRIXACHAT,
                                        GROUPPRODUITNAME, TAXENAMEACHAT, TAXITEMGROUPACHAT, TAXENAMEVENTE,
                                        TAXITEMGROUPVENTE, GROUPEPRODUCT, GROUPDIMSUIVI, REF_SIEGE, ITEMID, TX_TVA,
                                        TAXACHATVAL, ACTIVITE_ART, AGENCE_ART, BU_ART, CANAL_ART, G_ARTICLE_ART,
                                        INTERCOS_ART, PROJET_ART, SITE_ART, COLOR, CONFIG, SIZE, STYLE, VERSION,
                                        IS_VARIANTE, SHA, PRODUCTNAME, SLAVERECID, STORAGEDIMENSIONGROUPNAME,
                                        PRODUCTDIMENSIONGROUPNAME, VARIANTID, INVENTDIMID, SEARCHNAME, MODELGROUPNAME,
                                        STOPPEDSTK, STOPPEDSALES, STOPPEDPURCH, GROUPDIMSUIVINAME,
                                        STORAGEDIMENSIONGROUPDESCRIPTION)
go

create index [NonClusteredIndex-JOINTUREIMAGESTOCK]
    on dbo.P_ARTICLE (CONFIG, COLOR, SIZE, STYLE, VERSION, ITEMID) include (LIBELLE, CLE_AX, MASTERRECID, ID_ARTICLE,
                                                                            ID_FAMILLE_ARTICLE, UNITE_VENTE,
                                                                            UNITE_STOCK, STOCKABLE, ABREVIATION,
                                                                            BARRE_CODE, UNITE_COMMANDE, MODELPRIX,
                                                                            UNITE_ACHAT, GROUPTAXEACHAT, UNITEPRIXSTOCK,
                                                                            UNITEPRIXVENTE, UNITEPRIXACHAT,
                                                                            GROUPPRODUITNAME, TAXENAMEACHAT,
                                                                            TAXITEMGROUPACHAT, TAXENAMEVENTE,
                                                                            TAXITEMGROUPVENTE, GROUPEPRODUCT,
                                                                            GROUPDIMSUIVI, REF_SIEGE, TX_TVA,
                                                                            TAXACHATVAL, ACTIVITE_ART, AGENCE_ART,
                                                                            BU_ART, CANAL_ART, G_ARTICLE_ART,
                                                                            INTERCOS_ART, PROJET_ART, SITE_ART,
                                                                            IS_VARIANTE, SHA, PRODUCTNAME, SLAVERECID,
                                                                            STORAGEDIMENSIONGROUPNAME,
                                                                            PRODUCTDIMENSIONGROUPNAME, ANNULER,
                                                                            VARIANTID, INVENTDIMID, SEARCHNAME,
                                                                            MODELGROUPNAME, STOPPEDSTK, STOPPEDSALES,
                                                                            STOPPEDPURCH, GROUPDIMSUIVINAME,
                                                                            STORAGEDIMENSIONGROUPDESCRIPTION)
go

create index index_article
    on dbo.P_ARTICLE (ANNULER, STOPPEDSALES) include (LIBELLE, ID_ARTICLE, UNITE_STOCK, REF_SIEGE, ITEMID)
go

create index indexarticle
    on dbo.P_ARTICLE (ITEMID, ANNULER, STOPPEDSALES) include (LIBELLE, ID_ARTICLE, UNITE_STOCK, REF_SIEGE)
go

CREATE trigger [dbo].[TR_P_ARTICLE]
    on dbo.P_ARTICLE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_ARTICLE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_ARTICLE on dbo.P_ARTICLE
go

create table dbo.P_ARTICLE_CATEGORIE_AX2
(
    ID_ARTICLE          int
        constraint FK_P_ARTICLE_CATEGORIE_AX_P_ARTICLE
            references dbo.P_ARTICLE,
    CATEGORIE           varchar(max),
    CATEGORIEHIERARCHIE varchar(max),
    AXRECID             varchar(max)
)
go

create table dbo.P_ARTICLE_CODEBARE_AX
(
    BARCODE    varchar(50),
    ID_ARTICLE int
        constraint FK_P_ARTICLE_CODEBARE_AX_P_ARTICLE
            references dbo.P_ARTICLE,
    AXRECID    varchar(50)
)
go

create table dbo.P_DT_PROMOTION
(
    ID_PROMOTION               int
        constraint FK_P_DT_PROMOTION_P_PROMOTIONS
            references dbo.P_PROMOTIONS,
    ID_ARTICLE                 int
        constraint FK_P_DT_PROMOTION_P_ARTICLE
            references dbo.P_ARTICLE,
    TX_GRATUIT                 float,
    TRANCHE_FROM               float,
    TRANCHE_TO                 float,
    ID_DT_PROMOTION            int identity
        constraint PK_P_DT_PROMOTION
            primary key,
    ID_FAMILLE                 int
        constraint FK_P_DT_PROMOTION_P_FAMILLE_ARTICLE
            references dbo.P_FAMILLE_ARTICLE,
    ID_GAMME                   int
        constraint FK_P_DT_PROMOTION_P_GAMME
            references dbo.P_GAMME,
    ACTIF                      bit,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_OP_SAISIE               int,
    DATE_HEURE_SAISIE          datetime default getdate()
)
go

CREATE trigger [dbo].[TR_P_DT_PROMOTION]
    on DBO.P_DT_PROMOTION
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_DT_PROMOTION'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_DT_PROMOTION on dbo.P_DT_PROMOTION
go

CREATE trigger [dbo].[TR_P_FAMILLE_ARTICLE]
    on dbo.P_FAMILLE_ARTICLE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_FAMILLE_ARTICLE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_FAMILLE_ARTICLE on dbo.P_FAMILLE_ARTICLE
go

create table dbo.P_MACHINE
(
    ID_MACHINE            int identity
        constraint PK_P_MACHINE
            primary key,
    LIBELLE               varchar(100) not null,
    ID_MACHINE_SIEGE      int          not null,
    ID_PARC_MACHINE       int          not null
        constraint FK_P_MACHINE_P_PARC_MACHINE
            references dbo.P_PARC_MACHINE,
    ACTIF                 bit          not null,
    ORDINATEUR_IMPRESSION varchar(128)
)
go

create table dbo.AM_SHIFT_MACHINE_PILOTE
(
    ID         bigint identity,
    ID_SHIFT   int not null
        constraint FK_AM_SHIFT_MACHINE_PILOTE_P_SHIFT
            references dbo.P_SHIFT,
    ID_MACHINE int not null
        constraint FK_AM_SHIFT_MACHINE_PILOTE_P_MACHINE
            references dbo.P_MACHINE,
    ID_PILOTE  int not null
        constraint FK_AM_SHIFT_MACHINE_PILOTE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ACTIF      bit,
    constraint PK_AM_SHIFT_MACHINE_PILOTE
        primary key (ID_SHIFT, ID_MACHINE, ID_PILOTE)
)
go

CREATE trigger [dbo].[TR_P_PARC_MACHINE]
    on DBO.P_PARC_MACHINE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_PARC_MACHINE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_PARC_MACHINE on dbo.P_PARC_MACHINE
go

create table dbo.P_REMISE_FIN_MOIS
(
    ID_REMISE                  int identity
        constraint PK_P_REMISE_FIN_MOIS
            primary key,
    TITRE                      nvarchar(50),
    DESCRIPTION                nvarchar(150),
    OPERATEUR_SAISIE           int,
    DATE_SAISIE                datetime
        constraint date_saisie_defailt default getdate(),
    ACTIF                      bit
        constraint DF_REMISE_ACTIF default 1,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_SITE                    int
        constraint FK_P_REMISE_FIN_MOIS_P_SITE
            references dbo.P_SITE
)
go

create table dbo.P_REMISE_CALCULE
(
    ID_REMISE_CALCULE          int identity
        constraint PK_P_REMISE_CALCULE
            primary key,
    MOIS                       smallint,
    ANNEE                      int,
    DATE_CALCULE               datetime,
    ID_SITE                    int
        constraint FK_P_REMISE_CALCULE_P_SITE
            references dbo.P_SITE,
    ID_REMISE                  int
        constraint FK_P_REMISE_CALCULE_P_REMISE_FIN_MOIS
            references dbo.P_REMISE_FIN_MOIS,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_REMISE_CALCULE]
    on DBO.P_REMISE_CALCULE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_REMISE_CALCULE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_REMISE_CALCULE on dbo.P_REMISE_CALCULE
go

create table dbo.P_RFM_GAMME_EXCLUDE
(
    ID_GAMME_EXCLUDE int identity
        constraint PK_P_RFM_GAMME_EXCLUDE
            primary key,
    ID_GAMME_PRODUIT int
        constraint FK_P_RFM_GAMME_EXCLUDE_P_GAMME_PRODUIT
            references dbo.P_GAMME_PRODUIT,
    ID_SITE          int
        constraint FK_P_RFM_GAMME_EXCLUDE_P_SITE
            references dbo.P_SITE
)
go

CREATE trigger [dbo].[TR_P_SITE]
    on dbo.P_SITE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_SITE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_SITE on dbo.P_SITE
go

create table dbo.P_TRANCHE_REMISE
(
    ID_TRANCHE_REMISE   bigint identity
        constraint P_TRANCHE_REMISE_pk
            primary key nonclustered,
    TRANCHE_FROM        int,
    ID_REMISE           int
        constraint FK_P_TRANCHE_REMISE_P_REMISE_FIN_MOIS
            references dbo.P_REMISE_FIN_MOIS,
    TAUX_CALCULE        float,
    DATE_HEURE_SAISIE   datetime default sysdatetime(),
    ID_OPERATEUR_SAISIE int
        constraint P_TRANCHE_REMISE_A_UTILISATEUR_ID_UTILISATEUR_fk
            references dbo.A_UTILISATEUR,
    ACTIF               bit,
    ANNULER             bit      default 0 not null
)
go

CREATE trigger [dbo].[TR_P_TRANCHE_REMISE]
    on DBO.P_TRANCHE_REMISE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_TRANCHE_REMISE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_TRANCHE_REMISE on dbo.P_TRANCHE_REMISE
go

create table dbo.P_TYPE_TRANSPORT
(
    ID_TYPE_TRANSPORT         int identity
        constraint PK_P_TYPE_TRANSPORT
            primary key,
    TYPE_TRANSPORT            varchar(50),
    ID_TYPE_TRANSPORT_EXTERNE int
)
go

create table dbo.P_TYPE_VEHICULE
(
    ID_TYPE_VEHICULE           int identity
        constraint PK_P_TYPE_VEHICULE
            primary key,
    TYPE_VEHICULE              varchar(128),
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_TYPE_VEHICULE_EXTERNE   int,
    HAVE_MISSION               bit,
    IS_SEMI                    bit
)
go

CREATE trigger [dbo].[TR_P_TYPE_VEHICULE]
    on DBO.P_TYPE_VEHICULE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_TYPE_VEHICULE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_TYPE_VEHICULE on dbo.P_TYPE_VEHICULE
go

create table dbo.P_TYPE_ZONE
(
    ID_TYPE_ZONE int identity
        constraint PK_P_TYPE_ZONE
            primary key,
    TYPE_ZONE    varchar(80) not null,
    ABRV         varchar(56)
)
go

create table dbo.P_UNITE
(
    ID_UNITE                   int identity
        constraint PK_P_UNITE
            primary key,
    REF_UNITE                  varchar(50)
        constraint UNIQUE_REF_UNITE
            unique,
    UNITE                      varchar(50),
    ID_ARTICLE                 int
        constraint FK_P_UNITE_P_ARTICLE
            references dbo.P_ARTICLE,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    DECIMALPRECISION           int,
    IS_COMMERCIAL              bit,
    PRIX                       float
)
go

create table dbo.DELETE_ST_DT_INVENTAIRE
(
    CLE_ARTICLE        int                                           not null
        constraint FK_ST_DT_INVENTAIRE_P_ARTICLE
            references dbo.P_ARTICLE,
    NUM_LOT            varchar(50)
        constraint DF_ST_DT_INVENTAIRE_NUM_LOT default ''            not null,
    CLE_AX_ARTICLE     varchar(50),
    DATE_SAISIE        datetime
        constraint DF_ST_DT_INVENTAIRE_DATE_SAISIE default getdate() not null,
    ID_OP_SAISIE       int                                           not null
        constraint FK_ST_DT_INVENTAIRE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    QUANTITE           float
        constraint DF_ST_DT_INVENTAIRE_QUANTITE default 0            not null,
    ID_UNITE_INV       int                                           not null
        constraint FK_ST_DT_INVENTAIRE_P_UNITE
            references dbo.P_UNITE,
    QTE_COEFFICIENT    float
        constraint DF_ST_DT_INVENTAIRE_QTE_COEFFICIENT default 0     not null,
    QUANTITE_THEORIQUE float
        constraint DF_ST_DT_INVENTAIRE_QUANTITE_THEORIQUE default 0,
    ID_UNITE_STOCK     int                                           not null
        constraint FK_ST_DT_INVENTAIRE_P_UNITE1
            references dbo.P_UNITE,
    ID_INVENTAIRE      int                                           not null
        constraint FK_ST_DT_INVENTAIRE_ST_INVENTAIRE
            references dbo.DELETE_ST_INVENTAIRE,
    ACTIF              bit
        constraint DF_ST_DT_INVENTAIRE_ACTIF default 1,
    ID_DT_INVENTAIRE   int identity
        constraint PK_ST_DT_INVENTAIRE
            primary key,
    DLC                date
        constraint DF__ST_DT_INVEN__DLC__7EC36589 default '19000101',
    ID_EMPLACEMENT     int
        constraint FK_ST_DT_INVENTAIRE_P_EMPLACEMENT
            references dbo.P_EMPLACEMENT,
    NUM_SERIE          varchar(56)
        constraint DF__ST_DT_INV__NUM_S__7FB789C2 default ''
)
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.P_ARTICLE.ID_ARTICLE', 'SCHEMA', 'dbo', 'TABLE',
     'DELETE_ST_DT_INVENTAIRE', 'COLUMN', 'CLE_ARTICLE'
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.P_ARTICLE.CLE_AX', 'SCHEMA', 'dbo', 'TABLE',
     'DELETE_ST_DT_INVENTAIRE', 'COLUMN', 'CLE_AX_ARTICLE'
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.A_UTILISATEUR.ID_UTILISATEUR', 'SCHEMA', 'dbo', 'TABLE',
     'DELETE_ST_DT_INVENTAIRE', 'COLUMN', 'ID_OP_SAISIE'
go

create table dbo.DELETE_ST_DT_INVENTAIRE_THEORIQUE
(
    ID_ARTICLE             int
        constraint FK_ST_DT_INVENTAIRE_THEORIQUE_P_ARTICLE
            references dbo.P_ARTICLE,
    ID_UNITE_STOCK         int
        constraint FK_ST_DT_INVENTAIRE_THEORIQUE_P_UNITE
            references dbo.P_UNITE,
    QTE_THEORIQUE          float
        constraint DF_ST_DT_INVENTAIRE_THEORIQUE_QTE_THEORIQUE default 0,
    DATETIME               datetime
        constraint DF_ST_DT_INVENTAIRE_THEORIQUE_DATETIME default getdate(),
    ID_INVENTAIRE          int
        constraint FK_ST_DT_INVENTAIRE_THEORIQUE_ST_INVENTAIRE
            references dbo.DELETE_ST_INVENTAIRE,
    NUM_LOT                varchar(max)
        constraint DF_ST_DT_INVENTAIRE_THEORIQUE_NUM_LOT default '',
    ID_DET_INV_THEORIQUE   int identity
        constraint PK_ST_DT_INVENTAIRE_THEORIQUE
            primary key,
    DATE_SAISIE            datetime,
    DLC                    date        default '19000101',
    ID_EMPLACEMENT         int,
    ID_OP_PMU              int
        constraint FK_OP_PMU
            references dbo.A_UTILISATEUR,
    ID_UNITE_COMPTAGE      int
        constraint FK_ID_UNITE_COMPTAGE
            references dbo.P_UNITE,
    NUM_SERIE              varchar(56) default '' not null,
    PMU                    float       default 0,
    PMU_UPDATE             float       default 0,
    QTE_THEORIQUE_COMPTAGE float       default 0
)
go

create table dbo.DELETE_ST_ECART_INVENTAIRE
(
    CLE_AX               varchar(56),
    ID_ARTICLE           int
        constraint FK__ST_ECART___ID_AR__4FD36C76
            references dbo.P_ARTICLE,
    LIBELLE              varchar(128),
    NUM_LOT              varchar(128),
    ID_EMPLACEMENT       int
        references dbo.P_EMPLACEMENT,
    ID_ENTREPOT          int
        references dbo.P_ENTREPOT,
    DLC                  date,
    NUM_SERIE            varchar(128),
    ID_UNITE_STOCK       int
        references dbo.P_UNITE,
    QTE_COMPTER          float,
    QTE_THEORIQUE        float,
    QTE_ECART            float,
    ID_DET_INV_THEORIQUE int
        references dbo.DELETE_ST_DT_INVENTAIRE_THEORIQUE,
    NBR_DT               int,
    ID_INVENTAIRE        int
        references dbo.DELETE_ST_INVENTAIRE,
    PMP_ENTREPOT         float,
    PMP_GLOBALE          float,
    PRIX_DERNIER_ACHAT   float,
    PRIX_VENTE           float,
    COUT_INVENTAIRE      float
)
go

create index [NonClusteredIndex-20220625-141642]
    on dbo.DELETE_ST_ECART_INVENTAIRE (QTE_ECART) include (CLE_AX, ID_ARTICLE, LIBELLE, NUM_LOT, ID_EMPLACEMENT,
                                                           ID_ENTREPOT, DLC, NUM_SERIE, ID_UNITE_STOCK, QTE_COMPTER,
                                                           QTE_THEORIQUE, ID_DET_INV_THEORIQUE, NBR_DT, ID_INVENTAIRE)
go

alter table dbo.P_ARTICLE
    add constraint FK_P_ARTICLE_P_UNITE
        foreign key (UNITE_VENTE) references dbo.P_UNITE
go

alter table dbo.P_ARTICLE
    add constraint FK_P_ARTICLE_P_UNITE1
        foreign key (UNITE_STOCK) references dbo.P_UNITE
go

create table dbo.P_CONVERSION_UNITE
(
    ID_UNITE_FROM              int
        constraint FK_P_CONVERSION_UNITE_P_UNITE
            references dbo.P_UNITE,
    ID_UNITE_TO                int
        constraint FK_P_CONVERSION_UNITE_P_UNITE1
            references dbo.P_UNITE,
    QTE                        float,
    ID_CONVERSION              int identity
        constraint PK_P_CONVERSION_UNITE
            primary key,
    ID_ARTICLE                 int
        constraint FK_P_CONVERSION_UNITE_P_ARTICLE
            references dbo.P_ARTICLE,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    CLE_AX                     varchar(24)
)
go

CREATE trigger [dbo].[TR_P_CONVERSION_UNITE]
    on DBO.P_CONVERSION_UNITE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_CONVERSION_UNITE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_CONVERSION_UNITE on dbo.P_CONVERSION_UNITE
go

create table dbo.P_PRIX
(
    ID_ARTICLE                 int
        constraint FK_P_PRIX_P_ARTICLE
            references dbo.P_ARTICLE,
    PRIX                       float,
    UNITE                      int
        constraint FK_P_PRIX_P_UNITE
            references dbo.P_UNITE,
    ID_PRIX                    int identity
        constraint PK_T_PRIX
            primary key,
    CLE_AX_ARTICLE             varchar(20),
    DATE_DEBUT                 date,
    ID_GROUPE_PRIX             int
        constraint FK_P_PRIX_P_GROUPE_PRIX
            references dbo.P_GROUPE_PRIX,
    DATE_FIN                   date,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    PRICECURRENCYCODE          varchar(50),
    SALESPRICEQUANTITY         float,
    FROMQUANTITY               float,
    TOQUANTITY                 float,
    AXRECID                    bigint,
    ID_ENTREPOT                int,
    ID_SITE                    int
)
go

CREATE trigger [dbo].[TR_P_PRIX]
    on DBO.P_PRIX
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_PRIX'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_PRIX on dbo.P_PRIX
go

create table dbo.P_RANG_ARTICLE
(
    ID_ARTICLE           int
        constraint FK_P_RANG_ARTICLE_P_ARTICLE
            references dbo.P_ARTICLE,
    ID_RANGE             int identity
        constraint PK_P_RANG_ARTICLE
            primary key,
    ID_SITE              int
        constraint FK_P_RANG_ARTICLE_P_SITE
            references dbo.P_SITE,
    RANG                 int,
    ID_UNITE_COMMANDE    int
        constraint FK_P_RANG_ARTICLE_P_UNITE
            references dbo.P_UNITE,
    ID_UNITE_REPARTITION int
        constraint FK_P_RANG_ARTICLE_P_UNITE1
            references dbo.P_UNITE,
    DATE_HEURE_SAISIE    datetime default getdate(),
    ID_OPERATEUR_SAISIE  int
)
go

CREATE trigger [dbo].[TR_P_UNITE]
    on DBO.P_UNITE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_UNITE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_UNITE on dbo.P_UNITE
go

create table dbo.P_UNITE_EMBALAGE_AGENCE
(
    ID_ARTICLE                 int
        constraint FK_P_UNITE_EMBALAGE_AGENCE_P_ARTICLE
            references dbo.P_ARTICLE,
    ID_SITE                    int
        constraint FK_P_UNITE_EMBALAGE_AGENCE_P_SITE
            references dbo.P_SITE,
    ID_UNITE_EMBALAGE_AGENCE   int identity
        constraint PK_P_UNITE_EMBALAGE_AGENCE
            primary key,
    ID_UNITE_TO                int,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_UNITE_EMBALAGE_AGENCE]
    on DBO.P_UNITE_EMBALAGE_AGENCE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_UNITE_EMBALAGE_AGENCE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_UNITE_EMBALAGE_AGENCE on dbo.P_UNITE_EMBALAGE_AGENCE
go

create table dbo.P_UNITE_PRODUCTION
(
    ID_UNITE_PRODUCTION  int identity
        constraint PK_P_UNITE_PRODUCTION
            primary key,
    UNITE_PRODUCTION     varchar(50),
    ID_PRODUCTEUR        int,
    REF_UNITE_PRODUCTION varchar(50)
        constraint UNIQUE_REF
            unique,
    ACTIF                bit,
    LANGITUDE            varchar(30),
    LATITUDE             varchar(30),
    REF_EXTERN_UP        int,
    SALLE_DE_TRAITE      int
        constraint DF_P_UNITE_PRODUCTION_SALLE_DE_TRAITE default 1,
    SysStartTime         datetime2
        constraint DF_depotage_SysStart default sysutcdatetime()                                  not null,
    SysEndTime           datetime2
        constraint DF_depotage_SysEnd default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    VERTUELLE            bit
)
go

create table dbo.GC_BAC_LAIT
(
    ID_BAC                 int identity
        constraint PK_T_BAC_LAIT
            primary key nonclustered,
    ID_TYPE_BACK           int,
    BAC_LAIT               varchar(50)
        constraint UNIQUE_BAC_LAIT
            unique,
    REF_BAC_LAIT           varchar(50)
        constraint UNIQUE_REF_BAC_LAIT
            unique,
    ACTIF                  bit,
    CAP_BAC_LAIT           int,
    ID_UNITE_PRODUCTION    int
        constraint FK_GC_BAC_LAIT_P_UNITE_PRODUCTION
            references dbo.P_UNITE_PRODUCTION,
    REF_EXTERNE_BAC_A_LAIT int,
    SysStartTime           datetime2
        constraint DF_bac_lait_SysStart default sysutcdatetime()                                  not null,
    SysEndTime             datetime2
        constraint DF_bac_lait_SysEnd default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    OP_SAISIE              int
        references dbo.A_UTILISATEUR,
    DATE_HEURE_SAISIE      datetime default sysdatetime()
)
go

create table dbo.GC_PRIME_PENALITE
(
    ID_PRIME_PENALITE bigint identity
        constraint PK_GC_PRIME_PENALITE
            primary key,
    ID_UNITE_PROD     int
        constraint FK_GC_PRIME_PENALITE_P_UNITE_PRODUCTION
            references dbo.P_UNITE_PRODUCTION,
    MOYENNE_PRIME     float,
    MOYENNE_PENALITE  float,
    ID_PERIODE        bigint
)
go

create table dbo.GC_PRIME_PRIX
(
    ID_PRIX_PRIME       int identity
        constraint PK_GC_PRIME_PRIX
            primary key,
    PRIX                float,
    ID_UNITE_PRODUCTION int
        constraint FK_GC_PRIME_PRIX_P_UNITE_PRODUCTION
            references dbo.P_UNITE_PRODUCTION,
    ID_PERIODE          bigint not null
        constraint FK_GC_PRIME_PRIX_GC_PERIODE
            references dbo.GC_PERIODE,
    ID_ADHERENT         int
        constraint FK_GC_PRIME_PRIX_P_ADHERENT
            references dbo.P_ADHERENT,
    ID_PRODUCTEUR       int
        constraint FK_GC_PRIME_PRIX_P_PRODUCTEUR
            references dbo.P_PRODUCTEUR,
    QTE                 float
)
go

create table dbo.P_TOURNEE_UNITE_PRODUCTION
(
    ID_UNITE_PRODUCTION int                                                                            not null
        constraint FK_P_TOURNEE_UNITE_PRODUCTION_P_UNITE_PRODUCTION
            references dbo.P_UNITE_PRODUCTION,
    ID_TOURNEE          int                                                                            not null,
    DATE_HEURE_SAISIE   datetime
        constraint DF_P_TOURNEE_UNITE_PRODUCTION_DATE_HEURE_SAISIE default getdate(),
    ID_OP_SAISIE        int,
    SysStartTime        datetime2
        constraint DF_tournee_unite_SysStart default sysutcdatetime()                                  not null,
    SysEndTime          datetime2
        constraint DF_tournee_unite_SysEnd default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    constraint PK_P_TOURNEE_UNITE_PRODUCTION
        primary key (ID_UNITE_PRODUCTION, ID_TOURNEE)
)
go

create table dbo.P_VEHICULE_EXTERNE
(
    ID_VEHICULE  int identity
        constraint PK_P_VEHICULE_EXTERNE
            primary key,
    MATRICULE    varchar(50)
        constraint UNIQUE_MATRICULE_EXTERNALE
            unique,
    ID_OP_SAISIE int
        constraint FK_P_VEHICULE_EXTERNE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_SAISIE  datetime
        constraint DF_P_VEHICULE_EXTERNE_DATE_SAISIE default getdate()
)
go

create table dbo.P_VERGER
(
    ID_VERGER           int identity
        constraint PK_P_VERGER
            primary key,
    REF_VERGER          varchar(50) not null
        unique,
    LIBELLE             varchar(50),
    ACTIF               bit,
    ID_UNITE_PRODUCTION int,
    CODE_VERGER_EXTERNE int
)
go

create table dbo.P_ZONE
(
    ID_ZONE           int identity
        constraint PK__P_ZONE__0920FFD97A769FEF
            primary key,
    ZONE              varchar(128) not null
        constraint UNIQUE_ZONE
            unique,
    ID_SITE           int
        constraint FK__P_ZONE__ID_SITE__03BC5979
            references dbo.P_SITE
        constraint FK__P_ZONE__ID_SITE__676011ED
            references dbo.P_SITE,
    ID_SUPERVISEUR    int
        constraint FK__P_ZONE__ID_SUPER__0D45C3B3
            references dbo.A_UTILISATEUR,
    ID_TYPE_ZONE      int
        constraint FK_P_ZONE_P_TYPE_ZONE
            references dbo.P_TYPE_ZONE,
    ID_ZONE_TOURNEE   int,
    PRIX_ACHAT        float,
    REF_SIEGE         int,
    ID_OP_SAISIE      int,
    DATE_HEURE_SAISIE datetime
        constraint DF__P_ZONE__DATE_HEU__2BEB11BB default getdate()
)
go

create table dbo.P_BLOC
(
    ID_BLOC           int identity
        constraint PK__P_BLOC__7551932A48F55582
            primary key,
    BLOC              varchar(128)
        constraint UNIQUE_BLOC
            unique,
    ID_ZONE           int not null
        constraint FK__P_BLOC__ID_ZONE__0698C624
            references dbo.P_ZONE
        constraint FK__P_BLOC__ID_ZONE__6577C97B
            references dbo.P_ZONE,
    ID_ZONE_TOURNEE   int,
    REF_SIEGE         int,
    DATE_HEURE_SAISIE datetime
        constraint DF__P_BLOC__DATE_HEU__281A80D7 default getdate(),
    ID_OP_SAISIE      int
)
go

create table dbo.P_SECTEUR
(
    ID_SECTEUR                 int identity
        constraint PK_T_SECTEUR
            primary key,
    SECTEUR                    varchar(56)
        constraint UNIQUE_SECTEUR
            unique,
    CODE_SECTEUR               bigint,
    ID_SITE                    int
        constraint FK_P_SECTEUR_P_SITE
            references dbo.P_SITE,
    ID_TYPE_SECTEUR            int
        constraint FK_P_SECTEUR_P_SECTEUR_TYPE
            references dbo.P_SECTEUR_TYPE,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_BLOC                    int
        constraint FK__P_SECTEUR__ID_BL__0E39E7EC
            references dbo.P_BLOC
        constraint FK__P_SECTEUR__ID_BL__666BEDB4
            references dbo.P_BLOC,
    ID_TOURNEE_EXTERNE         int,
    REF_SIEGE                  int,
    DATE_HEURE_SAISIE          datetime default getdate(),
    ID_OP_SAISIE               int
)
go

create table dbo.P_BUDJET_PREVISION_OBJECTIF
(
    ID_SECTEUR                 int
        constraint FK_P_OBJECTIF_P_SECTEUR
            references dbo.P_SECTEUR,
    ID_SITE                    int
        constraint FK_P_OBJECTIF_P_SITE
            references dbo.P_SITE,
    DATE_HEURS_SAISIE          datetime,
    ID_OPERATEUR_SAISIE        int
        constraint FK_P_BUDJET_PREVISION_OBJECTIF_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    LIBELLE                    varchar(128),
    ID_OBJECTIF                int identity
        constraint PK_P_OBJECTIF
            primary key,
    ID_TYPE_OBJECTIF           int
        constraint FK_P_OBJECTIF_P_TYPE_OBJECTIF
            references dbo.P_BUDJET_PREVISION_OBJECTIF_TYPE,
    DATE_DEBUT                 date,
    DATE_FIN                   date,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_BUDJET_PREVISION_OBJECTIF]
    on DBO.P_BUDJET_PREVISION_OBJECTIF
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_BUDJET_PREVISION_OBJECTIF'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_BUDJET_PREVISION_OBJECTIF on dbo.P_BUDJET_PREVISION_OBJECTIF
go

create table dbo.P_BUDJET_PREVISION__OBJECTIF_DT
(
    ID_ARTICLE                 int,
    QTE                        float,
    ID_OBJECTIF                int
        constraint FK_P_OBJECTIF_DT_P_OBJECTIF
            references dbo.P_BUDJET_PREVISION_OBJECTIF,
    ID_DT_OBJECTIF             int identity
        constraint PK_P_OBJECTIF_DT
            primary key,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_BUDJET_PREVISION__OBJECTIF_DT]
    on DBO.P_BUDJET_PREVISION__OBJECTIF_DT
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_BUDJET_PREVISION__OBJECTIF_DT'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_BUDJET_PREVISION__OBJECTIF_DT on dbo.P_BUDJET_PREVISION__OBJECTIF_DT
go

CREATE trigger [dbo].[TR_P_SECTEUR]
    on dbo.P_SECTEUR
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_SECTEUR'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_SECTEUR on dbo.P_SECTEUR
go

create table dbo.P_SECTEUR_GAMME
(
    ID_SECT_GAMME     int identity,
    ID_SECTEUR        int not null
        constraint FK_P_SECTEUR_GAMME_P_SECTEUR
            references dbo.P_SECTEUR,
    ID_GAMME          int not null
        constraint FK_P_SECTEUR_GAMME_P_GAMME
            references dbo.P_GAMME,
    ID_OP_SAISIE      int,
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    constraint P_SECTEUR_GAMME_pk
        primary key nonclustered (ID_SECTEUR, ID_GAMME)
)
go

create table dbo.P_SOUS_SECTEUR
(
    ID_SOUS_SECTEUR            int identity
        constraint PK_T_SOUS_SECTEUR
            primary key,
    ID_SECTEUR                 int
        constraint FK_P_SOUS_SECTEUR_P_SECTEUR
            references dbo.P_SECTEUR,
    SOUS_SECTEUR               varchar(56),
    CODE_SOUS_SECTEUR          bigint,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    REF_SIEGE                  int,
    DATE_HEURE_SAISIE          datetime default getdate(),
    ID_OP_SAISIE               int
)
go

create table dbo.P_CLIENT
(
    ID_CLIENT              int identity
        constraint PK_T_CLIENT
            primary key,
    ID_SITE                varchar(25),
    ID_SOUS_SECTEUR        int
        constraint FK_P_CLIENT_P_SOUS_SECTEUR
            references dbo.P_SOUS_SECTEUR,
    NOM_CLIENT             varchar(255),
    ACTIF                  bit
        constraint DF_P_CLIENT_ACTIF default 1,
    LONGITUDE              varchar(20),
    LATITUDE               varchar(20),
    ADRESSE                varchar(255),
    NUM_TEL                varchar(255),
    CIN                    varchar(20),
    BLOCKER                bit,
    REF_CLIENT             varchar(50),
    REF_COMPTE_FACTURATION varchar(50),
    PATENTE                varchar(50),
    ID_REMISE              int
        constraint FK_P_CLIENT_P_REMISE_FIN_MOIS
            references dbo.P_REMISE_FIN_MOIS,
    DATETIME_OP            datetime,
    REF_SIEGE              varchar(50),
    CUSTGROUP              varchar(50),
    ID_GROUP_PRIX          int
        constraint FK_P_CLIENT_P_GROUPE_PRIX
            references dbo.P_GROUPE_PRIX,
    ACTIVITE               varchar(50),
    AGENCE                 varchar(50),
    BU                     varchar(50),
    CANAL                  varchar(50),
    G_ARTICLE              varchar(50),
    INTERCOS               varchar(50),
    PROJET                 varchar(50),
    SITE                   varchar(50),
    AUT_CHEQUE             bit,
    ID_OP_SAISIE           int,
    DATE_HEURE_SAISIE      datetime default getdate()
)
go

create table dbo.P_CIBLE_PROMOTION
(
    ID_PROMOTION               int not null
        constraint FK_P_CIBLE_PROMOTION_P_PROMOTIONS
            references dbo.P_PROMOTIONS,
    ID_SITE                    varchar(25),
    ID_SECTEUR                 int
        constraint FK_P_CIBLE_PROMOTION_P_SECTEUR
            references dbo.P_SECTEUR,
    ID_SOUS_SECTEUR            int
        constraint FK_P_CIBLE_PROMOTION_P_SOUS_SECTEUR
            references dbo.P_SOUS_SECTEUR,
    ID_CLIENT                  int not null
        constraint FK_P_CIBLE_PROMOTION_P_CLIENT
            references dbo.P_CLIENT,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    DATE_HEURE_SAISIE          datetime default getdate(),
    ID_OP_SAISIE               int,
    constraint PK_P_CIBLE_PROMOTION
        primary key (ID_PROMOTION, ID_CLIENT)
)
go

CREATE trigger [dbo].[TR_P_CIBLE_PROMOTION]
    on dbo.P_CIBLE_PROMOTION
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_CIBLE_PROMOTION'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_CIBLE_PROMOTION on dbo.P_CIBLE_PROMOTION
go

create index INDEXIDSOUSSECTEUR
    on dbo.P_CLIENT (ID_SOUS_SECTEUR) include (ID_CLIENT)
go

CREATE trigger [dbo].[TR_P_CLIENT]
    on dbo.P_CLIENT
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_CLIENT'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_CLIENT on dbo.P_CLIENT
go

create table dbo.P_MONTANT_REMISE
(
    ID_MONTANT_REMISE          int identity
        constraint PK_P_MONTANT_REMISE
            primary key,
    MONTANT_REMISE             float,
    CHIFFRE_AFFAIRE            float,
    ID_REMISE_CALCULE          int
        constraint FK_P_MONTANT_REMISE_P_REMISE_CALCULE1
            references dbo.P_REMISE_CALCULE,
    ID_CLIENT                  int
        constraint FK_P_MONTANT_REMISE_P_REMISE_CALCULE
            references dbo.P_CLIENT,
    MONTANT_RESTANT            float,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_MONTANT_REMISE]
    on DBO.P_MONTANT_REMISE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_MONTANT_REMISE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_MONTANT_REMISE on dbo.P_MONTANT_REMISE
go

CREATE trigger [dbo].[TR_P_SOUS_SECTEUR]
    on dbo.P_SOUS_SECTEUR
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_SOUS_SECTEUR'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_SOUS_SECTEUR on dbo.P_SOUS_SECTEUR
go

create table dbo.P_TOURNEE
(
    ID_TOURNEE                 int identity
        constraint PK_T_TOURNEE
            primary key,
    TOURNEE                    varchar(50),
    ID_SECTEUR                 int
        constraint FK_P_TOURNEE_P_SECTEUR
            references dbo.P_SECTEUR,
    CODE_TOURNEE               int,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_TOURNEE_EXTERNE         int,
    REF_SIEGE                  int,
    SysStartTime               datetime2
        constraint DF_tournee_SysStart default sysutcdatetime()                                  not null,
    SysEndTime                 datetime2
        constraint DF_tournee_SysEnd default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    ACTIF                      bit,
    DISTANCE                   float,
    DATE_HEURE_SAISIE          datetime default getdate()
)
go

create table dbo.GD_STATION_TOURNEE
(
    ID_STATION        int not null
        references dbo.GD_STATION_DEPOTAGE,
    ID_TOURNEE        int not null
        references dbo.P_TOURNEE,
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    OP_SAISIE         int
        references dbo.A_UTILISATEUR,
    primary key (ID_STATION, ID_TOURNEE)
)
go

create table dbo.P_REMISE_FACTURE_CLIENT
(
    DATE_DEBUT_AFFECTATION     datetime,
    DATE_FIN_AFFECTATION       datetime,
    ID_SECTEUR                 int
        constraint FK_P_REMISE_FACTURE_CLIENT_P_SECTEUR
            references dbo.P_SECTEUR,
    ID_SITE                    int
        constraint FK_P_REMISE_FACTURE_CLIENT_P_SITE
            references dbo.P_SITE,
    ID_TOURNEE                 int
        constraint FK_P_REMISE_FACTURE_CLIENT_P_TOURNEE
            references dbo.P_TOURNEE,
    ID_SOUS_SECTEUR            int
        constraint FK_P_REMISE_FACTURE_CLIENT_P_SOUS_SECTEUR
            references dbo.P_SOUS_SECTEUR,
    ID_OP_DEBUT_AFFECTATION    int
        constraint FK_P_REMISE_FACTURE_CLIENT_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_OP_FIN_AFFECTATION      int
        constraint FK_P_REMISE_FACTURE_CLIENT_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    ID_REMISE_FACTURE          int not null
        constraint FK_P_REMISE_FACTURE_CLIENT_P_REMISE_FACTURE
            references dbo.P_REMISE_FACTURE,
    ID_CLIENT                  int not null
        constraint FK_P_REMISE_FACTURE_CLIENT_P_CLIENT
            references dbo.P_CLIENT,
    ID_FACTURE_REMISE_CLIENT   int identity
        constraint PK_P_REMISE_FACTURE_CLIENT_1
            primary key,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime
)
go

CREATE trigger [dbo].[TR_P_TOURNEE]
    on dbo.P_TOURNEE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_TOURNEE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_TOURNEE on dbo.P_TOURNEE
go

create table dbo.P_TOURNEE_CLIENT
(
    ID_TOURNEE                 int
        constraint FK_T_TOURNEE_CLIENT_P_TOURNEE
            references dbo.P_TOURNEE,
    ID_CLIENT                  int
        constraint FK_T_TOURNEE_CLIENT_P_CLIENT
            references dbo.P_CLIENT,
    ID_TOURNEE_CLIENT          int identity
        constraint PK_T_TOURNEE_CLIENT
            primary key,
    CLASSEMENT                 int,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_OP_SAISIE               int,
    DATE_HEURE_SAISIE          datetime default getdate()
)
go

CREATE trigger [dbo].[TR_P_TOURNEE_CLIENT]
    on DBO.P_TOURNEE_CLIENT
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_TOURNEE_CLIENT'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_TOURNEE_CLIENT on dbo.P_TOURNEE_CLIENT
go

create table dbo.P_TOURNEE_SITE
(
    ID_TOURNEE int not null
        constraint FK_P_TOURNEE_SITE_P_TOURNEE
            references dbo.P_TOURNEE,
    ID_SITE    int not null
        constraint FK_P_TOURNEE_SITE_P_SITE
            references dbo.P_SITE,
    DEPART     bit not null,
    constraint PK_P_TOURNEE_SITE
        primary key (ID_TOURNEE, ID_SITE, DEPART)
)
go

create table dbo.ST_AFFECTATION_ARTICLE_MACHINE
(
    ID_ARTICLE int not null
        constraint FK_ST_AFFECTATION_ARTICLE_MACHINE_P_ARTICLE
            references dbo.P_ARTICLE,
    ID_MACHINE int not null
        constraint FK_ST_AFFECTATION_ARTICLE_MACHINE_P_MACHINE
            references dbo.P_MACHINE,
    constraint PK_ST_AFFECTATION_ARTICLE_MACHINE
        primary key (ID_ARTICLE, ID_MACHINE)
)
go

create table dbo.ST_AJUSTEMENT_PROD_CONS
(
    ID_ARTICLE                  int                                       not null,
    ID_OPERATION                int identity
        constraint PK_ST_AJUSTEMENT_PROD_CONS
            primary key,
    ID_UNITE_AJUST              int                                       not null,
    QTE                         float                                     not null,
    COEFICIENT                  float                                     not null,
    ID_UNITE_STOCK              int                                       not null,
    ID_ENTREPOT                 int                                       not null,
    ID_MAGASINIER               int                                       not null,
    DATE_OPERATION              datetime
        constraint DF_ST_AJUSTEMENT_PROD_DATE_OPERATION default getdate() not null,
    VALEUR_UNIT_STCK            float                                     not null,
    NUM_LOT                     varchar(128),
    ID_TYPE_AJUSTEMENT          int                                       not null,
    ID_NATURE_AJUSTEMENT        int                                       not null,
    ACTIF                       bit
        constraint DF_ST_AJUSTEMENT_PROD_CONS_ACTIF default 1,
    SYNCHRO_TO_BD_INTERMIDIAIRE bit
        constraint DF_ST_AJUSTEMENT_PROD_CONS_SYNCHRO_TO_BD_INTERMIDIAIRE default 0,
    ID_AJUSTEMENT_ORIGINALE     int
        constraint FK_ST_AJUSTEMENT_PROD_CONS_ST_AJUSTEMENT_PROD_CONS1
            references dbo.ST_AJUSTEMENT_PROD_CONS,
    CONFIGID                    varchar(50),
    COLORID                     varchar(50),
    VERSION                     varchar(50),
    SIZEID                      varchar(50),
    STYLEID                     varchar(50),
    ID_DEMANDEUR                int
        constraint FK_ST_AJUSTEMENT_PROD_CONS_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    COMMENT                     varchar(128),
    ID_ENTREPOT_ANALYTIQUE      int
)
go

CREATE TRIGGER [dbo].[AJUSTEMENT_STOCK_CONSUM_PROD]
    ON [dbo].[ST_AJUSTEMENT_PROD_CONS]
    AFTER INSERT, UPDATE, DELETE
    AS
BEGIN

    DECLARE @COUNTI INT, @COUNTD INT, @ACTIFD BIT, @ACTIFI BIT;
    DECLARE @VAL_PMP FLOAT;

    DECLARE @ID VARCHAR(20), @CLE_AX VARCHAR(20), @LIBELLE VARCHAR(20), @ID_ENTREPOT INT, @REF_UNITE VARCHAR(20), @NUM_LOT VARCHAR(20),
        @QTE FLOAT, @VALEUR_UNITE_STCK FLOAT, @REF_SITE VARCHAR(20), @BU VARCHAR(20), @REF_ENTREPOT VARCHAR(20), @EMPLACEMENT VARCHAR(20);

    SELECT @COUNTI = COUNT(*)
    FROM inserted;
    SELECT @COUNTD = COUNT(*)
    FROM deleted;

    BEGIN TRY

        IF (@COUNTI > 1 OR @COUNTD > 1)
            BEGIN
                RAISERROR ('Impossible de gerer les données en masse', 16, 1 );
            END
        IF (@COUNTD = 1 AND @COUNTI = 0)
            BEGIN
                RAISERROR ('Impossible de supprimer une ligne d''ajustement, Merci de l''ajustée via une ligne de production ou de consommation selon votre situation ', 16, 1 );
            END
        IF (@COUNTD = 1 AND @COUNTI = 1)
            BEGIN
                IF (
                       SELECT COUNT(*)
                       FROM INSERTED I
                                INNER JOIN DELETED D ON I.ID_OPERATION = D.ID_OPERATION
                       WHERE I.ID_ARTICLE != D.ID_ARTICLE
                          OR I.ID_UNITE_AJUST != D.ID_UNITE_AJUST
                          OR I.QTE != D.QTE
                          OR I.COEFICIENT != D.COEFICIENT
                          OR I.ID_UNITE_STOCK != D.ID_UNITE_STOCK
                          OR I.ID_ENTREPOT != D.ID_ENTREPOT
                          OR I.ID_MAGASINIER != D.ID_MAGASINIER
                          OR I.DATE_OPERATION != D.DATE_OPERATION
                          OR I.VALEUR_UNIT_STCK != D.VALEUR_UNIT_STCK
                          OR I.NUM_LOT != D.NUM_LOT
                          OR I.ID_TYPE_AJUSTEMENT != D.ID_TYPE_AJUSTEMENT
                          OR I.ID_NATURE_AJUSTEMENT != D.ID_NATURE_AJUSTEMENT
                          OR I.CONFIGID != D.CONFIGID
                          OR I.COLORID != D.COLORID
                          OR I.VERSION != D.VERSION
                          OR I.SIZEID != D.SIZEID
                          OR I.STYLEID != D.STYLEID
                   ) = 1
                    BEGIN
                        RAISERROR ('Impossible de modifier les informations d''une ligne d''ajustement, Merci de l''ajustée via une ligne de production ou de consommation selon votre situation ', 16, 1 );
                    END
            END
        IF (@COUNTD = 0 AND @COUNTI = 1)
            BEGIN
                --- ----------- ------------------ --------------------- > CARBURANT
                IF (SELECT ID_NATURE_AJUSTEMENT FROM INSERTED) = 1
                    BEGIN
                        IF (SELECT ID_TYPE_AJUSTEMENT FROM INSERTED) = 1
                            BEGIN
                                --- CONSOMMATION
                                INSERT INTO [10.7.5.25].AXINTERFACEDB.DBO.T_CONSUM_PROD3(JOURNAL, ARTICLE, SITE,
                                                                                         ENTREPOT, EMPLACEMENT, LOT,
                                                                                         CONFIGURATION, COULEUR, TAILLE,
                                                                                         STYLE, VERSION, QUANTITE, PRIX,
                                                                                         AMOUNT, ACTIVITE, AGENCE, BU,
                                                                                         CANAL, G_ARTICLE,
                                                                                         INTERCOS, PROJET, DATE,
                                                                                         SITE_STOCK, STOCK_MODE,
                                                                                         EXTERNALREF, UNIT_PRICE)
                                SELECT 'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.ITEMID,
                                       ISNULL(PE.SITE, ''),
                                       REF_ENTREPOT,
                                       'VEND_01',
                                       ISNULL(NUM_LOT, ''),
                                       ISNULL(PA.CONFIG, ''),
                                       ISNULL(PA.COLOR, ''),
                                       ISNULL(PA.SIZE, ''),
                                       ISNULL(PA.STYLE, ''),
                                       ISNULL(PA.VERSION, ''),
                                       -1 * QTE,
                                       0,
                                       0 * -1 * QTE,
                                       ISNULL(PE.ACTIVITE, ''),
                                       ISNULL(PE.AGENCE, ''),
                                       CASE WHEN I.ID_NATURE_AJUSTEMENT = 1 THEN 'DLOG' ELSE ISNULL(PE.BU, '') END,
                                       '9999',
                                       ISNULL(PA.G_ARTICLE_ART, ''),
                                       '9999',
                                       '9999',
                                       CAST(DATE_OPERATION AS DATE),
                                       PS.REF_SITE,
                                       'STD',
                                       'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.UNITEPRIXSTOCK
                                FROM INSERTED I
                                         INNER JOIN P_ARTICLE PA ON I.ID_ARTICLE = PA.ID_ARTICLE
                                         INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = I.ID_ENTREPOT
                                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                            END
                        IF (SELECT ID_TYPE_AJUSTEMENT FROM INSERTED) = 2
                            BEGIN
                                --- PRODUCTION
                                SET @VAL_PMP = 0;
                                SELECT @VAL_PMP = PMP
                                FROM [10.7.5.25].AXINTERFACEDB.DBO.VREC_AXSYNCHRO_STOCK STOCK
                                     --INNER JOIN INSERTED I ON I.ID_ARTICLE = STOCK.ID_ARTICLE
                                     --INNER JOIN P_ENTREPOT PENT ON PENT.ID_ENTREPOT = I.ID_ENTREPOT
                                WHERE STOCK.ID_ARTICLE = (SELECT TOP 1 I.ID_ARTICLE FROM INSERTED I)
                                  AND STOCK.INVENTbATCHID =
                                      (SELECT TOP 1 I.NUM_LOT FROM INSERTED I) COLLATE French_CI_AS
                                  AND STOCK.ID_ENTREPOT = (SELECT TOP 1 I.ID_ENTREPOT FROM INSERTED I)


                                INSERT INTO [10.7.5.25].AXINTERFACEDB.DBO.T_CONSUM_PROD3(JOURNAL, ARTICLE, SITE,
                                                                                         ENTREPOT, EMPLACEMENT, LOT,
                                                                                         CONFIGURATION, COULEUR, TAILLE,
                                                                                         STYLE, VERSION, QUANTITE, PRIX,
                                                                                         AMOUNT, ACTIVITE, AGENCE, BU,
                                                                                         CANAL, G_ARTICLE,
                                                                                         INTERCOS, PROJET, DATE,
                                                                                         SITE_STOCK, STOCK_MODE,
                                                                                         EXTERNALREF, UNIT_PRICE)
                                SELECT 'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.ITEMID,
                                       ISNULL(PE.SITE, ''),
                                       REF_ENTREPOT,
                                       'VEND_01',
                                       ISNULL(NUM_LOT, ''),
                                       ISNULL(PA.CONFIG, ''),
                                       ISNULL(PA.COLOR, ''),
                                       ISNULL(PA.SIZE, ''),
                                       ISNULL(PA.STYLE, ''),
                                       ISNULL(PA.VERSION, ''),
                                       QTE,
                                       @VAL_PMP,
                                       @VAL_PMP * CAST(QTE AS FLOAT),
                                       ISNULL(PE.ACTIVITE, ''),
                                       ISNULL(PE.AGENCE, ''),
                                       CASE WHEN I.ID_NATURE_AJUSTEMENT = 1 THEN 'DLOG' ELSE ISNULL(PE.BU, '') END,
                                       '9999',
                                       ISNULL(PA.G_ARTICLE_ART, ''),
                                       '9999',
                                       '9999',
                                       CAST(DATE_OPERATION AS DATE),
                                       PS.REF_SITE,
                                       'STD',
                                       'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.UNITEPRIXSTOCK
                                FROM INSERTED I
                                         INNER JOIN P_ARTICLE PA ON I.ID_ARTICLE = PA.ID_ARTICLE
                                         INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = I.ID_ENTREPOT
                                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                            END
                    END

                --- ----------- ------------------ --------------------- > SORTIE DE STOCK (TRansfert !!)
                IF (SELECT ID_NATURE_AJUSTEMENT FROM INSERTED) = 4
                    BEGIN
                        IF (SELECT ID_TYPE_AJUSTEMENT FROM INSERTED) = 1
                            BEGIN
                                --- CONSOMMATION
                                -- Valeur PMP de stock avant consommation
                                SET @VAL_PMP = 0;
                                SELECT @VAL_PMP = PMP
                                FROM [10.7.5.25].AXINTERFACEDB.DBO.VREC_AXSYNCHRO_STOCK STOCK
                                     --INNER JOIN INSERTED I ON I.ID_ARTICLE = STOCK.ID_ARTICLE
                                     --INNER JOIN P_ENTREPOT PENT ON PENT.ID_ENTREPOT = I.ID_ENTREPOT
                                WHERE STOCK.ID_ARTICLE = (SELECT TOP 1 I.ID_ARTICLE FROM INSERTED I)
                                  AND STOCK.INVENTbATCHID =
                                      (SELECT TOP 1 I.NUM_LOT FROM INSERTED I) COLLATE French_CI_AS
                                  AND STOCK.ID_ENTREPOT = (SELECT TOP 1 I.ID_ENTREPOT FROM INSERTED I)

                                --STOCK .ID_ARTICLE = I.ID_ARTICLE AND STOCK.INVENTbATCHID = I.NUM_LOT COLLATE French_CI_AS
                                --AND STOCK.INVENTLOCATIONID = PENT.REF_ENTREPOT COLLATE French_CI_AS
                                --Consommation entrepot src
                                INSERT INTO [10.7.5.25].AXINTERFACEDB.DBO.T_CONSUM_PROD2(JOURNAL, ARTICLE, SITE,
                                                                                         ENTREPOT, EMPLACEMENT, LOT,
                                                                                         CONFIGURATION, COULEUR, TAILLE,
                                                                                         STYLE, VERSION, QUANTITE, PRIX,
                                                                                         AMOUNT, ACTIVITE, AGENCE, BU,
                                                                                         CANAL, G_ARTICLE,
                                                                                         INTERCOS, PROJET, DATE,
                                                                                         SITE_STOCK, STOCK_MODE,
                                                                                         EXTERNALREF, UNIT_PRICE)
                                SELECT 'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.ITEMID,
                                       ISNULL(PE.SITE, ''),
                                       REF_ENTREPOT,
                                       'VEND_01',
                                       ISNULL(NUM_LOT, ''),
                                       ISNULL(PA.CONFIG, ''),
                                       ISNULL(PA.COLOR, ''),
                                       ISNULL(PA.SIZE, ''),
                                       ISNULL(PA.STYLE, ''),
                                       ISNULL(PA.VERSION, ''),
                                       -1 * QTE,
                                       0,
                                       0 * -1 * QTE,
                                       case WHEN PE.ACTIVITE = '' then '9999' ELSE PE.ACTIVITE end,
                                       case WHEN PE.AGENCE = '' then '9999' ELSE PE.AGENCE END,
                                       case WHEN PE.BU = '' then '9999' ELSE PE.BU END,
                                       case WHEN PE.CANAL = '' then '9999' ELSE PE.CANAL END,
                                       case WHEN PA.G_ARTICLE_ART = '' then '9999' ELSE PA.G_ARTICLE_ART END,
                                       case WHEN PE.INTERCOS = '' then '9999' ELSE PE.INTERCOS END,
                                       case WHEN PE.PROJET = '' then '9999' ELSE PE.PROJET END,
                                       FORMAT(getdate(), 'dd/MM/yyyy'),
                                       PS.REF_SITE,
                                       'STD',
                                       'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.UNITEPRIXSTOCK
                                FROM INSERTED I
                                         INNER JOIN P_ARTICLE PA ON I.ID_ARTICLE = PA.ID_ARTICLE
                                         INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = I.ID_ENTREPOT
                                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                                --Production entrepot destination
                                INSERT INTO [10.7.5.25].AXINTERFACEDB.DBO.T_CONSUM_PROD2(JOURNAL, ARTICLE, SITE,
                                                                                         ENTREPOT, EMPLACEMENT, LOT,
                                                                                         CONFIGURATION, COULEUR, TAILLE,
                                                                                         STYLE, VERSION, QUANTITE,
                                                                                         PRIX, AMOUNT, ACTIVITE, AGENCE,
                                                                                         BU, CANAL, G_ARTICLE,
                                                                                         INTERCOS, PROJET, DATE,
                                                                                         SITE_STOCK, STOCK_MODE,
                                                                                         EXTERNALREF, UNIT_PRICE)
                                SELECT 'STJ' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.ITEMID,
                                       ISNULL(PE.SITE, ''),
                                       REF_ENTREPOT,
                                       'VEND_01',
                                       ISNULL(NUM_LOT, ''),
                                       ISNULL(PA.CONFIG, ''),
                                       ISNULL(PA.COLOR, ''),
                                       ISNULL(PA.SIZE, ''),
                                       ISNULL(PA.STYLE, ''),
                                       ISNULL(PA.VERSION, ''),
                                       QTE,
                                       @VAL_PMP,
                                       @VAL_PMP * CAST(QTE AS FLOAT),
                                       case WHEN PE.ACTIVITE = '' then '9999' ELSE PE.ACTIVITE end,
                                       case WHEN PE.AGENCE = '' then '9999' ELSE PE.AGENCE END,
                                       case WHEN PE.BU = '' then '9999' ELSE PE.BU END,
                                       case WHEN PE.CANAL = '' then '9999' ELSE PE.CANAL END,
                                       case WHEN PA.G_ARTICLE_ART = '' then '9999' ELSE PA.G_ARTICLE_ART END,
                                       case WHEN PE.INTERCOS = '' then '9999' ELSE PE.INTERCOS END,
                                       case WHEN PE.PROJET = '' then '9999' ELSE PE.PROJET END,
                                       FORMAT(getdate(), 'dd/MM/yyyy'),
                                       PS.REF_SITE,
                                       'STD',
                                       'STJ' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.UNITEPRIXSTOCK
                                FROM INSERTED I
                                         INNER JOIN P_ARTICLE PA ON I.ID_ARTICLE = PA.ID_ARTICLE
                                         INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = I.ID_ENTREPOT_ANALYTIQUE
                                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                            END
                        IF (SELECT ID_TYPE_AJUSTEMENT FROM INSERTED) = 2
                            BEGIN
                                --- PRODUCTION
                                -- Valeur PMP de stock d'entrepot destination
                                SET @VAL_PMP = 0;
                                SELECT @VAL_PMP = PMP
                                FROM [10.7.5.25].AXINTERFACEDB.DBO.VREC_AXSYNCHRO_STOCK STOCK
                                     --INNER JOIN INSERTED I ON I.ID_ARTICLE = STOCK.ID_ARTICLE
                                     --INNER JOIN P_ENTREPOT PENT ON PENT.ID_ENTREPOT = I.ID_ENTREPOT
                                WHERE STOCK.ID_ARTICLE = (SELECT TOP 1 I.ID_ARTICLE FROM INSERTED I)
                                  AND STOCK.INVENTbATCHID =
                                      (SELECT TOP 1 I.NUM_LOT FROM INSERTED I) COLLATE French_CI_AS
                                  AND STOCK.ID_ENTREPOT = (SELECT TOP 1 I.ID_ENTREPOT FROM INSERTED I)

                                --STOCK .ID_ARTICLE = I.ID_ARTICLE AND STOCK.INVENTbATCHID = I.NUM_LOT COLLATE French_CI_AS
                                --AND STOCK.INVENTLOCATIONID = PENT.REF_ENTREPOT COLLATE French_CI_AS
                                -- production entrepot src
                                INSERT INTO [10.7.5.25].AXINTERFACEDB.DBO.T_CONSUM_PROD2(JOURNAL, ARTICLE, SITE,
                                                                                         ENTREPOT, EMPLACEMENT, LOT,
                                                                                         CONFIGURATION, COULEUR, TAILLE,
                                                                                         STYLE, VERSION, QUANTITE,
                                                                                         PRIX, AMOUNT, ACTIVITE, AGENCE,
                                                                                         BU, CANAL, G_ARTICLE,
                                                                                         INTERCOS, PROJET, DATE,
                                                                                         SITE_STOCK, STOCK_MODE,
                                                                                         EXTERNALREF, UNIT_PRICE)
                                SELECT 'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.ITEMID,
                                       ISNULL(PE.SITE, ''),
                                       REF_ENTREPOT,
                                       'VEND_01',
                                       ISNULL(NUM_LOT, ''),
                                       ISNULL(PA.CONFIG, ''),
                                       ISNULL(PA.COLOR, ''),
                                       ISNULL(PA.SIZE, ''),
                                       ISNULL(PA.STYLE, ''),
                                       ISNULL(PA.VERSION, ''),
                                       QTE,
                                       @VAL_PMP,
                                       @VAL_PMP * CAST(QTE AS FLOAT),
                                       case WHEN PE.ACTIVITE = '' then '9999' ELSE PE.ACTIVITE end,
                                       case WHEN PE.AGENCE = '' then '9999' ELSE PE.AGENCE END,
                                       case WHEN PE.BU = '' then '9999' ELSE PE.BU END,
                                       case WHEN PE.CANAL = '' then '9999' ELSE PE.CANAL END,
                                       case WHEN PA.G_ARTICLE_ART = '' then '9999' ELSE PA.G_ARTICLE_ART END,
                                       case WHEN PE.INTERCOS = '' then '9999' ELSE PE.INTERCOS END,
                                       case WHEN PE.PROJET = '' then '9999' ELSE PE.PROJET END,
                                       FORMAT(getdate(), 'dd/MM/yyyy'),
                                       PS.REF_SITE,
                                       'STD',
                                       'ST' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.UNITEPRIXSTOCK
                                FROM INSERTED I
                                         INNER JOIN P_ARTICLE PA ON I.ID_ARTICLE = PA.ID_ARTICLE
                                         INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = I.ID_ENTREPOT
                                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                                --consommation entrepôt destination
                                INSERT INTO [10.7.5.25].AXINTERFACEDB.DBO.T_CONSUM_PROD2(JOURNAL, ARTICLE, SITE,
                                                                                         ENTREPOT, EMPLACEMENT, LOT,
                                                                                         CONFIGURATION, COULEUR, TAILLE,
                                                                                         STYLE, VERSION, QUANTITE, PRIX,
                                                                                         AMOUNT, ACTIVITE, AGENCE, BU,
                                                                                         CANAL, G_ARTICLE,
                                                                                         INTERCOS, PROJET, DATE,
                                                                                         SITE_STOCK, STOCK_MODE,
                                                                                         EXTERNALREF, UNIT_PRICE)
                                SELECT 'STJ' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.ITEMID,
                                       ISNULL(PE.SITE, ''),
                                       REF_ENTREPOT,
                                       'VEND_01',
                                       ISNULL(NUM_LOT, ''),
                                       ISNULL(PA.CONFIG, ''),
                                       ISNULL(PA.COLOR, ''),
                                       ISNULL(PA.SIZE, ''),
                                       ISNULL(PA.STYLE, ''),
                                       ISNULL(PA.VERSION, ''),
                                       -1 * QTE,
                                       0,
                                       0 * -1 * QTE,
                                       case WHEN PE.ACTIVITE = '' then '9999' ELSE PE.ACTIVITE end,
                                       case WHEN PE.AGENCE = '' then '9999' ELSE PE.AGENCE END,
                                       case WHEN PE.BU = '' then '9999' ELSE PE.BU END,
                                       case WHEN PE.CANAL = '' then '9999' ELSE PE.CANAL END,
                                       case WHEN PA.G_ARTICLE_ART = '' then '9999' ELSE PA.G_ARTICLE_ART END,
                                       case WHEN PE.INTERCOS = '' then '9999' ELSE PE.INTERCOS END,
                                       case WHEN PE.PROJET = '' then '9999' ELSE PE.PROJET END,
                                       FORMAT(getdate(), 'dd/MM/yyyy'),
                                       PS.REF_SITE,
                                       'STD',
                                       'STJ' + CAST(ID_OPERATION AS VARCHAR(50)),
                                       PA.UNITEPRIXSTOCK
                                FROM INSERTED I
                                         INNER JOIN P_ARTICLE PA ON I.ID_ARTICLE = PA.ID_ARTICLE
                                         INNER JOIN P_ENTREPOT PE ON PE.ID_ENTREPOT = I.ID_ENTREPOT_ANALYTIQUE
                                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                            END
                    END
            END
    END TRY
    BEGIN CATCH
        declare @err varchar(max)
        SELECT @err = ERROR_MESSAGE()
        RAISERROR (@err, 16, 1 );
    END CATCH
END;


go

create table dbo.ST_AJUSTEMENT_PROD_CONS_PPF
(
    ID_AJUSTEMENT_PROD_CONS int not null
        constraint PK_ST_AJUSTEMENT_PROD_CONS_PPF
            primary key
        constraint FK_ST_AJUSTEMENT_PROD_CONS_PPF_ST_AJUSTEMENT_PROD_CONS
            references dbo.ST_AJUSTEMENT_PROD_CONS,
    NUM_PALETTE             bigint
)
go

create table dbo.ST_AJUSTEMENT_PROD_CONS_SORTIE_CARBURANT
(
    ID_AJUSTEMENT_PROD_CONS int not null
        constraint PK_ST_AJUSTEMENT_PROD_CONS_SORTIE_CARBURANT
            primary key
        constraint FK_ST_AJUSTEMENT_PROD_CONS_SORTIE_CARBURANT_ST_AJUSTEMENT_PROD_CONS
            references dbo.ST_AJUSTEMENT_PROD_CONS,
    ID_VEHICULE             int,
    ID_CHAUFFEUR            int,
    INDEX_KM                int,
    COMPTEUR_POMPE          int,
    DATE_HEURES_SORTIE      datetime
        constraint DF_ST_AJUSTEMENT_PROD_CONS_SORTIE_CARBURANT_DATE_HEURES_SORTIE default sysdatetime(),
    COMMENTAIRE             varchar(128),
    ID_VEHICULE_EXTERNE     int
        constraint FK_ST_AJUSTEMENT_PROD_CONS_SORTIE_CARBURANT_P_VEHICULE_EXTERNE
            references dbo.P_VEHICULE_EXTERNE,
    ID_DEMENDEUR_EXTERNE    int
        constraint FK_ST_AJUSTEMENT_PROD_CONS_SORTIE_CARBURANT_P_DEMANDEUR_EXTERNE
            references dbo.P_DEMANDEUR_EXTERNE
)
go

create table dbo.ST_CARBURANT_PROD_CONS
(
    ID_OPERATION int identity
        constraint PK_ST_CARBURANT_PROD_CONS
            primary key,
    QTE          float not null,
    ID_ENTREPOT  int,
    ID_ARTICLE   int
)
go

create table dbo.ST_CARBURANT_TEST
(
    ID_AJUSTEMENT_PROD_CONS int not null,
    ID_VEHICULE             int,
    ID_CHAUFFEUR            int,
    INDEX_KM                int,
    COMPTEUR_POMPE          int,
    DATE_HEURES_SORTIE      date,
    COMMENTAIRE             varchar(128),
    ID_VEHICULE_EXTERNE     int
)
go

create table dbo.ST_CONTROLE_RECEPTION_CMD_FRNS
(
    ID_ARTICLE            int
        constraint FK_ST_CONTROLE_RECEPTION_CMD_FRNS_P_ARTICLE
            references dbo.P_ARTICLE,
    CLE_AX                varchar(50),
    QTE                   float,
    ID_UNITE              int
        constraint FK_ST_CONTROLE_RECEPTION_CMD_FRNS_P_UNITE
            references dbo.P_UNITE,
    GPS_SAISIE            varchar(128),
    NUM_BC                varchar(50),
    NUM_FOURNISSEUR       varchar(50),
    FOURNISSEUR           varchar(128),
    DATE_HEURE_SAISIE     datetime,
    ID_OP_SAISIE          int
        constraint FK_ST_CONTROLE_RECEPTION_CMD_FRNS_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_OP_VALIDATION      int
        constraint FK_ST_CONTROLE_RECEPTION_CMD_FRNS_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    DATE_HEURE_VALIDATION datetime,
    GPS_VALIDATION        varchar(128),
    ID                    int identity
        constraint PK_ST_CONTROLE_RECEPTION_CMD_FRNS
            primary key
)
go

create table dbo.ST_ENTREPOT_MAGASINIER
(
    ID_MAGASINIER       int not null
        constraint FK_ST_ENTREPOT_MAGASINIER_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_ENTREPOT         int not null
        constraint FK_ST_ENTREPOT_MAGASINIER_P_ENTREPOT
            references dbo.P_ENTREPOT,
    CREATE_PHYSICAL_INV bit
        constraint DF_ST_ENTREPOT_MAGASINIER_CREATE_PHYSICAL_INV default 0,
    DATE_TIME_SAISIE    datetime
        constraint DF_ST_ENTREPOT_MAGASINIER_DATE_TIME_SAISIE default getdate(),
    ID_OP_SAISIE        int
        constraint FK_ST_ENTREPOT_MAGASINIER_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    constraint PK_ST_ENTREPOT_MAGASINIER
        primary key (ID_MAGASINIER, ID_ENTREPOT)
)
go

create table dbo.ST_MOTIF_CONSOMMATION_ARTICLE
(
    ID_MOTIF_CONSOMMATION_MP int identity
        constraint PK_ST_MOTIF_CONSOMMATION_ARTICLE
            primary key,
    MOTIF_CONSOMMATION_MP    varchar(50)
)
go

create table dbo.ST_CONSOMMATION_MACHINE_ARTICLE
(
    ID_MACHINE                      int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_P_MACHINE
            references dbo.P_MACHINE,
    ID_UNITE_STOCK                  int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_P_UNITE
            references dbo.P_UNITE,
    ID_PILOTE                       int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_HEURE_SAISIE               datetime
        constraint DF_ST_CONSOMMATION_MACHINE_ARTICLE_DATE_HEURE_SAISIE default getdate(),
    ID_UNITE_CONSOMMATION           int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_P_UNITE1
            references dbo.P_UNITE,
    COEFFICIENT                     float,
    ID_ENTREPOT                     int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_P_ENTREPOT
            references dbo.P_ENTREPOT,
    ID_SHIFT                        int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_P_SHIFT
            references dbo.P_SHIFT,
    ID_ARTICLE                      int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_P_ARTICLE
            references dbo.P_ARTICLE,
    CLE_AX_ARTICLE                  varchar(50),
    QTE_CONSUM                      float,
    ID_CONSOMMATION                 int identity
        constraint PK_ST_CONSOMMATION_MACHINE_ARTICLE
            primary key,
    DATE_HEURE_SAISIE_DEBRANCHEMENT datetime,
    ID_UNITE_MESURE_DEBRANCHEMENT   int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_P_UNITE2
            references dbo.P_UNITE,
    QTE_CONSUM_FINAL                float,
    ID_PILOTE_DEBRANCHEMENT         int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    COEFFICIENT_CONV_FINAL          float,
    PMP                             float,
    LOT                             varchar(128),
    IMP                             bit
        constraint DF_ST_CONSOMMATION_MACHINE_ARTICLE_IMP default 0,
    ACTIF                           bit
        constraint DF_ST_CONSOMMATION_MACHINE_ARTICLE_ACTIF default 1,
    ID_MOTIF_CONSOMMATION_MP        int
        constraint FK_ST_CONSOMMATION_MACHINE_ARTICLE_ST_MOTIF_CONSOMMATION_ARTICLE
            references dbo.ST_MOTIF_CONSOMMATION_ARTICLE
)
go


CREATE TRIGGER [dbo].[AJUSTEMENT_STOCK_EMB]
    ON [dbo].[ST_CONSOMMATION_MACHINE_ARTICLE]
    AFTER INSERT, UPDATE, DELETE
    AS
BEGIN
    DECLARE @COUNTI INT, @COUNTD INT, @ACTIFD BIT, @ACTIFI BIT

    DECLARE @ID VARCHAR(20), @CLE_AX VARCHAR(20), @LIBELLE VARCHAR(20), @ID_ENTREPOT INT, @REF_UNITE VARCHAR(20), @NUM_LOT VARCHAR(20), @QTE_CONSUM_FINAL FLOAT,
        @DATE_HEURE_SAISIE_DEBRANCHEMENTI BIGINT, @DATE_HEURE_SAISIE_DEBRANCHEMENTD BIGINT,
        @QTE FLOAT, @VALEUR_UNITE_STCK FLOAT, @REF_SITE VARCHAR(20), @BU VARCHAR(20), @REF_ENTREPOT VARCHAR(20), @EMPLACEMENT VARCHAR(20);

    SELECT @COUNTI = COUNT(*)
    FROM inserted;
    SELECT @COUNTD = COUNT(*)
    FROM deleted;

    BEGIN TRY

        IF (@COUNTI > 1 OR @COUNTD > 1)
            BEGIN
                RAISERROR ('Impossible de gerer les données en masse', 16, 1 );
            END

        -- BEFOR DELETE
        IF (@COUNTD = 1 AND @COUNTI = 0)
            BEGIN
                RAISERROR ('Impossible de supprimer une ligne d''ajustement, vous pouvez juste la désactivée ', 16, 1 );
            END

        IF
                (SELECT COUNT(*)
                 FROM INSERTED STC
                          INNER JOIN P_ENTREPOT PE ON STC.ID_ENTREPOT = PE.ID_ENTREPOT
                          INNER JOIN [10.7.5.25].AXINTERFACEDB.DBO.T_ENTREPOT TE
                                     ON TE.LIB_ENTREPOT = REF_ENTREPOT COLLATE French_CI_AS) = 0
            BEGIN
                RAISERROR ('Merci de contacter le support informatique afin de vous paramétrer un nouveau routine pour l''entrepôt séléctioné', 16, 1 );
            END

        -- BEFOR INSERT
        IF (@COUNTD = 0 AND @COUNTI = 1)
            BEGIN

                SELECT @ID = CAST(ID_CONSOMMATION AS VARCHAR),
                       @CLE_AX = CLE_AX,
                       @LIBELLE = LIBELLE,
                       @ID_ENTREPOT = TE.ID_ENTREPOT,
                       @REF_ENTREPOT = PE.REF_ENTREPOT,
                       @REF_UNITE = PSTK.REF_UNITE,
                       @NUM_LOT = LOT,
                       @EMPLACEMENT = WMSLOCATIONIDDEFAULTRECEIPT,
                       @QTE = (CAST(COEFFICIENT AS FLOAT) * CAST(QTE_CONSUM AS FLOAT) * -1),
                       @VALEUR_UNITE_STCK = 0,
                       @REF_SITE = PS.REF_SITE,
                       @BU = CONCAT(TE.BU, '--')
                FROM INSERTED STC
                         INNER JOIN P_ARTICLE PA ON STC.ID_ARTICLE = PA.ID_ARTICLE
                         INNER JOIN P_ENTREPOT PE ON STC.ID_ENTREPOT = PE.ID_ENTREPOT
                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                         INNER JOIN P_UNITE PSTK ON PSTK.ID_UNITE = STC.ID_UNITE_CONSOMMATION
                         INNER JOIN [10.7.5.25].AXINTERFACEDB.DBO.T_ENTREPOT TE
                                    ON TE.LIB_ENTREPOT = REF_ENTREPOT COLLATE French_CI_AS
                         INNER JOIN [10.7.5.16].AXDB.DBO.INVENTLOCATION IL ON IL.INVENTLOCATIONID = TE.LIB_ENTREPOT

                INSERT INTO [10.7.5.25].AXINTERFACEDB.[dbo].[T_CONSUM_PROD]( [ID_ENTREPOT], [ITEMNUMBER], [NAME]
                                                                           , [INVENTUNIT], [INVENTORYSITEID]
                                                                           , [WAREHOUSEID], [WAREHOUSELOCATIONID]
                                                                           , [INVENTORYSTATUSID]
                                                                           , [COUNTEDQUANTITY], [ITEMBATCHNUMBER]
                                                                           , [DEFAULTLEDGERDIMENSIONDISPLAYVALUE]
                                                                           , [SAG_COSTPRICE], [SAG_COSTAMOUNT]
                                                                           , [EXTERNALREFERENCE])
                VALUES (@ID_ENTREPOT, @CLE_AX, @LIBELLE, @REF_UNITE, @REF_SITE, @REF_ENTREPOT, @EMPLACEMENT, 'STD',
                        @QTE, @NUM_LOT, @BU, @VALEUR_UNITE_STCK, @VALEUR_UNITE_STCK * @QTE, @ID)
            END;
            -- BEFOR UPDATE
        ELSE
            IF (@COUNTD = 1 AND @COUNTI = 1)
                BEGIN
                    SELECT @ACTIFI = ACTIF,
                           @DATE_HEURE_SAISIE_DEBRANCHEMENTI =
                           DATEDIFF(SECOND, {d '1970-01-01'}, DATE_HEURE_SAISIE_DEBRANCHEMENT),
                           @QTE_CONSUM_FINAL = QTE_CONSUM_FINAL
                    FROM inserted;
                    SELECT @ACTIFd = ACTIF,
                           @DATE_HEURE_SAISIE_DEBRANCHEMENTD =
                           DATEDIFF(SECOND, {d '1970-01-01'}, DATE_HEURE_SAISIE_DEBRANCHEMENT)
                    FROM deleted;

                    IF
                            @ACTIFI = 1 AND @ACTIFD = 1 AND @DATE_HEURE_SAISIE_DEBRANCHEMENTI IS NOT NULL AND
                            @DATE_HEURE_SAISIE_DEBRANCHEMENTD IS NULL
                        BEGIN

                            IF (ISNULL(@QTE_CONSUM_FINAL, 0) > 0)
                                BEGIN
                                    SELECT @ID = CAST(ID_CONSOMMATION AS VARCHAR),
                                           @CLE_AX = CLE_AX,
                                           @LIBELLE = LIBELLE,
                                           @ID_ENTREPOT = TE.ID_ENTREPOT,
                                           @REF_ENTREPOT = PE.REF_ENTREPOT,
                                           @REF_UNITE = PSTK.REF_UNITE,
                                           @NUM_LOT = LOT,
                                           @EMPLACEMENT = WMSLOCATIONIDDEFAULTRECEIPT,
                                           @QTE =
                                           (CAST(COEFFICIENT_CONV_FINAL AS FLOAT) * CAST(QTE_CONSUM_FINAL AS FLOAT)),
                                           @VALEUR_UNITE_STCK = 0,
                                           @REF_SITE = PS.REF_SITE,
                                           @BU = CONCAT(TE.BU, '--')
                                    FROM INSERTED STC
                                             INNER JOIN P_ARTICLE PA ON STC.ID_ARTICLE = PA.ID_ARTICLE
                                             INNER JOIN P_ENTREPOT PE ON STC.ID_ENTREPOT = PE.ID_ENTREPOT
                                             INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                                             INNER JOIN P_UNITE PSTK ON PSTK.ID_UNITE = STC.ID_UNITE_MESURE_DEBRANCHEMENT
                                             INNER JOIN [10.7.5.25].AXINTERFACEDB.DBO.T_ENTREPOT TE
                                                        ON TE.LIB_ENTREPOT = REF_ENTREPOT COLLATE French_CI_AS
                                             INNER JOIN [10.7.5.16].AXDB.DBO.INVENTLOCATION IL
                                                        ON IL.INVENTLOCATIONID = TE.LIB_ENTREPOT

                                    INSERT INTO [10.7.5.25].AXINTERFACEDB.[dbo].[T_CONSUM_PROD]( [ID_ENTREPOT]
                                                                                               , [ITEMNUMBER], [NAME]
                                                                                               , [INVENTUNIT]
                                                                                               , [INVENTORYSITEID]
                                                                                               , [WAREHOUSEID]
                                                                                               , [WAREHOUSELOCATIONID]
                                                                                               , [INVENTORYSTATUSID]
                                                                                               , [COUNTEDQUANTITY]
                                                                                               , [ITEMBATCHNUMBER]
                                                                                               , [DEFAULTLEDGERDIMENSIONDISPLAYVALUE]
                                                                                               , [SAG_COSTPRICE]
                                                                                               , [SAG_COSTAMOUNT]
                                                                                               , [EXTERNALREFERENCE])
                                    VALUES (@ID_ENTREPOT, @CLE_AX, @LIBELLE, @REF_UNITE, @REF_SITE, @REF_ENTREPOT,
                                            @EMPLACEMENT, 'STD',
                                            @QTE, @NUM_LOT, @BU, @VALEUR_UNITE_STCK, @VALEUR_UNITE_STCK * @QTE, @ID)
                                END
                        END
                    ELSE
                        IF (@ACTIFI = 0 AND @ACTIFD = 1) AND (@DATE_HEURE_SAISIE_DEBRANCHEMENTD IS NULL) AND
                           @DATE_HEURE_SAISIE_DEBRANCHEMENTI IS NULL
                            BEGIN
                                SELECT @ID = CAST(ID_CONSOMMATION AS VARCHAR),
                                       @CLE_AX = CLE_AX,
                                       @LIBELLE = LIBELLE,
                                       @ID_ENTREPOT = TE.ID_ENTREPOT,
                                       @REF_ENTREPOT = PE.REF_ENTREPOT,
                                       @REF_UNITE = PSTK.REF_UNITE,
                                       @NUM_LOT = LOT,
                                       @EMPLACEMENT = WMSLOCATIONIDDEFAULTRECEIPT,
                                       @QTE = (CAST(COEFFICIENT AS FLOAT) * CAST(QTE_CONSUM AS FLOAT)),
                                       @VALEUR_UNITE_STCK = 0,
                                       @REF_SITE = PS.REF_SITE,
                                       @BU = CONCAT(TE.BU, '--')
                                FROM INSERTED STC
                                         INNER JOIN P_ARTICLE PA ON STC.ID_ARTICLE = PA.ID_ARTICLE
                                         INNER JOIN P_ENTREPOT PE ON STC.ID_ENTREPOT = PE.ID_ENTREPOT
                                         INNER JOIN P_SITE PS ON PS.ID_SITE = PE.ID_SITE
                                         INNER JOIN P_UNITE PSTK ON PSTK.ID_UNITE = STC.ID_UNITE_CONSOMMATION
                                         INNER JOIN [10.7.5.25].AXINTERFACEDB.DBO.T_ENTREPOT TE
                                                    ON TE.LIB_ENTREPOT = REF_ENTREPOT COLLATE French_CI_AS
                                         INNER JOIN [10.7.5.16].AXDB.DBO.INVENTLOCATION IL
                                                    ON IL.INVENTLOCATIONID = TE.LIB_ENTREPOT

                                INSERT INTO [10.7.5.25].AXINTERFACEDB.[dbo].[T_CONSUM_PROD]( [ID_ENTREPOT], [ITEMNUMBER]
                                                                                           , [NAME], [INVENTUNIT]
                                                                                           , [INVENTORYSITEID]
                                                                                           , [WAREHOUSEID]
                                                                                           , [WAREHOUSELOCATIONID]
                                                                                           , [INVENTORYSTATUSID]
                                                                                           , [COUNTEDQUANTITY]
                                                                                           , [ITEMBATCHNUMBER]
                                                                                           , [DEFAULTLEDGERDIMENSIONDISPLAYVALUE]
                                                                                           , [SAG_COSTPRICE]
                                                                                           , [SAG_COSTAMOUNT]
                                                                                           , [EXTERNALREFERENCE])
                                VALUES (@ID_ENTREPOT, @CLE_AX, @LIBELLE, @REF_UNITE, @REF_SITE, @REF_ENTREPOT,
                                        @EMPLACEMENT, 'STD',
                                        @QTE, @NUM_LOT, @BU, @VALEUR_UNITE_STCK, @VALEUR_UNITE_STCK * @QTE, @ID)
                            END
                        ELSE
                            BEGIN
                                RAISERROR ('Merci de suivre la procédure de correction des ajustements de stock', 16, 1 );
                            END
                END;
    END TRY
    BEGIN CATCH
        declare @err varchar(max)
        SELECT @err = ERROR_MESSAGE()
        RAISERROR (@err, 16, 1 );
    END CATCH
END;
go

disable trigger dbo.AJUSTEMENT_STOCK_EMB on dbo.ST_CONSOMMATION_MACHINE_ARTICLE
go

create table dbo.ST_NATURE_AJUSTEMENT
(
    ID_NATURE_AJUSTEMENT int identity
        constraint PK_ST_NATURE_AJUSTEMENT
            primary key,
    NATURE_AJUSTEMENT    varchar(50),
    ABRV                 varchar(50)
)
go

create table dbo.ST_NATURE_AJUSTEMENT_ENTREPOT
(
    ID_ENTREPOT          int not null
        constraint FK_ST_NATURE_AJUSTEMENT_ENTREPOT_P_ENTREPOT
            references dbo.P_ENTREPOT,
    ID_NATURE_AJUSTEMENT int not null
        constraint FK_ST_NATURE_AJUSTEMENT_ENTREPOT_ST_NATURE_AJUSTEMENT
            references dbo.ST_NATURE_AJUSTEMENT,
    DATE_HEURS_SAISIE    datetime,
    ID_OP_SAISIE         int,
    constraint PK_ST_NATURE_AJUSTEMENT_ENTREPOT
        primary key (ID_ENTREPOT, ID_NATURE_AJUSTEMENT)
)
go

create table dbo.ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX
(
    DATE_TIME_SAISIE  datetime
        constraint DF_ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX_DATE_TIME_SAISIE default getdate(),
    ID_OP_SAISIE      int
        constraint FK_ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    NBR_ARTICLE       int,
    NBR_JOURS_RELANCE int,
    ID_ENTREPOT       int not null
        constraint PK_ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX
            primary key
        constraint FK_ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX_P_ENTREPOT
            references dbo.P_ENTREPOT
)
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.A_UTILISATEUR.ID_UTILISATEUR', 'SCHEMA', 'dbo', 'TABLE',
     'ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX', 'COLUMN', 'ID_OP_SAISIE'
go

exec sp_addextendedproperty 'MS_Description', 'BD_INTEGRALE.DBO.P_ENTREPOT.ID_ENTREPOT', 'SCHEMA', 'dbo', 'TABLE',
     'ST_PARAMETRAGE_INVENTAIRE_CONTROL_FLUX', 'COLUMN', 'ID_ENTREPOT'
go

create table dbo.ST_PERIODE_SAISIE
(
    ID_PERIODE_SAISIE int identity
        constraint PK_ST_PERIODE_SAISIE
            primary key,
    DATE_DEBUT        date,
    DATE_FIN          date,
    CLOTURE           bit,
    DATE_H_SAISIE     datetime,
    ID_OP_SAISIE      int
        constraint FK_ST_PERIODE_SAISIE_A_UTILISATEUR
            references dbo.A_UTILISATEUR
)
go

create table dbo.ST_PRIX_PRODUCTION_ARTICLE
(
    ID_ARTICLE        int,
    ID_UNITE_STOCK    int,
    PRIX_UNITE        float,
    DATE_DEBUT        date,
    DATE_FIN          date,
    DATE_HEURE_SAISIE datetime
        constraint DF_ST_PRIX_PRODUCTION_ARTICLE_DATE_HEURE_SAISIE default sysdatetime(),
    ID_OP_SAISIE      int,
    ID_PRIX           int identity
        constraint PK_ST_PRIX_PRODUCTION_ARTICLE
            primary key
)
go

create table dbo.ST_TYPE_AJUSTEMENT
(
    ID_TYPE_AJUSTEMENT int identity
        constraint PK_ST_TYPE_AJUSTEMENT
            primary key,
    TYPE_AJUSTEMENT    varchar(50)
)
go

create table dbo.T_AGENCE_ARTICLE_ENTREPOT
(
    ID_ENTREPOT                  int not null,
    ID_ARTICLE_COMMANDE_ENTREPOT int not null,
    ACTIF                        bit,
    DATE_HEURE_SAISIE            datetime
)
go

create table dbo.T_ANALYSES
(
    ID_ANALYSE                     bigint identity
        constraint PK_T_ANALYSES_LOT_11
            primary key,
    compagne                       nchar(4),
    Code_Bar                       nvarchar(50),
    code_bar1                      nvarchar(50),
    cpt                            int,
    cpt1                           int,
    ID_LOT                         int,
    Id_Lot_ancien                  int,
    ID_TYPE_ANALYSE                int,
    DATE_HEURE                     datetime
        constraint DF_T_ANALYSES_DATE_HEURE1 default getdate(),
    NUM_BON                        nvarchar(50),
    NUM_CUVE                       int,
    TEMP                           real,
    TEMP_Reception                 real,
    Date_Reception                 datetime,
    ID_Receptionneur               int,
    Recu                           int
        constraint DF_T_ANALYSES_Recu1 default 0,
    Observation_Reception          nvarchar(max),
    Refuser                        int
        constraint DF_T_ANALYSES_Refuser1 default 0,
    Motif_Refu                     nvarchar(max),
    CODE_TOURNEE                   int,
    ID_DEMANDEUR                   int,
    Id_Pasteurisateur              int,
    Id_Refroidisseur               int,
    Num_Palette                    bigint,
    Id_Point_Prelevement           int,
    ID_DT_Bon_Collecte             bigint,
    ID_Bac                         int,
    Id_LABO_Produit                int,
    Id_Machine                     int,
    ID_Etape_Process               int,
    Statu                          nchar(20),
    CLOTURER                       int
        constraint DF_T_ANALYSES_CLOTURER1 default 0,
    Observation_Cloture            nvarchar(max),
    ID_Clotureur                   int,
    Date_Analyse                   datetime,
    Signer                         int
        constraint DF_T_ANALYSES_Signer1 default 0,
    Id_Operateur_Signature         int,
    Date_Signtaure                 datetime,
    Archiver                       int
        constraint DF_T_ANALYSES_Archiver1 default 0,
    Type                           int
        constraint DF_T_ANALYSES_Type1 default 0,
    Approber                       int
        constraint DF_T_ANALYSES_Approber1 default 0,
    ID_Approbateur                 int,
    Date_Approbation               datetime,
    Commentaire                    nvarchar(max),
    Conformite                     int
        constraint DF_T_ANALYSES_Conformite1 default 0,
    Motif                          nvarchar(max),
    Id_Declotureur                 int,
    Date_Decloture                 datetime,
    Labo                           int
        constraint DF_T_ANALYSES_Labo1 default 1,
    Nature_A                       int
        constraint DF_T_ANALYSES_Nature_A1 default 0,
    Exporter                       int
        constraint DF_T_ANALYSES_Exporter1 default 0,
    Reserver                       int
        constraint DF_T_ANALYSES_Reserver1 default 0,
    Emetteur                       nvarchar(50),
    Prelveur                       nvarchar(50),
    Debut_Prelev                   datetime,
    Fin_Prelev                     datetime,
    Qte                            real,
    Ref_Emetteur                   nvarchar(50),
    Num_Envoi_Usine                nvarchar(max),
    Lot_AALAF                      nvarchar(50),
    Origine                        nvarchar(50),
    Id_Parcelle                    int,
    Id_variete                     int,
    Id_Puit                        int,
    Id_Producteur                  int,
    Id_Verger                      int,
    Id_Lot_AALAF                   int,
    Dte_ADD                        datetime
        constraint DF_T_ANALYSES_Dte_ADD1 default getdate(),
    Liberer                        int
        constraint DF_T_ANALYSES_Liberer1 default 0,
    Id_libereur                    int,
    Dte_Liberation                 datetime,
    Dte_DLC                        datetime,
    Dte_FAB                        datetime,
    Nbre_Ech_Creation              int
        constraint DF_T_ANALYSES_Nbre_Ech_Creation1 default 0,
    Nbre_Ech_Recu                  int
        constraint DF_T_ANALYSES_Nbre_Ech_Recu1 default 0,
    Observ_Liberation              nvarchar(max),
    ordre_ech                      int,
    Nature_Ech                     int
        constraint DF_T_ANALYSES_Nature_Ech1 default 0,
    Chronologie                    nchar(10),
    N_Fut                          nvarchar(50),
    Id_lot_Abatoir                 int,
    Id_prod_abattoir               int,
    IdRaisonAnalyse                int,
    ID_ECHANTILLON_DT_BON_COLLECTE int,
    NV_CODE_TOURNEE                int
)
go

exec sp_addextendedproperty 'MS_Description', 'Date clôture de l''analyse', 'SCHEMA', 'dbo', 'TABLE', 'T_ANALYSES',
     'COLUMN', 'Date_Analyse'
go

exec sp_addextendedproperty 'MS_Description', '0 Analyse PN non Traiter,1 liberer ,2 Bloquer', 'SCHEMA', 'dbo', 'TABLE',
     'T_ANALYSES', 'COLUMN', 'Liberer'
go

create table dbo.T_ARTICLE_COMMANDE_ENTREPOT
(
    ID_ARTICLE_COMMANDE_ENTREPOT int not null,
    ID_ARTICLE                   int,
    ID_ENTREPOT                  int,
    DATE_SAISIE                  datetime
)
go

create table dbo.T_CARTE_AUTOROUTE
(
    ID_CARTE          int identity
        constraint PK_T_CARTE_AUTOROUTE
            primary key,
    NUMERO            int not null,
    ACTIF             bit default 1,
    OP_SAISIE         int
        constraint FK_T_CARTE_AUTOROUTE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_HEURE_SAISIE datetime
        constraint DF_T_CARTE_AUTOROUTE_DATE_HEURE_SAISIE default getdate()
)
go

create table dbo.P_VEHICULE
(
    ID_VEHICULE                int identity
        constraint PK_T_VEHICULE
            primary key nonclustered,
    ID_TYPE_VEHICULE           int
        constraint FK_P_VEHICULE_P_TYPE_VEHICULE
            references dbo.P_TYPE_VEHICULE,
    ID_SITE                    int
        constraint FK_P_VEHICULE_P_SITE
            references dbo.P_SITE,
    ID_PROPRIETAIRE            int
        constraint FK_P_VEHICULE_P_PROPRIETAIRE
            references dbo.P_PROPRIETAIRE,
    MATRICULE_VEHICULE         varchar(25)
        constraint UNIQUE_MATRICULE_VEHICULE
            unique,
    PTC_VEHICULE               float,
    ID_BU                      int
        constraint FK_P_VEHICULE_P_BU
            references dbo.P_BU,
    ACTIF                      bit,
    ID_CATEGORIE_VEHICULE      int
        constraint FK_P_VEHICULE_P_CATEGORIE_VEHICULE
            references dbo.P_CATEGORIE_VEHICULE,
    ID_MODEL                   int
        constraint FK_P_VEHICULE_P_MODELE
            references dbo.P_MODELE,
    DATE_MES                   datetime,
    DATE_AJOUT_SYSTEME         datetime,
    ID_OPERATEUR_SAISIE        int
        constraint FK_P_VEHICULE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_SESSION_APPLICATIF_USER int,
    POSTE                      varchar(128),
    SESSION_WINDOWS            varchar(128),
    NOM_UTILISATEUR            varchar(128),
    DATETIME_OP                datetime,
    ID_VEHICULE_EXTERNE        int,
    ID_SECTION_ACTIVITE        int
        constraint FK_P_VEHICULE_P_SECTION_ACTIVITE
            references dbo.P_SECTION_ACTIVITE,
    ID_CARTE_AUTOROUTE         int
        constraint FK_P_VEHICULE_T_CARTE_AUTOROUTE
            references dbo.T_CARTE_AUTOROUTE,
    ABRV                       varchar(50)
)
go

create table dbo.P_AFFECTATION_DESTRIBUTION
(
    ID_AFFECTATION_SECTEURISATION bigint identity
        constraint P_AFFECTATION_DESTRIBUTION_pk
            primary key nonclustered,
    ID_SECTEUR                    int
        constraint FK_P_AFFECTATION_DESTRIBUTION_P_SECTEUR
            references dbo.P_SECTEUR,
    ID_TOURNEE                    int not null
        constraint FK_P_AFFECTATION_DESTRIBUTION_P_TOURNEE
            references dbo.P_TOURNEE,
    ID_VENDEUR                    int not null
        constraint FK_P_AFFECTATION_DESTRIBUTION_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_VEHICULE                   int
        constraint FK_P_AFFECTATION_DESTRIBUTION_P_VEHICULE
            references dbo.P_VEHICULE,
    ID_AIDE_VENDEUR1              int
        constraint FK_P_AFFECTATION_DESTRIBUTION_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    ID_AIDE_VENDEUR2              int
        constraint FK_P_AFFECTATION_DESTRIBUTION_A_UTILISATEUR2
            references dbo.A_UTILISATEUR,
    ID_CHAUFFEUR                  int
        constraint FK_P_AFFECTATION_DESTRIBUTION_A_UTILISATEUR3
            references dbo.A_UTILISATEUR,
    ID_SITE                       int
        constraint FK_P_AFFECTATION_DESTRIBUTION_P_SITE
            references dbo.P_SITE,
    DATE_HEURE_SAISIE             datetime default sysdatetime(),
    ID_PREVENDEUR                 int
        constraint FK_P_AFFECTATION_DESTRIBUTION_A_UTILISATEUR4
            references dbo.A_UTILISATEUR,
    ID_OP_SAISIE                  int
        constraint FK_P_AFFECTATION_DESTRIBUTION_A_UTILISATEUR5
            references dbo.A_UTILISATEUR
)
go

CREATE trigger [dbo].[TR_P_AFFECTATION_DESTRIBUTION]
    on DBO.P_AFFECTATION_DESTRIBUTION
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_AFFECTATION_DESTRIBUTION'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_AFFECTATION_DESTRIBUTION on dbo.P_AFFECTATION_DESTRIBUTION
go

CREATE trigger [dbo].[TR_P_VEHICULE]
    on DBO.P_VEHICULE
    for insert, update, delete as declare
    @bit int, @field int, @maxfield int, @char int, @fieldname varchar(128), @TableName varchar(128), @PKCols varchar(1000), @sql varchar(2000), @UpdateDate varchar(21), @UserName varchar(128), @Type char(1), @PKSelect varchar(1000)
DECLARE @NomPoste varchar(200) = RTRIM(LTRIM((SELECT hostname
                                              FROM SYS.DM_EXEC_CONNECTIONS EXC
                                                       INNER JOIN sys.sysprocesses SP ON SP.spid = EXC.session_id
                                              WHERE SESSION_ID = @@SPID)))
select @TableName = 'P_VEHICULE'
select @UserName = system_user,
       @UpdateDate = convert(varchar(8), getdate(), 112) + ' ' + convert(varchar(12), getdate(), 114)
if exists(select *
          from inserted)
    if exists(select * from deleted) select @Type = 'U' else select @Type = 'I'
else
    select @Type = 'D'
select *
into #ins
from inserted
select *
into #del
from deleted
select @PKCols = coalesce(@PKCols + ' and', ' on') + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
select @PKSelect =
       coalesce(@PKSelect + '+', '') + '''<' + COLUMN_NAME + '=''+convert(varchar(100),coalesce(i.' + COLUMN_NAME +
       ',d.' + COLUMN_NAME + '))+''>'''
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk,
     INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
where pk.TABLE_NAME = @TableName
  and CONSTRAINT_TYPE = 'PRIMARY KEY'
  and c.TABLE_NAME = pk.TABLE_NAME
  and c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
if @PKCols is null
    begin
        raiserror ('no PK on table %s', 16, -1, @TableName) return
    end
select @field = 0, @maxfield = max(ORDINAL_POSITION)
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @TableName
while @field < @maxfield begin
    select @field = min(ORDINAL_POSITION)
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_NAME = @TableName
      and ORDINAL_POSITION > @field
    select @bit = (@field - 1) % 8 + 1 select @bit = power(2, @bit - 1) select @char = ((@field - 1) / 8) + 1
    if substring(COLUMNS_UPDATED(), @char, 1) & @bit > 0 or @Type in ('I', 'D')
        begin
            select @fieldname = COLUMN_NAME
            from INFORMATION_SCHEMA.COLUMNS
            where TABLE_NAME = @TableName and ORDINAL_POSITION = @field
            select @sql =
                   'insert BD_TACABILITE_BD_COMMERCIAL.DBO.Audit_Integrale (Type, TableName, PK, FieldName, OldValue, NewValue, UpdateDate, UserName)'
            select @sql = @sql + ' select ''' + @Type + '''' select @sql = @sql + ',''' + @TableName + ''''
            select @sql = @sql + ',' + @PKSelect select @sql = @sql + ',''' + @fieldname + ''''
            select @sql = @sql + ',convert(varchar(1000),d.' + @fieldname + ')'
            select @sql = @sql + ',convert(varchar(1000),i.' + @fieldname + ')'
            select @sql = @sql + ',''' + @UpdateDate + ''''
            select @sql = @sql + ',''[' + @NomPoste + '] ' + @UserName + ''''
            select @sql = @sql + ' from #ins i full outer join #del d' select @sql = @sql + @PKCols
            select @sql = @sql + ' where i.' + @fieldname + ' <> d.' + @fieldname
            select @sql = @sql + ' or (i.' + @fieldname + ' is null and  d.' + @fieldname + ' is not null)'
            select @sql = @sql + ' or (i.' + @fieldname + ' is not null and  d.' + @fieldname + ' is null)' exec (@sql)
        end
end
go

disable trigger dbo.TR_P_VEHICULE on dbo.P_VEHICULE
go

create table dbo.T_ASSURANCES
(
    ID_VEHICULE       int
        constraint FK_T_ASSURANCES_P_VEHICULE
            references dbo.P_VEHICULE,
    ID_OP_SAISIE      int
        constraint FK_T_ASSURANCES_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_SAISIE       datetime
        constraint DF_T_ASSURANCES_DATE_SAISIE default getdate(),
    ID_ASSURANCE      int identity
        constraint PK_T_ASSURANCES
            primary key,
    MONTANT_ASSURANCE float,
    DATE_DEBUT        date,
    DATE_FIN          date,
    ACTIVE            int
        constraint DF_T_ASSURANCES_ACTIVE default 1 not null
)
go

create table dbo.T_MOTIF_DET_MISSION
(
    ID_MOTIF int identity
        primary key,
    LIBELLE  varchar(250) not null,
    ACTIF    bit default 1
)
go

create table dbo.T_STATUT_ORDRE_MISSION
(
    ID_STATUT_ORDRE_MISSION int identity
        constraint PK_P_STATUT_ORDRE_MISSION
            primary key,
    STATUT_ORDRE_MISSION    varchar(50),
    ABRV                    varchar(50)
)
go

create table dbo.T_ORDER_MISSION
(
    ID_ORDER_MISSION       bigint identity
        constraint PK_P_ORDER_MISSION
            primary key,
    DATE_HEURE_SAISIE      datetime
        constraint DF_P_ORDER_MISSION_DATE_HEURE_SAISIE default getdate(),
    REF_OM                 varchar(50)                                                   not null,
    ID_VEHICULE            int
        constraint FK_T_ORDER_MISSION_P_VEHICULE
            references dbo.P_VEHICULE,
    ID_SEMI                int
        constraint FK_T_ORDER_MISSION_P_VEHICULE1
            references dbo.P_VEHICULE,
    ID_STATUT              int
        constraint DF_T_ORDER_MISSION_VALIDER default 1
        constraint FK_T_ORDER_MISSION_P_STATUT_ORDRE_MISSION
            references dbo.T_STATUT_ORDRE_MISSION,
    ID_OP_SAISIE           int
        constraint FK_T_ORDER_MISSION_A_UTILISATEUR
            references dbo.A_UTILISATEUR
        constraint FK_T_ORDER_MISSION_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    ID_FACTURE             int,
    ID_TYPE_TRANSPORT      int
        constraint FK_T_ORDER_MISSION_P_TYPE_TRANSPORT
            references dbo.P_TYPE_TRANSPORT,
    ID_PROPRIETAIRE        int
        constraint FK_T_ORDER_MISSION_P_PROPRIETAIRE
            references dbo.P_PROPRIETAIRE,
    ID_CATEGORIE           int
        constraint FK_T_ORDER_MISSION_P_CATEGORIE_ACTIVITE
            references dbo.P_CATEGORIE_ACTIVITE,
    ACTIF                  bit
        constraint DF_T_ORDER_MISSION_ACTIF default 1,
    CLOTURE                bit
        constraint DF_T_ORDER_MISSION_CLOTURE default 0,
    ID_OP_COLLECTE_EXTERNE int,
    ID_SITE                int
        constraint DF_T_ORDER_MISSION_ID_SITE default 1
        constraint FK_T_ORDER_MISSION_P_SITE
            references dbo.P_SITE,
    ID_OP_IMPORT           int,
    DATE_IMPORT            datetime,
    DATE_EXPORT            datetime,
    ID_OP_EXPORT           int,
    SysStartTime           datetime2
        constraint DF_SysStart default sysutcdatetime()                                  not null,
    SysEndTime             datetime2
        constraint DF_SysEnd default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    DATE_CLOTURE           datetime,
    OP_CLOTURE             int
        constraint fk_opCloture_user
            references dbo.A_UTILISATEUR,
    DATE_SITUATION         date,
    QTTE_ANNONCE           float,
    QTTE_DEPOTE            float,
    ID_OP_QTTE_DEPOT       int,
    DATE_VALID_DEPOT       datetime,
    ID_CARTE_AUTOROUTE     int
        references dbo.T_CARTE_AUTOROUTE,
    QTE_ANNONCE_EXPORT     float
)
go

create table dbo.GC_DEPOTAGE
(
    ID_DEPOTAGE         bigint identity
        constraint PK_GC_DEPOTAGE
            primary key,
    DEBUT_DEPOTAGE      datetime,
    FIN_DEPOTAGE        datetime,
    QUANTITE            float,
    OP_DEPOTAGE         int
        constraint FK_GC_DEPOTAGE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    OP_VALIDATION       int
        constraint FK_GC_DEPOTAGE_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    DATE_STATIONNEMENT  datetime,
    DATE_DEPART         datetime,
    DATE_SAISIE_QTT     datetime
        constraint DF_GC_DEPOTAGE_DATE_SAISIE_QTT default getdate(),
    ID_ORDRE_MISSION    bigint
        constraint FK_GC_DEPOTAGE_T_ORDER_MISSION
            references dbo.T_ORDER_MISSION,
    DATE_VALIDATION     datetime,
    SysStartTime        datetime2 default sysdatetime()                                       not null,
    SysEndTime          datetime2 default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    TEMPERATURE_ENTREE  float,
    TEMPERATURE_SORTIE  float,
    ID_STATION_DEPOTAGE int
        constraint FK_GC_DEPOTAGE_GD_STATION_DEPOTAGE
            references dbo.GD_STATION_DEPOTAGE
        references dbo.GD_STATION_DEPOTAGE,
    ID_LIGNE_DEPOTAGE   int
        constraint FK_GC_DEPOTAGE_GD_LIGNE
            references dbo.GD_LIGNE
        references dbo.GD_LIGNE
)
go

create table dbo.GC_ANALYSE_DEPOTAGE
(
    ID_ANALYSE_DEPOTAGE bigint not null
        constraint PK_GC_ANALYSE_DEPOTAGE
            primary key,
    REFERENCE           varchar(50),
    OP_SAISIE           int
        constraint FK_GC_ANALYSE_DEPOTAGE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_SAISIE         datetime
        constraint DF_GC_ANALYSE_DEPOTAGE_DATE_SAISIE default getdate(),
    ID_DEPOTAGE         bigint
        constraint FK_GC_ANALYSE_DEPOTAGE_GC_DEPOTAGE
            references dbo.GC_DEPOTAGE,
    ID_TYPE_ANALYSE     int,
    ID_STATION_DEPOTAGE int
        references dbo.GD_STATION_DEPOTAGE
)
go

create table dbo.GC_CUVE_DEPOTAGE
(
    QUANTITE    float,
    ID_CUVE     int    not null
        constraint FK_GC_CUVE_DEPOTAGE_GC_CUVE
            references dbo.GC_CUVE,
    ID_DEPOTAGE bigint not null
        constraint FK_GC_CUVE_DEPOTAGE_GC_DEPOTAGE
            references dbo.GC_DEPOTAGE,
    DATE_SAISIE datetime
        constraint DF_GC_CUVE_DEPOTAGE_DATE_SAISIE default getdate(),
    OP_SAISIE   int
        constraint FK_GC_CUVE_DEPOTAGE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    primary key (ID_CUVE, ID_DEPOTAGE)
)
go

create table dbo.GC_MOBILE_HISTORY
(
    ID_HISTORY        bigint identity
        primary key,
    ID_ORDRE_MISSION  bigint
        references dbo.T_ORDER_MISSION,
    DATA              varchar(max),
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    ID_OP_SAISIE      int
        references dbo.A_UTILISATEUR,
    ID_AGENT_COLLECTE int
        references dbo.A_UTILISATEUR,
    FILE_DESTINATION  varchar(200)
)
go

create table dbo.GC_NETTOYAGE
(
    ID_NETTOYAGE         bigint identity
        constraint PK_GC_NETTOAYEG
            primary key,
    DATE_DEBUT           datetime,
    DATE_FIN             datetime,
    ID_DEPOTAGE          bigint
        constraint FK_GC_NETTOAYEG_GC_DEPOTAGE
            references dbo.GC_DEPOTAGE,
    ID_TYPE_NETTOYAGE    int
        constraint FK_GC_NETTOAYEG_GC_TYPE_NETTOYAGE
            references dbo.GC_TYPE_NETTOYAGE,
    DATE_SAISIE          datetime
        constraint DF_GC_NETTOAYEG_DATE_SAISIE default getdate(),
    OP_SAISIE            int
        constraint FK_GC_NETTOYAGE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_LIGNE_NETTOYAGE   int
        references dbo.GD_LIGNE,
    ID_STATION_NETTOYAGE int
        references dbo.GD_STATION_DEPOTAGE,
    OP_VALIDATION        int
        references dbo.A_UTILISATEUR,
    DATE_VALIDATION      datetime,
    OBSERVATION          varchar(max)
)
go

create table dbo.GD_DEPOTAGE_MOUVEMENT
(
    ID_STATION_SRC        int not null
        references dbo.GD_STATION_DEPOTAGE,
    ID_STATION_DEST       int not null
        references dbo.GD_STATION_DEPOTAGE,
    ID_DEPOTAGE           bigint
        references dbo.GC_DEPOTAGE,
    ACTIF                 bit      default 1,
    ID_MOTIF              int not null
        references dbo.GD_MOTIF_DEPOTAGE,
    DATE_HEURE_SAISIE     datetime default sysdatetime(),
    OP_SAISIE             int
        references dbo.A_UTILISATEUR,
    ID_LIGNE_SRC          int
        references dbo.GD_LIGNE,
    ID_DEPOTAGE_MOUVEMENT bigint identity
        constraint GD_DEPOTAGE_MOUVEMENT_pk
            primary key nonclustered
)
go

create table dbo.GD_STATION_MISSION
(
    ID_STATION        int    not null
        references dbo.GD_STATION_DEPOTAGE,
    ID_ORDRE_MISSION  bigint not null
        references dbo.T_ORDER_MISSION,
    ACTIF             bit      default 1,
    ID_MOTIF          int
        references dbo.GD_MOTIF_DEPOTAGE,
    DATE_HEURE_SAISIE datetime default sysdatetime(),
    OP_SAISIE         int
        references dbo.A_UTILISATEUR
)
go

create table dbo.T_DET_MISSION
(
    ID_DET_MISSION             bigint identity
        constraint PK_T_DET_MISSION
            primary key,
    ID_ORDER_MISSION           bigint                                                                 not null
        constraint FK_T_DET_MISSION_T_ORDER_MISSION
            references dbo.T_ORDER_MISSION,
    ID_TOURNEE                 int                                                                    not null
        constraint FK_T_DET_MISSION_P_TOURNEE
            references dbo.P_TOURNEE,
    DATE_HEURE_DEPART          datetime,
    DATE_HEURE_ARRIVEE         datetime,
    ID_CONTROLLEUR_FLUX_SORTIE int
        constraint FK_T_DET_MISSION_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    KM_ENTRE                   int,
    KM_SORTIE                  int,
    POIDS_NET                  float,
    NBR_PALETTE                float,
    ID_CONTROLLEUR_FLUX_ENTREE int
        constraint FK_T_DET_MISSION_A_UTILISATEUR1
            references dbo.A_UTILISATEUR,
    ID_OP_SAISIE               int
        constraint FK_T_DET_MISSION_A_UTILISATEUR2
            references dbo.A_UTILISATEUR,
    DATE_HEURE_SAISIE          datetime
        constraint DF_T_DET_MISSION_DATE_HEURE_SAISIE default getdate(),
    ANNULER                    bit
        constraint DF_T_DET_MISSION_ANNULER default 0,
    KM_ARRET                   float,
    ORDRE                      int,
    COORDONNEES_ENTREE         varchar(200),
    COORDONNEES_SORTIE         varchar(200),
    DATE_SITUATION             date,
    DATE_VALIDATION            datetime,
    ID_OP_VALIDATION           int
        constraint FK_T_DET_MISSION_A_UTILISATEUR3
            references dbo.A_UTILISATEUR,
    SCELLE_ENTREE              varchar(200),
    SCELLE_SORTIE              varchar(200),
    SysStartTime               datetime2
        constraint DF_SysStartT_DET_MISSION default sysutcdatetime()                                  not null,
    SysEndTime                 datetime2
        constraint DF_SysEndT_DET_MISSION default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    ID_MOTIF                   int
        references dbo.T_MOTIF_DET_MISSION
)
go

create table dbo.GC_BON_COLLECTE
(
    ID_BON_COLLECTE           bigint identity
        constraint PK_GC_BON_COLLECTE
            primary key,
    REF_BON_COLLECTE          varchar(50),
    DATE_HEURE_SAISIE         datetime
        constraint DF_GC_BON_COLLECTE_DATE_HEURE_SAISIE default getdate(),
    ID_DET_MISSION            bigint
        constraint FK_GC_BON_COLLECTE_T_DET_MISSION
            references dbo.T_DET_MISSION,
    ID_QUINZAINE              bigint,
    ID_UNITE_PRODUCTION       int
        constraint FK_GC_BON_COLLECTE_P_UNITE_PRODUCTION
            references dbo.P_UNITE_PRODUCTION,
    QTE_TOTAL                 float,
    PRIX_FACTURATION          float,
    ID_FACTURE                int,
    DATE_EXPORTATION          datetime
        constraint DF_GC_BON_COLLECTE_DATE_EXPORTATION default getdate(),
    ID_OP_SAISIE              int
        constraint FK_GC_BON_COLLECTE_A_UTILISATEUR_OP
            references dbo.A_UTILISATEUR,
    IMPRIMER                  bit,
    DATE_VALIDATION           datetime,
    ID_OP_VALIDATION          int
        constraint FK_GC_BON_COLLECTE_A_UTILISATEUR_VAL
            references dbo.A_UTILISATEUR,
    SysStartTime              datetime2
        constraint DF_SysStartGC_BON_COLLECTE default sysutcdatetime()                                  not null,
    SysEndTime                datetime2
        constraint DF_SysEndGC_BON_COLLECTE default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    QTE_TOTAL_CNC             float,
    ID_TOURNEE                int
        constraint FK_GC_BON_COLLECTE_P_TOURNEE
            references dbo.P_TOURNEE,
    ID_SITE                   int
        constraint FK_GC_BON_COLLECTE_P_SITE
            references dbo.P_SITE,
    ID_ZONE                   int
        constraint FK_GC_BON_COLLECTE_P_ZONE
            references dbo.P_ZONE,
    ID_ADHERENT               int
        constraint FK_GC_BON_COLLECTE_P_ADHERENT
            references dbo.P_ADHERENT,
    ID_PRODUCTEUR             int
        constraint FK_GC_BON_COLLECTE_P_PRODUCTEUR
            references dbo.P_PRODUCTEUR,
    CODE_BON_COLLECTE_EXTERNE bigint
)
go

create index INDEXGCBONCOLLECTE
    on dbo.GC_BON_COLLECTE (ID_DET_MISSION) include (ID_BON_COLLECTE, REF_BON_COLLECTE, ID_TOURNEE)
go

create table dbo.GC_DETAIL_BON_COLLECTE
(
    ID_DET_BON_COLLECTE bigint identity
        constraint PK_GC_DETAIL_BON_COLLECTE
            primary key,
    ID_BAC              int
        constraint FK_GC_DETAIL_BON_COLLECTE_GC_BAC_LAIT
            references dbo.GC_BAC_LAIT,
    QUANTITE            int                                                                                    not null,
    ID_ACIDITE          int
        constraint FK_GC_DETAIL_BON_COLLECTE_GC_ACIDITE
            references dbo.GC_ACIDITE,
    ID_STABILITE        int
        constraint FK_GC_DETAIL_BON_COLLECTE_GC_STABILITE
            references dbo.GC_STABILITE,
    TEMPERATURE         int,
    ID_DECISION         int
        constraint FK_GC_DETAIL_BON_COLLECTE_GC_DECISION
            references dbo.GC_DECISION,
    DATE_HEURE_SAISIE   datetime
        constraint DF_GC_DETAIL_BON_COLLECTE_DATE_SAISIE default getdate(),
    ID_BON_COLLECTE     bigint
        constraint FK_GC_DETAIL_BON_COLLECTE_GC_BON_COLLECTE
            references dbo.GC_BON_COLLECTE,
    ID_OP_SAISIE        int
        constraint FK_GC_DETAIL_BON_COLLECTE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    LANGITUDE           varchar(50),
    LATITUDE            varchar(50),
    FLACONS             varchar(150),
    ACTIF               bit,
    CODE_EXTERNE_DT_BC  int,
    SysStartTime        datetime2
        constraint DF_SysStartGC_DETAIL_BON_COLLECTE default sysutcdatetime()                                  not null,
    SysEndTime          datetime2
        constraint DF_SysEndGC_DETAIL_BON_COLLECTE default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null,
    ID_DET_REG          int
        constraint GC_DETAIL_BON_COLLECTE_GC_DET_BON_REGULARISATION_ID_REGULARISATION_fk
            references dbo.GC_DET_BON_REGULARISATION,
    CODE_DET_BC_EXTERNE int
)
go

create index indexondetbncollecte
    on dbo.GC_DETAIL_BON_COLLECTE (ID_DECISION, ACTIF) include (QUANTITE, ID_BON_COLLECTE)
go

create index INDEX1
    on dbo.GC_DETAIL_BON_COLLECTE (ID_DECISION, ID_BON_COLLECTE, ACTIF) include (QUANTITE)
go

create index INDEXDBCBACLAIT
    on dbo.GC_DETAIL_BON_COLLECTE (ID_BON_COLLECTE) include (ID_DET_BON_COLLECTE, ID_BAC)
go

create table dbo.GC_ECHANTILLON_DT_BON_COLLECTE
(
    ID_ECHANTILLON_DT_BON_COLLECTE bigint identity
        constraint PK_GC_ECHANTILLON_DT_BON_COLLECTE
            primary key,
    REF_ANALYSE                    varchar(50)                                     not null,
    DATE_SAISIE                    datetime
        constraint DF_GC_ECHANTILLON_DT_BON_COLLECTE_DATE_SAISIE default getdate() not null,
    ID_DET_BON_COLLECTE            bigint                                          not null
        constraint FK_GC_ECHANTILLON_DT_BON_COLLECTE_GC_DETAIL_BON_COLLECTE
            references dbo.GC_DETAIL_BON_COLLECTE,
    ID_ANALYSE                     bigint
)
go

create index indexech
    on dbo.GC_ECHANTILLON_DT_BON_COLLECTE (ID_DET_BON_COLLECTE) include (REF_ANALYSE)
go

create index INDEXONGCECHANTILLONDTBONCOLLECTEREFANALYSE
    on dbo.GC_ECHANTILLON_DT_BON_COLLECTE (REF_ANALYSE)
go

create table dbo.GC_QUALITE
(
    ID_QUALITE       int identity
        constraint PK_QUALITE
            primary key nonclustered,
    ID_ECHANTILLON   bigint
        constraint FK_GC_QUALITE_GC_ECHANTILLON_DT_BON_COLLECTE
            references dbo.GC_ECHANTILLON_DT_BON_COLLECTE,
    DATE_SAISIE      datetime
        constraint DF_GC_QUALITE_DATE_SAISIE default getdate(),
    NUM_CUVE         int,
    AC               float,
    PC               float,
    MG               float,
    ALC              varchar(50),
    RDL              float,
    TEMPERATURE      int,
    MP               float,
    OBSERVATION      varchar(254),
    INH              bit,
    VALIDER          bit
        constraint DF__GC_QUALIT__VALID__63EF73BC default 0,
    HEURE_INCUBATION varchar(50),
    NUM_INCUBATION   int,
    HEURE_LECTURE    varchar(50),
    NUM_ECH          int,
    ID_ANALYSE       int,
    ID_DBCOL         int,
    EST              float,
    SIGNE_ALC        varchar(1),
    CELLULE          float,
    CATEG_ANALYSE    int
        constraint DF_Qualite_Categ_Analyse default 1,
    ID_PERIODE       bigint
        constraint FK_GC_QUALITE_GC_PERIODE
            references dbo.GC_PERIODE,
    CODE_QUALITE_EXT int,
    DATE_VALIDATION  datetime,
    OP_VALIDATION    int
        constraint FK__GC_QUALIT__OP_VA__64E397F5
            references dbo.A_UTILISATEUR,
    ACTIF            bit
        constraint DF__GC_QUALIT__ACTIF__5848B6E6 default 1
)
go

create table dbo.GC_PENALITE
(
    ID_PENALITE         bigint identity
        constraint PK_GC_PENALITE
            primary key,
    POURCENTAGE         float,
    ID_PERIODE          bigint
        constraint FK_GC_PENALITE_GC_PERIODE
            references dbo.GC_PERIODE,
    PRIX                float,
    ID_QUALITE          int
        constraint FK_GC_PENALITE_GC_QUALITE
            references dbo.GC_QUALITE,
    ID_UNITE_PRODUCTION int
        constraint FK_GC_PENALITE_P_UNITE_PRODUCTION
            references dbo.P_UNITE_PRODUCTION,
    ID_PRODUCTEUR       int
        constraint FK_GC_PENALITE_P_PRODUCTEUR
            references dbo.P_PRODUCTEUR,
    ID_ADHERENT         int
        constraint FK_GC_PENALITE_P_ADHERENT
            references dbo.P_ADHERENT,
    QTE                 float
)
go

create table dbo.GC_PRIME
(
    ID_PRIME      bigint identity
        constraint PK_GC_PRIME
            primary key,
    ID_TYPE_PRIME int,
    ID_QUALITE    int
        constraint FK_GC_PRIME_GC_QUALITE
            references dbo.GC_QUALITE,
    ID_PERIODE    bigint
        constraint FK_GC_PRIME_GC_PERIODE
            references dbo.GC_PERIODE,
    PRIX          float,
    POURCENTAGE   float
)
go

create index INDEXONGCQUALITEIDECHANTION
    on dbo.GC_QUALITE (ID_ECHANTILLON) include (ID_QUALITE, DATE_SAISIE, NUM_CUVE, AC, PC, MG, ALC, RDL, TEMPERATURE,
                                                MP, OBSERVATION, INH, VALIDER, HEURE_INCUBATION, NUM_INCUBATION,
                                                HEURE_LECTURE, NUM_ECH, ID_ANALYSE, ID_DBCOL, EST, SIGNE_ALC, CELLULE,
                                                CATEG_ANALYSE, ID_PERIODE, CODE_QUALITE_EXT, DATE_VALIDATION,
                                                OP_VALIDATION, ACTIF)
go

create table dbo.GC_RECEPTION
(
    ID_RECEPTION        bigint identity
        constraint PK_GC_RECEPTION
            primary key,
    QUANTITE            float,
    QTTE_DEPOTE         float,
    ECART               bit
        constraint DF_GC_RECEPTION_ANNULER default 0,
    FACTURER            bit
        constraint DF_GC_RECEPTION_FACTURER default 0,
    ID_PERIODE          bigint
        constraint FK_GC_RECEPTION_GC_PERIODE
            references dbo.GC_PERIODE,
    ID_TYPE_RECEPTION   int
        constraint FK_GC_RECEPTION_GC_TYPE_RECEPTION
            references dbo.GC_TYPE_RECEPTION,
    ID_UNITE_PROD       int
        constraint FK_GC_RECEPTION_P_UNITE_PRODUCTION
            references dbo.P_UNITE_PRODUCTION,
    ID_FACTURE          bigint,
    ID_ORDRE_MISSION    bigint
        constraint FK_GC_RECEPTION_T_ORDER_MISSION
            references dbo.T_ORDER_MISSION,
    QTTE_ANNONCEE       float,
    POURCENTAGE         float,
    ECART_DEPOTAGE      float,
    ID_DET_BON_COLLECTE bigint
        constraint FK_GC_RECEPTION_GC_DETAIL_BON_COLLECTE
            references dbo.GC_DETAIL_BON_COLLECTE,
    DATE_HEURE_SAISIE   datetime
        constraint DF_GC_RECEPTION_DATE_HEURE_SAISIE default getdate(),
    OP_SAISIE           int
        constraint FK_GC_RECEPTION_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_CUVE             int,
    NUM_LOT             varchar(30),
    ID_PRODUCTEUR       int
        constraint FK_GC_RECEPTION_P_PRODUCTEUR
            references dbo.P_PRODUCTEUR,
    ID_ADHERENT         int
        constraint FK_GC_RECEPTION_P_ADHERENT
            references dbo.P_ADHERENT,
    NUM_SERIE           varchar(50),
    ID_SITE             int
        constraint FK_GC_RECEPTION_P_SITE
            references dbo.P_SITE,
    ID_ENTREPOT         int
        constraint FK_GC_RECEPTION_P_ENTREPOT
            references dbo.P_ENTREPOT,
    ID_EMPLACEMENT      int
        constraint FK_GC_RECEPTION_P_EMPLACEMENT
            references dbo.P_EMPLACEMENT,
    ID_TOURNEE          int
        references dbo.P_TOURNEE,
    DATE_SITUATION      date,
    NUM_BL              varchar(50),
    NUM_BC              varchar(50),
    ID_ARTICLE          int
        constraint FK_GC_RECEPTION_P_ARTICLE
            references dbo.P_ARTICLE
)
go

create index INDEXTYPERECEP
    on dbo.GC_RECEPTION (ID_TYPE_RECEPTION) include (QUANTITE, ID_PERIODE, ID_UNITE_PROD, ID_PRODUCTEUR, ID_ADHERENT)
go

create index INDEXTYPERECEPADH
    on dbo.GC_RECEPTION (ID_TYPE_RECEPTION, ID_ADHERENT) include (QUANTITE, ID_PERIODE, ID_UNITE_PROD, ID_PRODUCTEUR)
go

create index INDEXRECEPT
    on dbo.GC_RECEPTION (ID_UNITE_PROD) include (QUANTITE, NUM_LOT, ID_PRODUCTEUR, ID_ADHERENT, ID_TOURNEE,
                                                 DATE_SITUATION, NUM_BL)
go

create index INDEXADHERE
    on dbo.GC_RECEPTION (ID_ADHERENT) include (QUANTITE, ID_UNITE_PROD, NUM_LOT, ID_PRODUCTEUR, ID_TOURNEE,
                                               DATE_SITUATION, NUM_BL)
go

create index INDEXUP
    on dbo.GC_RECEPTION (ID_UNITE_PROD) include (QUANTITE, ID_PERIODE, ID_TYPE_RECEPTION, NUM_LOT, ID_PRODUCTEUR,
                                                 ID_ADHERENT, ID_TOURNEE, DATE_SITUATION, NUM_BL)
go

create index indexdomidom
    on dbo.T_DET_MISSION (ID_ORDER_MISSION) include (ID_DET_MISSION)
go

create table dbo.T_DET_MISSION_BL
(
    ID_DET_MISSION_BL     bigint identity
        constraint PK_T_DET_MISSION_BL
            primary key,
    NUM_BL                int not null,
    ID_DET_MISSION        bigint
        constraint FK_T_DET_MISSION_BL_T_DET_MISSION
            references dbo.T_DET_MISSION,
    ID_CATEGORIE_ACTIVITE int
        references dbo.P_CATEGORIE_ACTIVITE
)
go

create index INDEXOMDATESITUATION
    on dbo.T_ORDER_MISSION (DATE_SITUATION) include (ID_ORDER_MISSION, REF_OM, ID_STATUT, QTTE_ANNONCE, QTTE_DEPOTE,
                                                     QTE_ANNONCE_EXPORT)
go

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER VERIF_NETOYAGE
    ON T_ORDER_MISSION
    AFTER INSERT, UPDATE
    AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @DATE_VALIDATION DATETIME;
    DECLARE @DATE_SITUATION DATE;

    SELECT @DATE_VALIDATION = DATE_VALIDATION,
           @DATE_SITUATION = DATE_SITUATION
    FROM (
             SELECT MAX(TOM.ID_ORDER_MISSION) ID_ORDER_MISSION
             FROM T_ORDER_MISSION TOM
             WHERE ID_VEHICULE = (SELECT ID_VEHICULE FROM inserted)
               AND TOM.ACTIF = 1
               AND ID_STATUT = 2
         ) T
             INNER JOIN
         (
             SELECT ID_ORDRE_MISSION,
                    GCN.DATE_VALIDATION,
                    TDM.DATE_SITUATION
             FROM T_ORDER_MISSION TOM
                      INNER JOIN GC_DEPOTAGE GCD ON TOM.ID_ORDER_MISSION = GCD.ID_ORDRE_MISSION
                      INNER JOIN T_DET_MISSION TDM ON TOM.ID_ORDER_MISSION = TDM.ID_ORDER_MISSION
                      LEFT OUTER JOIN GC_NETTOYAGE GCN ON GCN.ID_DEPOTAGE = GCD.ID_DEPOTAGE
         ) B
         ON T.ID_ORDER_MISSION = B.ID_ORDRE_MISSION


    -- Insert statements for trigger here
    IF @DATE_VALIDATION IS NULL
        BEGIN
            ROLLBACK
            DECLARE @MESSAGE_ERROR varchar(128)
            SET @MESSAGE_ERROR =
                        'Le véhicule n''est pas netoyé. Veulliez demander la validation d''opération de nétoyage. ' +
                        CAST(@DATE_SITUATION AS VARCHAR(56))
            RAISERROR (@MESSAGE_ERROR, 16, 1 );
        END


END
go

disable trigger dbo.VERIF_NETOYAGE on dbo.T_ORDER_MISSION
go

create table dbo.T_SCELLE_DET_MISSION
(
    ID_SCELLE_DET_MISSION int identity
        constraint PK_T_SCELLE_DET_MISSION
            primary key,
    NUM_SCELLE            varchar(256) not null,
    ID_DET_MISSION        bigint
        constraint FK_T_SCELLE_DET_MISSION_T_DET_MISSION
            references dbo.T_DET_MISSION
)
go

create table dbo.T_TYPE_AGENT_MISSION
(
    ID_TYPE_AGENT_MISSION int identity
        constraint PK_T_TYPE_AGENT_MISSION
            primary key,
    LIBELLE               varchar(50)
)
go

create table dbo.T_AGENT_MISSION
(
    ID_AGENT_MISSION int identity
        constraint PK_T_AGENT_MISSION
            primary key,
    ID_AGENT         int                                                                                not null,
    ID_ORDER_MISSION bigint
        constraint FK_T_AGENT_MISSION_T_ORDER_MISSION
            references dbo.T_ORDER_MISSION,
    ID_TYPE_AGENT    int
        constraint FK_T_AGENT_MISSION_T_TYPE_AGENT_MISSION
            references dbo.T_TYPE_AGENT_MISSION,
    DATE_VALIDATION  datetime,
    ID_OP_VALIDATION int
        constraint FK_T_AGENT_MISSION_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    SysStartTime     datetime2
        constraint DF_SysStartT_AGENT_MISSION default sysutcdatetime()                                  not null,
    SysEndTime       datetime2
        constraint DF_SysEndT_AGENT_MISSION default CONVERT([datetime2], '9999-12-31 23:59:59.9999999') not null
)
go

create index INDEXONIDORDREMISSION
    on dbo.T_AGENT_MISSION (ID_ORDER_MISSION)
go

create table dbo.T_TYPE_CHARGE_ATELIER
(
    ID_TYPE_CHARGE_ATELIER int identity
        constraint PK_T_TYPE_CHARGE_ATELIER
            primary key,
    TYPE_CHARGE_ATELIER    varchar(50)
)
go

create table dbo.T_CHARGE_ATELIER
(
    ID_CHARGE_ATELIER      int identity
        constraint PK_T_CHARGE_ATELIER
            primary key,
    ID_TYPE_CHARGE_ATELIER int
        constraint FK_T_CHARGE_ATELIER_T_CHARGE_ATELIER
            references dbo.T_TYPE_CHARGE_ATELIER,
    LIBELLE                varchar(128),
    MONTANT                float,
    MOIS_DEB               varchar(2),
    MOIS_FIN               varchar(2),
    ANNES_DEB              varchar(4),
    ANNES_FIN              varchar(4),
    FRAIS_MENSUELLE        float,
    DESCRIPTION            varchar(max),
    ID_OP_SAISIE           int
        constraint FK_T_CHARGE_ATELIER_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_SAISIE            datetime
        constraint DF_T_CHARGE_ATELIER_DATE_SAISIE default getdate(),
    ACTIVE                 int
        constraint DF_T_CHARGE_ATELIER_ACTIVE default 1 not null
)
go

create table dbo.T_TYPE_LEASING
(
    ID_TYPE_LEASING int identity
        constraint PK_TYPE_LEASING
            primary key,
    TYPE_LEASING    varchar(1028) not null
)
go

create table dbo.T_LEASING
(
    ID_LEASING            int identity
        constraint PK_T_Leasing
            primary key,
    OBJET_LEASING         text,
    VO_LEASING            float,
    NBRE_ECHEANCES        int,
    DATE_DEBUT            date,
    DATE_FIN              date,
    DATE_CONTRACT         date,
    ORGANE_LEASING        varchar(50),
    FOURNISSEUR_LEASING   varchar(50),
    ANNUITE_AMORTISSEMENT float,
    NUM_CONTRAT           varchar(15),
    VALEUR_RESIDUELLE     float,
    ID_VEHICULE           int
        constraint FK_T_Leasing_T_Vehicule
            references dbo.P_VEHICULE,
    ID_SEMI               int,
    ID_TYPE_LEASING       int                    not null
        constraint FK_T_Leasing_T_TYPE_LEASING
            references dbo.T_TYPE_LEASING,
    ANNUITE_LEASING       float,
    DATE_SAISIE           datetime
        constraint DF_T_LEASING_DATE_SAISIE default getdate(),
    ID_OP_SAISIE          int
        constraint FK_T_LEASING_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ACTIVE                int
        constraint DF_T_LEASING_ACTIVE default 1 not null
)
go

create table dbo.T_TYPE_PESAGE
(
    ID_TYPE_PESAGE int identity
        constraint PK_T_TYPE_PESAGE
            primary key,
    TYPE_PESAGE    varchar(50)
)
go

create table dbo.T_PESAGES
(
    ID_ORDRE_MISSION bigint not null
        constraint UNIQMISSION
            unique
        constraint FK_T_PESAGES_T_ORDER_MISSION
            references dbo.T_ORDER_MISSION,
    ID_PESAGE        int    not null
        constraint PK_T_PESAGES
            primary key,
    DATE_SAISIE      datetime,
    ID_OP_SAISIE     int
        constraint FK_T_PESAGES_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    ID_TYPE_PESAGE   int
        constraint FK_T_PESAGES_T_TYPE_PESAGE
            references dbo.T_TYPE_PESAGE,
    QTTE_PESEE       real,
    QTTE_TARE        real,
    DATE_PESAGE      datetime,
    DATE_TARE        datetime
)
go

-- =============================================
-- Author:		<Mourad Elberziz>
-- Create date: <20211022>
-- Description:	<Synchro avec la nouvelle table bon de pesage>
-- =============================================
CREATE TRIGGER [dbo].[Trg_Update_T_PESAGE]
    ON [dbo].[T_PESAGES]
    AFTER insert
    AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    UPDATE dbo.T_PESAGES
    SET DATE_PESAGE=DATE_SAISIE,
        DATE_TARE=(SELECT top 1 DATE_SORTIE
                   FROM [10.7.0.20].pesage_copag.DBO.pesee,
                        inserted
                   WHERE num_pesee = inserted.id_pesage),
        QTTE_TARE=(SELECT top 1 tare_vehicule
                   FROM [10.7.0.20].pesage_copag.DBO.pesee,
                        inserted
                   WHERE num_pesee = inserted.id_pesage),
        QTTE_PESEE=(SELECT top 1 poids_net
                    FROM [10.7.0.20].pesage_copag.DBO.pesee,
                         inserted
                    WHERE num_pesee = inserted.id_pesage)
    WHERE ID_PESAGE = (SELECT top 1 NUM_PESEE
                       FROM [10.7.0.20].pesage_copag.DBO.pesee,
                            inserted
                       WHERE num_pesee = inserted.id_pesage)

END
go

create table dbo.T_TYPE_TAXE
(
    ID_TYPE_TAXE int identity
        constraint PK_T_TYPE_TAXE
            primary key,
    TYPE_TAXE    varchar(50)
)
go

create table dbo.T_TAXES
(
    ID_TAXE            int identity
        constraint PK_T_TAXES
            primary key,
    ID_TYPE_TAXE       int
        constraint FK_T_TAXES_T_TYPE_TAXE
            references dbo.T_TYPE_TAXE,
    ID_OP_SAISIE       int
        constraint FK_T_TAXES_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATETIME_SAISIE    datetime
        constraint DF_T_TAXES_DATETIME_SAISIE default getdate(),
    ID_VEHICULE        int
        constraint FK_T_TAXES_P_VEHICULE
            references dbo.P_VEHICULE,
    MONTANT_TAXE       float,
    DATE_PAIEMENT_TAXE date,
    ACTIVE             int
        constraint DF_T_TAXES_ACTIVE default 1 not null
)
go

create table dbo.T_VISITE_TECHNIQUE
(
    ID_VEHICULE    int
        constraint FK_T_VISITE_TECHNIQUE_P_VEHICULE
            references dbo.P_VEHICULE,
    DATE_VISITE    date,
    MONTANT_VISITE float,
    ID_VISITE      int identity
        constraint PK_T_VISITE_TECHNIQUE
            primary key,
    ID_OP_SAISIE   int
        constraint FK_T_VISITE_TECHNIQUE_A_UTILISATEUR
            references dbo.A_UTILISATEUR,
    DATE_SAISIE    datetime
        constraint DF_T_VISITE_TECHNIQUE_DATE_SAISIE default getdate(),
    ACTIVE         int
        constraint DF_T_VISITE_TECHNIQUE_ACTIVE default 1 not null
)
go

create table dbo.VC_ACTION
(
    ID   int identity
        constraint PK_ACTION
            primary key,
    NAME varchar(100) not null
)
go

create table dbo.VC_ACTION_FIELD
(
    ID        int identity
        constraint PK_ACTION_FIELD
            primary key,
    NAME      varchar(100) not null,
    TYPE      varchar(80)  not null,
    ACTION_ID int          not null
        constraint FK_ActionField_ACTION
            references dbo.VC_ACTION
)
go

create table dbo.VC_OPERATOR
(
    ID   int identity
        constraint PK_OPERATOR
            primary key,
    NAME varchar(80) not null
)
go

create table dbo.VC_DETECTED_ACTION
(
    ID          int identity
        constraint PK_DETECTED_ACTION
            primary key,
    PRODUCT     varchar(80)                not null,
    USER_ID     int                        not null,
    SITE_ID     int                        not null,
    DATE_SAISIE datetime default getdate() not null,
    ACTION_ID   int                        not null,
    OPERATOR_ID int                        not null
        constraint FK_DETECTED_ACTION_OPERATOR
            references dbo.VC_OPERATOR
)
go

create table dbo.VC_DETAIL_DETECTED_ACTION
(
    ID                 int identity
        constraint PK_DETAIL_DETECTED_ACTION
            primary key,
    DETAIL_VALUE       varchar(100) not null,
    ACTION_FIELD_ID    int          not null
        constraint FK_VC_DETAIL_DETECTED_ACTION_VC_ACTION_FIELDS
            references dbo.VC_ACTION_FIELD,
    DETECTED_ACTION_ID int          not null
        constraint FK_DETAIL_DETECTED_ACTION_DETECTED_ACTION
            references dbo.VC_DETECTED_ACTION
)
go

create table dbo.V_CARBURANT
(
    MATRICULE_VEHICULE_INTERNE varchar(max),
    MATRICULE_VEHICULE_EXTERNE varchar(max),
    MATRICULE_DEMANDEUR        varchar(max),
    CIN_DEMANDEUR              varchar(max),
    INDEX_KM                   int,
    COMPTEUR_POMPE             int,
    DATE_HEURES_SORTIE         date,
    COMMENTAIRE                varchar(128),
    QTE                        varchar(max)
)
go

create table dbo.sysdiagrams
(
    name         sysname not null,
    principal_id int     not null,
    diagram_id   int identity
        primary key,
    version      int,
    definition   varbinary(max),
    constraint UK_principal_name
        unique (principal_id, name)
)
go

