create user ADFAPP identified by "Welcome1234#";
ALTER USER ADFAPP QUOTA UNLIMITED ON DATA;

GRANT create session TO ADFAPP;
GRANT create table TO ADFAPP;
GRANT create view TO ADFAPP;
GRANT create sequence TO ADFAPP;
GRANT create trigger TO ADFAPP;
GRANT create procedure TO ADFAPP;
GRANT create VIEW TO ADFAPP;

CREATE TABLE ADFAPP.CALENDAR (
  ID VARCHAR2(32 CHAR) NOT NULL 
, PROVIDER VARCHAR2(128 CHAR) NOT NULL 
, START_DATE DATE NOT NULL 
, END_DATE DATE NOT NULL 
, DESCRIPTION VARCHAR2(256 CHAR) NOT NULL
, RECURRING VARCHAR2(16 CHAR)
, Reminder VARCHAR2(4 CHAR)
, TimeType VARCHAR2(8 CHAR)
, Location VARCHAR2(64 CHAR)
, Tags VARCHAR2(128 CHAR)
);

ALTER TABLE ADFAPP.CALENDAR ADD CONSTRAINT CALENDAR_PK PRIMARY KEY (ID);



insert into ADFAPP.CALENDAR(ID, PROVIDER, START_DATE, END_DATE, Description) VALUES (
    	1000,
    	'John',
    	NEXT_DAY(trunc(sysdate) -7, 'MONDAY') + 1 +  9/24,
    	NEXT_DAY(trunc(sysdate) -7, 'MONDAY') + 1 + 11/24,
    	'Morning Meeting with Board'
    );

insert into ADFAPP.CALENDAR(ID, PROVIDER, START_DATE, END_DATE, Description) VALUES (
    	1001,
    	'Team',
    	NEXT_DAY(trunc(sysdate), 'MONDAY') + 9/24,
    	NEXT_DAY(trunc(sysdate), 'MONDAY') + 17/24,
    	'Security Training'
    );

insert into ADFAPP.CALENDAR(ID, PROVIDER, START_DATE, END_DATE, Description) VALUES (
    	1002,
    	'Team',
    	NEXT_DAY(trunc(sysdate), 'MONDAY') + 1 + 9/24,
    	NEXT_DAY(trunc(sysdate), 'MONDAY') + 1 + 17/24,
    	'Security Training'
    );

insert into ADFAPP.CALENDAR(ID, PROVIDER, START_DATE, END_DATE, Description) VALUES (
    	1003,
    	'Team',
    	NEXT_DAY(trunc(sysdate), 'MONDAY') + 2 + 9/24,
    	NEXT_DAY(trunc(sysdate), 'MONDAY') + 2 + 17/24,
    	'Security Training'
    );

insert into ADFAPP.CALENDAR(ID, PROVIDER, START_DATE, END_DATE, Description, TIMETYPE) VALUES (
    	1004,
    	'John',
    	NEXT_DAY(trunc(sysdate) + 7, 'MONDAY') + 3 ,
    	NEXT_DAY(trunc(sysdate) + 7, 'MONDAY') + 5 ,
    	'Off',
        'ALLDAY'
    );

insert into ADFAPP.CALENDAR(ID, PROVIDER, START_DATE, END_DATE, Description) VALUES (
    	1005,
    	'John',
    	NEXT_DAY(trunc(sysdate) -7, 'MONDAY') + 3 + 10/24,
    	NEXT_DAY(trunc(sysdate) -7, 'MONDAY') + 3 + 12/24,
    	'Meeting with Alex'
    );

insert into ADFAPP.CALENDAR(ID, PROVIDER, START_DATE, END_DATE, Description) VALUES (
    	1006,
    	'John',
    	NEXT_DAY(trunc(sysdate) -7, 'MONDAY') + 3 + 14/24,
    	NEXT_DAY(trunc(sysdate) -7, 'MONDAY') + 3 + 15/24,
    	'Meeting with Simone'
    );