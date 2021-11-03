drop user osm cascade;

create user osm identified by "Welcome12----";

GRANT CREATE SESSION TO "OSM";

ALTER USER "OSM" ACCOUNT UNLOCK;

grant resource, connect, dwrole to "OSM";

GRANT UNLIMITED TABLESPACE TO "OSM";

BEGIN
    ORDS.ENABLE_SCHEMA(p_enabled => TRUE,
                       p_schema => 'OSM',
                       p_url_mapping_type => 'BASE_PATH',
                       p_url_mapping_pattern => 'OSM',
                       p_auto_rest_auth => FALSE);
    commit;
END;
/


CREATE TABLE "OSM"."CUSTOMERS" 
(	"CUST_NO" NUMBER NOT NULL ENABLE, 
	"CUST_NAME" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	"CUST_EMAIL" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	"CUST_MOBILE" VARCHAR2(16 BYTE) NOT NULL ENABLE, 
	"CUST_ADDRESS" VARCHAR2(128 BYTE), 
	"CUST_TS" TIMESTAMP (6), 
	"CUST_AGE" NUMBER, 
	"REG_ID" VARCHAR2(8 BYTE), 
	"EDUL_ID" VARCHAR2(8 BYTE), 
	"PROF_ID" VARCHAR2(8 BYTE), 
	 PRIMARY KEY ("CUST_NO")
)
/
CREATE TABLE "OSM"."POLICIES" 
   (	"POL_NO" NUMBER NOT NULL ENABLE, 
	"POL_FROM" DATE NOT NULL ENABLE, 
	"POL_TO" DATE NOT NULL ENABLE, 
	"POL_VALUE" NUMBER(8,2) NOT NULL ENABLE, 
	"POL_SUB_TOTAL" NUMBER(8,2) NOT NULL ENABLE, 
	"PT_CODE" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"DT_CODE" VARCHAR2(8 BYTE), 
	"POL_TOTAL" NUMBER(8,2) NOT NULL ENABLE, 
	"CUST_NO" NUMBER NOT NULL ENABLE, 
	 PRIMARY KEY ("POL_NO")
)
/
CREATE TABLE "OSM"."CLAIMS" 
   (	"CUST_NO" NUMBER NOT NULL ENABLE, 
	"POL_NO" NUMBER NOT NULL ENABLE, 
	"CLM_DATE" DATE, 
	"CLM_AMT" NUMBER(8,2), 
	"CLM_STATUS" VARCHAR2(8 BYTE), 
	 PRIMARY KEY ("CUST_NO", "POL_NO")
)
/
CREATE TABLE "OSM"."CLAIM_STATUS" 
   (	"CLM_STATUS" VARCHAR2(8 BYTE), 
	"CLM_STATUS_DESC" VARCHAR2(128 BYTE), 
	 PRIMARY KEY ("CLM_STATUS")
)
/
CREATE TABLE "OSM"."DISCOUNT_TYPES" 
   (	"DT_CODE" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"DT_DESC" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	"DT_PERC" NUMBER, 
	 PRIMARY KEY ("DT_CODE")
)
/
CREATE TABLE "OSM"."EDU_LEVELS" 
   (	"EDUL_ID" VARCHAR2(8 BYTE), 
	"EDUL_NAME" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("EDUL_ID")
)
/
CREATE TABLE "OSM"."POLICY_TYPES" 
   (	"PT_CODE" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"PT_DESC" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("PT_CODE")
)
/
CREATE TABLE "OSM"."PROFESSIONS" 
   (	"PROF_ID" VARCHAR2(8 BYTE), 
	"PROF_NAME" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("PROF_ID")
)
/
CREATE TABLE "OSM"."RANDOM_DOMAIN" 
   (	"RD_NAME" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("RD_NAME")
)
/
CREATE TABLE "OSM"."RANDOM_FIRST" 
   (	"RF_NAME" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("RF_NAME")
)
/
CREATE TABLE "OSM"."RANDOM_LAST" 
   (	"RL_NAME" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("RL_NAME")
)
/
CREATE TABLE "OSM"."RANDOM_MIDDLE" 
   (	"RM_NAME" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("RM_NAME")
)
/
CREATE TABLE "OSM"."REGIONS" 
   (	"REG_ID" VARCHAR2(8 BYTE), 
	"REG_NAME" VARCHAR2(128 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("REG_ID")
)
/
insert into OSM.DISCOUNT_TYPES values ('SCH','University Student',10)
/
insert into OSM.DISCOUNT_TYPES values ('PS','Public Sector Employee',10)
/
insert into OSM.DISCOUNT_TYPES values ('SW','Social Worker',20)
/
insert into OSM.DISCOUNT_TYPES values ('SN','Specail Need Person',10)
/
commit
/
insert into OSM.EDU_LEVELS values ('HS','High School')
/
insert into OSM.EDU_LEVELS values ('DIP','College Diploma')
/
insert into OSM.EDU_LEVELS values ('UG','Univerity Under Graduate')
/
insert into OSM.EDU_LEVELS values ('MD','Master Degree')
/
insert into OSM.EDU_LEVELS values ('PHD','PhD')
/
insert into OSM.EDU_LEVELS values ('NS','None')
/
commit
/
insert into OSM.POLICY_TYPES values ('CAR','Vechile Insurance')
/
insert into OSM.POLICY_TYPES values ('ENG','Engineering Insurance')
/
insert into OSM.POLICY_TYPES values ('PRO','Propery Insurance')
/
insert into OSM.POLICY_TYPES values ('MED','Medical Insurance')
/
insert into OSM.claim_status values ('O','Open')
/
insert into OSM.claim_status values ('C','Closed')
/
insert into OSM.professions values ('ENG','Engineer')
/
insert into OSM.professions values ('MD','Medical Doctor')
/
insert into OSM.professions values ('UW','Under Writer')
/
insert into OSM.professions values ('IT','Information Technology')
/
insert into OSM.professions values ('JL','Job Less')
/
insert into OSM.professions values ('NRS','Nurse')
/
insert into OSM.professions values ('PLOT','Pilot')
/
insert into OSM.random_domain values ('air')
/
insert into OSM.random_domain values ('gmail')
/
insert into OSM.random_domain values ('hotmail')
/
insert into OSM.random_domain values ('pt')
/
insert into OSM.random_domain values ('yahoo')
/
insert into OSM.random_first values ('Andrew')
/
insert into OSM.random_first values ('David')
/
insert into OSM.random_first values ('Fawzi')
/
insert into OSM.random_first values ('George')
/
insert into OSM.random_first values ('Jan')
/
insert into OSM.random_first values ('Kevin')
/
insert into OSM.random_first values ('Mark')
/
insert into OSM.random_first values ('Philip')
/
insert into OSM.random_first values ('Richard')
/
insert into OSM.random_first values ('Steven')
/
insert into OSM.random_first values ('Thomas')
/
insert into OSM.random_last values ('ALLEN')
/
insert into OSM.random_last values ('Alswaimil')
/
insert into OSM.random_last values ('CLARK')
/
insert into OSM.random_last values ('GARCIAGARCIA')
/
insert into OSM.random_last values ('GREEN	')
/
insert into OSM.random_last values ('HARRIS')
/
insert into OSM.random_last values ('JACKSON	JACKSON	')
/
insert into OSM.random_last values ('MILLER')
/
insert into OSM.random_last values ('TAYLOR')
/
insert into OSM.random_last values ('THOMAS')
/
insert into OSM.random_last values ('WILSON')
/
insert into OSM.random_middle values ('A')
/
insert into OSM.random_middle values ('D')
/
insert into OSM.random_middle values ('J')
/
insert into OSM.random_middle values ('L')
/
insert into OSM.random_middle values ('Q')
/
insert into OSM.random_middle values ('S')
/
insert into OSM.regions values ('EAST','Eastern')
/
insert into OSM.regions values ('CENT','Central')
/
insert into OSM.regions values ('WEST','Western')
/
insert into OSM.regions values ('NORTH','Northern')
/
insert into OSM.regions values ('SOUTH','Southern')
/
commit
/


grant execute on sys.dbms_lock to osm
/


create or replace PROCEDURE osm.SUBMIT_CLAIM
( 
  PCUST_NO IN NUMBER
, PPOL_NO IN NUMBER
) AS
   type clm_status_type$typ is table of varchar2(8) index by binary_integer;
   vclm_status_type clm_status_type$typ;
   cursor c10 is select CLM_STATUS from osm.claim_status;
   vclm_status varchar2(8);
   vclm_cnt    number;
BEGIN
  open c10;
  loop
    fetch c10 into vclm_status;
    exit when c10%notfound;
    vclm_status_type(c10%rowcount) := vclm_status;
  end loop;
  close c10;
  --
  select count(*) into vclm_cnt from osm.claim_status;
  insert into osm.claims values (PCUST_NO, PPOL_NO, sysdate, round(dbms_random.value(1000, 100000)), vclm_status_type(dbms_random.value(1, vclm_cnt)));
  commit;
END SUBMIT_CLAIM;
/
create or replace procedure osm.trans_load (pLoad_Level in number default 10, pStartFrom in number default 1000000) is
   vlast_name varchar2(32);
   vmiddle_name varchar2(32);
   vfirst_name varchar2(32);
   vlast_cnt number;
   vmiddle_cnt number;
   vfirst_cnt number;
   --
   vpt_code varchar2(8);
   vpt_cnt  number;
   --
   vdt_code varchar2(8);
   vdt_cnt  number;
   --
   vreg_id varchar2(8);
   vreg_cnt number;
   --
   vedul_id varchar2(8);
   vedul_cnt number;
   --
   vprof_id varchar2(8);
   vprof_cnt number;
   --
   vclm_status varchar2(8);
   vclm_cnt    number;
   --
   vrd_name varchar2(32);
   vrd_cnt  number;
   --
   type pt_code_type$typ is table of varchar2(8) index by binary_integer;
   vpt_code_type   pt_code_type$typ;
   --
   type dt_code_type$typ is table of varchar2(8) index by binary_integer;
   vdt_code_type   dt_code_type$typ;
   --
   type rd_name_type$typ is table of varchar2(32) index by binary_integer;
   vrd_name_type   rd_name_type$typ;
   --
   type last_name_type$typ is table of varchar2(32) index by binary_integer;
   vlast_name_type   last_name_type$typ;
   --
   type middle_name_type$typ is table of varchar2(32) index by binary_integer;
   vmiddle_name_type   middle_name_type$typ;
   --
   type first_name_type$typ is table of varchar2(32) index by binary_integer;
   vfirst_name_type   first_name_type$typ;
   --
   type reg_id_type$typ is table of varchar2(8) index by binary_integer;
   vreg_id_type reg_id_type$typ;
   --
   type edul_id_type$typ is table of varchar2(8) index by binary_integer;
   vedul_id_type edul_id_type$typ;
   --
   type prof_id_type$typ is table of varchar2(8) index by binary_integer;
   vprof_id_type prof_id_type$typ;
   --
   type clm_status_type$typ is table of varchar2(8) index by binary_integer;
   vclm_status_type clm_status_type$typ;
   --
   cursor c1 is select pt_code from osm.policy_types;
   cursor c2 is select dt_code from osm.discount_types;
   cursor c3 is select rf_name from osm.random_first;
   cursor c4 is select rm_name from osm.random_middle;
   cursor c5 is select rl_name from osm.random_last;
   cursor c6 is select rd_name from osm.random_domain;
   cursor c7 is select reg_id  from osm.regions;
   cursor c8 is select edul_id from osm.edu_levels;
   cursor c9 is select prof_id from osm.professions;
   cursor c10 is select CLM_STATUS from osm.claim_status;
   --
   vcust_seq number;
   vpol_seq  number;
   vpol_value number;
   vj number:=0;
   vk number:=0;
   vz number:=0;
   vfirstname varchar2(128);
   vmiddlename varchar2(128);
   vlastname varchar2(128);
   --
   -- PROCEDURE SUBMIT_CLAIM (PCUST_NO IN NUMBER, PPOL_NO IN NUMBER) AS
   -- BEGIN
      -- insert into claims values (PCUST_NO, PPOL_NO, sysdate, round(dbms_random.value(1000, 100000)), vclm_status_type(dbms_random.value(1, vclm_cnt)));
      -- commit;
   -- END SUBMIT_CLAIM;
begin
  select count(*) into vrd_cnt from osm.random_domain;
  select count(*) into vlast_cnt from osm.random_last;
  select count(*) into vmiddle_cnt from osm.random_middle;
  select count(*) into vfirst_cnt from osm.random_first;
  select count(*) into vpt_cnt from osm.policy_types;
  select count(*) into vdt_cnt from osm.discount_types;
  select count(*) into vreg_cnt from osm.regions;
  select count(*) into vedul_cnt from osm.edu_levels;
  select count(*) into vprof_cnt from osm.professions;
  select count(*) into vclm_cnt  from osm.claim_status;
  --
  for i in 1..pLoad_Level loop
      open c1;
      loop
         fetch c1 into vpt_code;
         exit when c1%notfound;
         vpt_code_type(c1%rowcount) := vpt_code;
      end loop;
      close c1;
      --
      open c2;
      loop
         fetch c2 into vdt_code;
         exit when c2%notfound;
         vdt_code_type(c2%rowcount) := vdt_code;
      end loop;
      close c2;
      --
      open c3;
      loop
         fetch c3 into vfirst_name;
         exit when c3%notfound;
         vfirst_name_type(c3%rowcount) := vfirst_name;
      end loop;
      close c3;
      --
      open c4;
      loop
         fetch c4 into vmiddle_name;
         exit when c4%notfound;
         vmiddle_name_type(c4%rowcount) := vmiddle_name;
      end loop;
      close c4;
      --
      open c5;
      loop
         fetch c5 into vlast_name;
         exit when c5%notfound;
         vlast_name_type(c5%rowcount) := vlast_name;
      end loop;
      close c5;
      --
      open c6;
      loop
         fetch c6 into vrd_name;
         exit when c6%notfound;
         vrd_name_type(c6%rowcount) := vrd_name;
      end loop;
      close c6;
      --
      open c7;
      loop
         fetch c7 into vreg_id;
         exit when c7%notfound;
         vreg_id_type(c7%rowcount) := vreg_id;
      end loop;
      close c7;
      --
      open c8;
      loop
         fetch c8 into vedul_id;
         exit when c8%notfound;
         vedul_id_type(c8%rowcount) := vedul_id;
      end loop;
      close c8;
      --
      open c9;
      loop
         fetch c9 into vprof_id;
         exit when c9%notfound;
         vprof_id_type(c9%rowcount) := vprof_id;
      end loop;
      close c9;
      --
      open c10;
      loop
         fetch c10 into vclm_status;
         exit when c10%notfound;
         vclm_status_type(c10%rowcount) := vclm_status;
      end loop;
      close c10;
      --
      -- dbms_output.put_line(vpt_code_type(dbms_random.value(1, vpt_cnt)));
      -- select cust_seq.nextval into vcust_seq from dual;
      select count(*) into vcust_seq from osm.customers;
      if vcust_seq = 0 then
         vcust_seq := pStartFrom;
      else
         select max(cust_no) into vcust_seq from osm.customers;
         if pStartFrom > vcust_seq then
            vcust_seq := pStartFrom;
         else
            select max(cust_no)+1 into vcust_seq from osm.customers;
         end if;
      end if;
      vfirstname := vfirst_name_type(dbms_random.value(1, vfirst_cnt));
      vmiddlename := vmiddle_name_type(dbms_random.value(1, vmiddle_cnt));
      vlastname := vlast_name_type(dbms_random.value(1, vlast_cnt));
      --
      insert into customers values (vcust_seq, vfirstname||' '||vmiddlename||'. '||vlastname, vfirstname||'.'||vlastname||'@'||vrd_name_type(dbms_random.value(1, vrd_cnt))||'.com', '876-'||trunc(dbms_random.value (1, 4))||trunc(dbms_random.value (1, 4))||trunc(dbms_random.value (1, 4))||trunc(dbms_random.value (1, 4)), null, localtimestamp, round(dbms_random.value(18, 90)), vreg_id_type(dbms_random.value(1, vreg_cnt)),vedul_id_type(dbms_random.value(1, vedul_cnt)), vprof_id_type(dbms_random.value(1, vprof_cnt)));
      --
      commit;
      -- select pol_seq.nextval into vpol_seq from dual;
      select count(*) into vpol_seq from osm.policies;
      if vpol_seq = 0 then
         vpol_seq := vcust_seq+300000000;
      else
         select max(pol_no)+1 into vpol_seq from osm.policies;
      end if;
      vpol_value := dbms_random.value(10000, 500000);
      insert into policies values (vpol_seq, sysdate, sysdate+364, vpol_value, vpol_value*5/100, vpt_code_type(dbms_random.value(1, vpt_cnt)), vdt_code_type(dbms_random.value(1, vdt_cnt)), vpol_value*5/100-vpol_value*5/100*5/100, vcust_seq);
      commit;
      --
      --dbms_output.put_line('J='||j);
      vj:= dbms_random.value(1, 100);
      vk:= dbms_random.value(1, 100);
      vz:= dbms_random.value(1, 200);
       if vj> 50 and vk < 50  and vz > 100 then
         osm.submit_claim(vcust_seq, vpol_seq);
         vj:=0;
         vk:=0;
       end if;
       --
  end loop;
  vj := 0;
  vk := 0;
end;
/
create or replace procedure osm.call_trans_load(n number default 500, s number default 5) is
begin
   --
   for i in 1..n loop
       osm.trans_load;
       --
       if s > 0 then
          sys.dbms_lock.sleep(s);
       end if;
   end loop;
end;
/


ALTER PLUGGABLE DATABASE ADD SUPPLEMENTAL LOG DATA;
