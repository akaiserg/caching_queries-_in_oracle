
-- to check parameters 
SELECT
    name,
    value,
    isdefault
FROM
    v$parameter
WHERE
    name LIKE 'result_cache%';
    
-- to see  cache objects 

    SELECT * FROM v$result_cache_objects;
	
--  to delete cache 

alter system flush buffer_cache;	