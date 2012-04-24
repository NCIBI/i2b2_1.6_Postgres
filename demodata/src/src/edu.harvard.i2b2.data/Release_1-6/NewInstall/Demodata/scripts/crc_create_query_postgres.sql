--==============================================================
-- Database Script to create CRC query tables                   
--                                                            
-- This script will create tables, indexes and sequences. 	    
-- User should have permission to create VARRAY type            										                       
--==============================================================


--------------------------------------------------------
--SEQUENCE CREATION
--------------------------------------------------------

--QUERY MASTER SEQUENCE
CREATE SEQUENCE QT_SQ_QM_QMID START WITH 1
;

--QUERY RESULT 
CREATE SEQUENCE QT_SQ_QR_QRID START WITH 1
;

CREATE SEQUENCE QT_SQ_QS_QSID START WITH 1
;

--QUERY INSTANCE SEQUENCE
CREATE SEQUENCE QT_SQ_QI_QIID START WITH 1
;

--QUERY RESULT INSTANCE ID
CREATE SEQUENCE QT_SQ_QRI_QRIID START WITH 1
;

--QUERY PATIENT SET RESULT COLLECTION ID
CREATE SEQUENCE QT_SQ_QPR_PCID START WITH 1
;

--QUERY PATIENT ENCOUNTER SET RESULT COLLECTION ID
CREATE SEQUENCE QT_SQ_QPER_PECID START WITH 1
;

--QUERY XML RESULT INSTANCE ID
CREATE SEQUENCE QT_SQ_QXR_XRID START WITH 1
;

--QUERY PDO MASTER SEQUENCE
CREATE SEQUENCE QT_SQ_PQM_QMID START WITH 1
;


