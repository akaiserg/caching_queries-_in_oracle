-- to allow the user   to use dbms_lock:  grant execute on SYS.DBMS_LOCK to <user>;

CREATE OR REPLACE FUNCTION bd_util.make_me_slow( p_seconds in number )
  RETURN number
IS
BEGIN
  dbms_lock.sleep( p_seconds );
  RETURN 1;
END;