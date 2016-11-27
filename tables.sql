create table t1 as select rownum as id, dbms_random.value(0,10) N1, dbms_random.value(0,20) N2 , dbms_random.string('U',20) N3  from dual connect by level < 800000;
create table t2 as select rownum as id, dbms_random.value(0,10) N1, dbms_random.value(0,30) N2 , dbms_random.string('U',20) N3  from dual connect by level < 700000;
create table t3 as select rownum as id, dbms_random.value(0,10) N1, dbms_random.value(0,40) N2  , dbms_random.string('U',20) N3  from dual connect by level < 500000;