--===========================================================================
-- Table: QT_QUERY_MASTER 											          
--============================================================================
CREATE TABLE QT_QUERY_MASTER (
	QUERY_MASTER_ID		NUMERIC(5,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_QM_QMID'),
	NAME				VARCHAR(250) NOT NULL,
	USER_ID				VARCHAR(50) NOT NULL,
	GROUP_ID			VARCHAR(50) NOT NULL,
	MASTER_TYPE_CD		VARCHAR(2000),
	PLUGIN_ID			NUMERIC(10,0),
	CREATE_DATE			TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	DELETE_DATE			TIMESTAMP WITHOUT TIME ZONE,
	DELETE_FLAG			VARCHAR(3),
	GENERATED_SQL		TEXT,
	REQUEST_XML			TEXT,
	I2B2_REQUEST_XML	TEXT
)
;
CREATE INDEX QT_IDX_QM_UGID ON QT_QUERY_MASTER(USER_ID,GROUP_ID,MASTER_TYPE_CD)
;


--============================================================================
-- Table: QT_QUERY_RESULT_TYPE										          
--============================================================================
CREATE TABLE QT_QUERY_RESULT_TYPE (
	RESULT_TYPE_ID				NUMERIC(3,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_QR_QRID'),
	NAME						VARCHAR(100),
	DESCRIPTION					VARCHAR(200),
	DISPLAY_TYPE_ID				VARCHAR(500),
	VISUAL_ATTRIBUTE_TYPE_ID	VARCHAR(3)	
)
;


--============================================================================
-- Table: QT_QUERY_STATUS_TYPE										          
--============================================================================
CREATE TABLE QT_QUERY_STATUS_TYPE (
	STATUS_TYPE_ID	NUMERIC(3,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_QS_QSID'),
	NAME			VARCHAR(100),
	DESCRIPTION		VARCHAR(200)
)
;


--============================================================================
-- Table: QT_QUERY_INSTANCE 										          
--============================================================================
CREATE TABLE QT_QUERY_INSTANCE (
	QUERY_INSTANCE_ID	NUMERIC(5,0) PRIMARY KEY  DEFAULT NEXTVAL('QT_SQ_QI_QIID'),
	QUERY_MASTER_ID		NUMERIC(5,0),
	USER_ID				VARCHAR(50) NOT NULL,
	GROUP_ID			VARCHAR(50) NOT NULL,
	BATCH_MODE			VARCHAR(50),
	START_DATE			TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	END_DATE			TIMESTAMP WITHOUT TIME ZONE,
	DELETE_FLAG			VARCHAR(3),
	STATUS_TYPE_ID		NUMERIC(5,0),
	MESSAGE				TEXT,
	CONSTRAINT QT_FK_QI_MID FOREIGN KEY (QUERY_MASTER_ID)
		REFERENCES QT_QUERY_MASTER (QUERY_MASTER_ID),
	CONSTRAINT QT_FK_QI_STID FOREIGN KEY (STATUS_TYPE_ID)
		REFERENCES QT_QUERY_STATUS_TYPE (STATUS_TYPE_ID)
)
;
CREATE INDEX QT_IDX_QI_UGID ON QT_QUERY_INSTANCE(USER_ID,GROUP_ID)
;
CREATE INDEX QT_IDX_QI_MSTARTID ON QT_QUERY_INSTANCE(QUERY_MASTER_ID,START_DATE)
;


--=============================================================================
-- Table: QT_QUERY_RESULT_INSTANCE   								        
--============================================================================
CREATE TABLE QT_QUERY_RESULT_INSTANCE (
	RESULT_INSTANCE_ID	NUMERIC(5,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_QRI_QRIID'),
	QUERY_INSTANCE_ID	NUMERIC(5,0),
	RESULT_TYPE_ID		NUMERIC(3,0) NOT NULL,
	SET_SIZE			NUMERIC(10,0),
	START_DATE			TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	END_DATE			TIMESTAMP WITHOUT TIME ZONE,
	DELETE_FLAG			VARCHAR(3),
	STATUS_TYPE_ID		NUMERIC(3,0) NOT NULL,
	MESSAGE				TEXT,
	DESCRIPTION			VARCHAR(200),
	REAL_SET_SIZE		NUMERIC(10,0),
	OBFUSC_METHOD		VARCHAR(500),
	CONSTRAINT QT_FK_QRI_RID FOREIGN KEY (QUERY_INSTANCE_ID)
		REFERENCES QT_QUERY_INSTANCE (QUERY_INSTANCE_ID),
	CONSTRAINT QT_FK_QRI_RTID FOREIGN KEY (RESULT_TYPE_ID)
		REFERENCES QT_QUERY_RESULT_TYPE (RESULT_TYPE_ID),
	CONSTRAINT QT_FK_QRI_STID FOREIGN KEY (STATUS_TYPE_ID)
		REFERENCES QT_QUERY_STATUS_TYPE (STATUS_TYPE_ID)
)
;


--============================================================================
-- Table: QT_PATIENT_SET_COLLECTION									         
--============================================================================
CREATE TABLE QT_PATIENT_SET_COLLECTION ( 
	PATIENT_SET_COLL_ID		NUMERIC(10,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_QPR_PCID'),
	RESULT_INSTANCE_ID		NUMERIC(5,0),
	SET_INDEX				NUMERIC(10,0),
	PATIENT_NUM				NUMERIC(10,0),
	CONSTRAINT QT_FK_PSC_RI FOREIGN KEY (RESULT_INSTANCE_ID)
		REFERENCES QT_QUERY_RESULT_INSTANCE (RESULT_INSTANCE_ID)
)
;

CREATE INDEX QT_IDX_QPSC_RIID ON QT_PATIENT_SET_COLLECTION(RESULT_INSTANCE_ID)
;


--============================================================================
-- Table: QT_PATIENT_ENC_COLLECTION									         
--============================================================================
CREATE TABLE QT_PATIENT_ENC_COLLECTION (
	PATIENT_ENC_COLL_ID		NUMERIC(10,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_QPER_PECID'),
	RESULT_INSTANCE_ID		NUMERIC(5,0),
	SET_INDEX				NUMERIC(10,0),
	PATIENT_NUM				NUMERIC(10,0),
	ENCOUNTER_NUM			NUMERIC(10,0),
	CONSTRAINT QT_FK_PESC_RI FOREIGN KEY (RESULT_INSTANCE_ID)
		REFERENCES QT_QUERY_RESULT_INSTANCE(RESULT_INSTANCE_ID)
)
;


--============================================================================
-- Table: QT_XML_RESULT												          
--============================================================================
CREATE TABLE QT_XML_RESULT (
	XML_RESULT_ID		NUMERIC(5,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_QXR_XRID'),
	RESULT_INSTANCE_ID	NUMERIC(5,0),
	XML_VALUE			VARCHAR(4000),
	CONSTRAINT QT_FK_XMLR_RIID FOREIGN KEY (RESULT_INSTANCE_ID)
		REFERENCES QT_QUERY_RESULT_INSTANCE (RESULT_INSTANCE_ID)
)
;


--============================================================================
-- Table: QT_ANALYSIS_PLUGIN												          
--============================================================================
CREATE TABLE QT_ANALYSIS_PLUGIN (
	PLUGIN_ID			NUMERIC(10,0) NOT NULL,
	PLUGIN_NAME			VARCHAR(2000),
	DESCRIPTION			VARCHAR(2000),
	VERSION_CD			VARCHAR(50),			--support for version
	PARAMETER_INFO		TEXT,					-- plugin parameter stored as xml
	PARAMETER_INFO_XSD	VARCHAR(2000),
	COMMAND_LINE		VARCHAR(2000),
	WORKING_FOLDER		VARCHAR(2000),
	COMMANDOPTION_CD	VARCHAR(2000),
	PLUGIN_ICON			VARCHAR(2000),
	STATUS_CD			VARCHAR(50),			-- active,deleted,..
	USER_ID				VARCHAR(50),
	GROUP_ID			VARCHAR(50),
	CREATE_DATE			TIMESTAMP WITHOUT TIME ZONE,
	UPDATE_DATE			TIMESTAMP WITHOUT TIME ZONE,
	CONSTRAINT ANALYSIS_PLUGIN_PK PRIMARY KEY(PLUGIN_ID)
)
;
CREATE INDEX QT_APNAMEVERGRP_IDX ON QT_ANALYSIS_PLUGIN(PLUGIN_NAME,VERSION_CD,GROUP_ID)
;


--============================================================================
-- Table: QT_ANALYSIS_PLUGIN_RESULT_TYPE											          
--============================================================================
CREATE TABLE QT_ANALYSIS_PLUGIN_RESULT_TYPE (
	PLUGIN_ID		NUMERIC(10,0),
	RESULT_TYPE_ID	NUMERIC(10,0),
	CONSTRAINT ANALYSIS_PLUGIN_RESULT_PK PRIMARY KEY(PLUGIN_ID,RESULT_TYPE_ID)
)
;


--============================================================================
-- Table: QT_PDO_QUERY_MASTER											          
--============================================================================
CREATE TABLE QT_PDO_QUERY_MASTER (
	QUERY_MASTER_ID		NUMERIC(5,0) PRIMARY KEY DEFAULT NEXTVAL('QT_SQ_PQM_QMID'),
	USER_ID				VARCHAR(50) NOT NULL,
	GROUP_ID			VARCHAR(50) NOT NULL,
	CREATE_DATE			TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	REQUEST_XML			TEXT,
	I2B2_REQUEST_XML	TEXT
)
;
CREATE INDEX QT_IDX_PQM_UGID ON QT_PDO_QUERY_MASTER(USER_ID,GROUP_ID)
;


--============================================================================
-- Table: QT_PRIVILEGE											          
--============================================================================
CREATE TABLE QT_PRIVILEGE (
	PROTECTION_LABEL_CD		VARCHAR(1500),
	DATAPROT_CD				VARCHAR(1000),
	HIVEMGMT_CD				VARCHAR(1000),
	PLUGIN_ID				NUMERIC(10,0)
)
;


--============================================================================
-- Table: QT_BREAKDOWN_PATH											          
--============================================================================
CREATE TABLE QT_BREAKDOWN_PATH ( 
	NAME			VARCHAR(100),
	VALUE			VARCHAR(2000),
	CREATE_DATE		TIMESTAMP WITHOUT TIME ZONE,
	UPDATE_DATE		TIMESTAMP WITHOUT TIME ZONE,
	USER_ID			VARCHAR(50)
)
;


--============================================================================
-- CREATE GLOBALS -- Created the following tables at runtime because POSTGRES 
-- temporaray tables are automatically dropped at the end of a session.
--============================================================================

--------------------------------------------------------
--INIT WITH SEED DATA
--------------------------------------------------------
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(1,'QUEUED',' WAITING IN QUEUE TO START PROCESS')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(2,'PROCESSING','PROCESSING')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(3,'FINISHED','FINISHED')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(4,'ERROR','ERROR')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(5,'INCOMPLETE','INCOMPLETE')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(6,'COMPLETED','COMPLETED')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(7,'MEDIUM_QUEUE','MEDIUM QUEUE')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(8,'LARGE_QUEUE','LARGE QUEUE')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(9,'CANCELLED','CANCELLED')
;
insert into QT_QUERY_STATUS_TYPE(STATUS_TYPE_ID,NAME,DESCRIPTION) values(10,'TIMEDOUT','TIMEDOUT')
;


insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(1,'PATIENTSET','Patient set','LIST','LA')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(2,'PATIENT_ENCOUNTER_SET','Encounter set','LIST','LA')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(3,'XML','Generic query result','CATNUM','LH')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(4,'PATIENT_COUNT_XML','Number of patients','CATNUM','LA')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(5,'PATIENT_GENDER_COUNT_XML','Gender patient breakdown','CATNUM','LA')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(6,'PATIENT_VITALSTATUS_COUNT_XML','Vital Status patient breakdown','CATNUM','LA')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(7,'PATIENT_RACE_COUNT_XML','Race patient breakdown','CATNUM','LA')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(8,'PATIENT_AGE_COUNT_XML','Age patient breakdown','CATNUM','LA')
;
insert into QT_QUERY_RESULT_TYPE(RESULT_TYPE_ID,NAME,DESCRIPTION,DISPLAY_TYPE_ID,VISUAL_ATTRIBUTE_TYPE_ID) values(9,'PATIENTSET','Timeline','LIST','LA')
;


insert into QT_PRIVILEGE(PROTECTION_LABEL_CD, DATAPROT_CD, HIVEMGMT_CD) values ('PDO_WITHOUT_BLOB','DATA_LDS','USER')
;
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD, DATAPROT_CD, HIVEMGMT_CD) values ('PDO_WITH_BLOB','DATA_DEID','USER')
;
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD, DATAPROT_CD, HIVEMGMT_CD) values ('SETFINDER_QRY_WITH_DATAOBFSC','DATA_OBFSC','USER')
;
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD, DATAPROT_CD, HIVEMGMT_CD) values ('SETFINDER_QRY_WITHOUT_DATAOBFSC','DATA_AGG','USER')
;
insert into QT_PRIVILEGE(PROTECTION_LABEL_CD, DATAPROT_CD, HIVEMGMT_CD) values ('UPLOAD','DATA_OBFSC','MANAGER')
;


insert into QT_BREAKDOWN_PATH(NAME,VALUE,CREATE_DATE) values ('PATIENT_GENDER_COUNT_XML',E'\\\\i2b2_DEMO\\i2b2\\Demographics\\Gender\\',now())
;
insert into QT_BREAKDOWN_PATH(NAME,VALUE,CREATE_DATE) values ('PATIENT_RACE_COUNT_XML',E'\\\\i2b2_DEMO\\i2b2\\Demographics\\Race\\',now())
;
insert into QT_BREAKDOWN_PATH(NAME,VALUE,CREATE_DATE) values ('PATIENT_VITALSTATUS_COUNT_XML',E'\\\\i2b2_DEMO\\i2b2\\Demographics\\Vital Status\\',now())
;
insert into QT_BREAKDOWN_PATH(NAME,VALUE,CREATE_DATE) values ('PATIENT_AGE_COUNT_XML',E'\\\\i2b2_DEMO\\i2b2\\Demographics\\Age\\',now())
;


--------------------------------------------------------
-- ARRAY TYPE FOR PDO QUERY
--------------------------------------------------------
--CREATE OR REPLACE TYPE QT_PDO_QRY_INT_ARRAY AS varray(100000) of  NUMERIC(20); 

--CREATE OR REPLACE TYPE QT_PDO_QRY_STRING_ARRAY AS varray(100000) of  VARCHAR(150);



















