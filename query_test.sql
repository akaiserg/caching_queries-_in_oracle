select 
t1.id,
sum(t1.n1+t_t2.n1),
sum(t1.n2+t_t2.n2),
t1.n3||'-----'|| t_t2.n3
 from t1 left join  (

select  t2.* from t2 left join t3 on (
t2.n3= t3.n3
)

where  t2.N3 like '%A%'
and t2.id <1000

union all 

select/*+ RESULT_CACHE */ 0 id , make_me_slow(3) n1 ,2  n2 ,'sass'n3  from dual


) t_t2  on (t1.id= t_t2.id)

where  t1.N3 like '%AB%'

group by t1.id,
t1.n3, t_t2.n3

having t1.id < 1000

