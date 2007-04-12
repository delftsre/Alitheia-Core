    create table FILE_GROUP (
        ID bigint generated by default as identity (start with 1),
        NAME varchar(255),
        DESCRIPTION varchar(255),
        PROJECT_VERSION_ID bigint not null,
        primary key (ID)
    );

    create table MEASUREMENT (
        ID bigint generated by default as identity (start with 1),
        RESULT varchar(255),
        WHEN_RUN timestamp,
        METRIC_ID bigint not null,
        PROJECT_FILE_ID bigint,
        FILE_GROUP_ID bigint,
        PROJECT_VERSION_ID bigint,
        primary key (ID)
    );

    create table METRIC (
        ID bigint generated by default as identity (start with 1),
        PLUGIN_ID bigint not null,
        METRIC_TYPE_ID bigint not null,
        NAME varchar(255),
        DESCRIPTION varchar(255),
        primary key (ID)
    );

    create table METRIC_TYPE (
        ID bigint generated by default as identity (start with 1),
        TYPE varchar(255),
        primary key (ID)
    );

    create table PLUGIN (
        ID bigint generated by default as identity (start with 1),
        DESCRIPTION varchar(255),
        NAME varchar(255),
        PATH varchar(255),
        EXECUTOR varchar(255),
        EXECUTOR_TYPE varchar(255),
        PARSER varchar(255),
        PARSER_TYPE varchar(255),
        primary key (ID)
    );

    create table PROJECT_FILE (
        ID bigint generated by default as identity (start with 1),
        PROJECT_VERSION_ID bigint not null,
        NAME varchar(255),
        primary key (ID)
    );

    create table PROJECT_VERSION (
        ID bigint generated by default as identity (start with 1),
        STORED_PROJECT_ID bigint not null,
        VERSION varchar(255),
        LOCAL_PATH varchar(255),
        primary key (ID)
    );

    create table STORED_PROJECT (
        ID bigint generated by default as identity (start with 1),
        NAME varchar(255),
        WEB_SITE varchar(255),
        CONTACT_POINT varchar(255),
        REMOTE_PATH varchar(255),
        SVN_URL varchar(255),
        MAIL_PATH varchar(255),
        primary key (ID)
    );

    alter table FILE_GROUP 
        add constraint FKD2AB41DCA11FC705 
        foreign key (PROJECT_VERSION_ID) 
        references PROJECT_VERSION;

    alter table MEASUREMENT 
        add constraint FK14466F9CDB4C67CF 
        foreign key (PROJECT_FILE_ID) 
        references PROJECT_FILE;

    alter table MEASUREMENT 
        add constraint FK14466F9CA5C4F678 
        foreign key (METRIC_ID) 
        references METRIC;

    alter table MEASUREMENT 
        add constraint FK14466F9CA639B923 
        foreign key (FILE_GROUP_ID) 
        references FILE_GROUP;

    alter table MEASUREMENT 
        add constraint FK14466F9CA11FC705 
        foreign key (PROJECT_VERSION_ID) 
        references PROJECT_VERSION;

    alter table METRIC 
        add constraint FK8758E9B06161E398 
        foreign key (PLUGIN_ID) 
        references PLUGIN;

    alter table METRIC 
        add constraint FK8758E9B079678179 
        foreign key (METRIC_TYPE_ID) 
        references METRIC_TYPE;

    alter table PROJECT_FILE 
        add constraint FKC3DC4302A11FC705 
        foreign key (PROJECT_VERSION_ID) 
        references PROJECT_VERSION;

    alter table PROJECT_VERSION 
        add constraint FKC5061D72C0BF9F95 
        foreign key (STORED_PROJECT_ID) 
        references STORED_PROJECT;
