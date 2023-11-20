CREATE OR REPLACE FUNCTION wq_list_running ()
RETURNS SETOF jobs AS
$$
BEGIN
  RETURN QUERY
  SELECT
    *
  FROM
    jobs
  WHERE
    status = 'running';
END;
$$
LANGUAGE plpgsql;

COMMENT ON FUNCTION wq_list_running() IS
  'List running jobs scoped to the current user privileges wp_list_running()';
