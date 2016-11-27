# Caching queries in Oracle

Oracle   give us  the capability  to   use cache directly   within our queries,  you only need  to use <br> <b>/*+ RESULT_CACHE */</b>

 The import thing is to find the correct part to  put <b>/* + RESULT_CACHE */</b> at. Something the slowness  comes from   subqueries, therefore you  should  use <b>/** + RESULT_CACHE */</b> at the subqueries.
 
First of all let's  check  the oracle  configuration for  the cache.
 
```sql
SELECT
    name,
    value,
    isdefault
FROM
    v$parameter
WHERE
    name LIKE 'result_cache%';
```
 
 The important  one is  <b>RESULT_CACHE_MODE </b> and it should  be <b>MANUAL</b>. The other value can  be FORCE    which means  all the queries will be cached. To  change  this  use:
 

```sql
alter session set result_cache_mode=manual;
```

The other parameters are:

 * RESULT_CACHE_MAX_SIZE: specifies memory allocated for result cache.
 * RESULT_CACHE_MAX_RESULT: specifies maximum cache memory for a single result.
 * RESULT_CACHE_REMOTE_EXPIRATION: sets expiry time for cached results depending on remote database.


Let's  create  some  tables and a function:

```sql
create table t1 as select rownum as id, dbms_random.value(0,10) N1, dbms_random.value(0,20) N2 , dbms_random.string('U',20) N3  from dual connect by level < 800000;
create table t2 as select rownum as id, dbms_random.value(0,10) N1, dbms_random.value(0,30) N2 , dbms_random.string('U',20) N3  from dual connect by level < 700000;
create table t3 as select rownum as id, dbms_random.value(0,10) N1, dbms_random.value(0,40) N2  , dbms_random.string('U',20) N3  from dual connect by level < 500000;

```

```sql 
CREATE OR REPLACE FUNCTION bd_util.make_me_slow( p_seconds in number )
  RETURN number
IS
BEGIN
  dbms_lock.sleep( p_seconds );
  RETURN 1;
END;

```
To allow the user   to use dbms_lock:	

```sql
grant execute on SYS.DBMS_LOCK to <user>;
```

Now  a  query with RESULT_CACHE:

```sql
select /*+ RESULT_CACHE */ 
t1.id,
sum(t1.n1+t_t2.n1),
sum(t1.n2+t_t2.n2),
t1.n3||'-----'|| t_t2.n3
 from bd_util.t1 left join  (
select  t2.* from bd_util.t2 left join bd_util.t3 on (
t2.n3= t3.n3
)
where  t2.N3 like '%A%'
and t2.id <1000
union all 
select 0 id , bd_util.make_me_slow(3) n1 ,2  n2 ,'sass'n3  from dual
) t_t2  on (t1.id= t_t2.id)
where  t1.N3 like '%AB%'
group by t1.id,
t1.n3, t_t2.n3
having t1.id < 1000

```

So if you run this query nothing will be cached, you can check this out by   running  this:

```sql
SELECT * FROM v$result_cache_objects ;
```

Let's cache the  query that uses  the slow function:

So if you run this query nothing will be cached, yo can check this out by   running  this:
```sql
select 
t1.id,
sum(t1.n1+t_t2.n1),
sum(t1.n2+t_t2.n2),
t1.n3||'-----'|| t_t2.n3
 from bd_util.t1 left join  (
select  t2.* from bd_util.t2 left join bd_util.t3 on (
t2.n3= t3.n3
)
where  t2.N3 like '%A%'
and t2.id <1000
union all 
select/*+ RESULT_CACHE */ 0 id , bd_util.make_me_slow(3) n1 ,2  n2 ,'sass'n3  from dual
) t_t2  on (t1.id= t_t2.id)
where  t1.N3 like '%AB%'
group by t1.id,
t1.n3, t_t2.n3
having t1.id < 1000
```

After running the query  the subquery will be cached and  if you  run the query again  it will be faster.

to delte   the cache  run this command:

```sql
exec dbms_result_cache.flush
```

### more:

 * [Result cache](http://dbaora.com/sql-result-cache-11g/)
 
