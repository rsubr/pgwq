CREATE OR REPLACE FUNCTION wq_fetch (
  p_latest BOOL DEFAULT FALSE 
) RETURNS TABLE (
  id     BIGINT,
  label  CITEXT,
  params CITEXT
) AS
$$
DECLARE
  worker_r RECORD;
BEGIN
  SELECT
    jobs.id,
    jobs.name,
    jobs.params
  INTO worker_r
  FROM jobs
  WHERE
    status = 'new'
  ORDER BY (CASE WHEN p_latest THEN jobs.created_at END) ASC, jobs.created_at DESC
  LIMIT 1
  FOR UPDATE SKIP LOCKED;

  IF FOUND THEN
    UPDATE jobs
    SET
      status = 'running',
      worker = current_user,
      started_at = NOW()
    WHERE
      jobs.id = worker_r.id;

    RETURN QUERY SELECT worker_r.id, worker_r.name, worker_r.params;
  END IF;
  
  RETURN;
END;
$$
LANGUAGE plpgsql;

COMMENT ON FUNCTION wq_fetch(BOOL) IS
  'Fetch a job from the wq_fetch(latest BOOL DEFAULT false)';



CREATE OR REPLACE FUNCTION wq_completed (
  p_id          BIGINT,
  p_exit_status INT,
  p_output      CITEXT
) RETURNS BIGINT AS
$$
BEGIN

  UPDATE jobs SET
    exit_status = p_exit_status,
    output = p_output,
    completed_at = NOW(),
    status = 'completed'
  WHERE
    id = p_id AND
    status = 'running';
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR: Job not found!';
  END IF;
  
  RETURN p_id;
END;
$$
LANGUAGE plpgsql;

COMMENT ON FUNCTION wq_completed(BIGINT, INT, CITEXT) IS
  'Mark a job as completed in the work queue wq_completed(job_id CITEXT, queue_name CITEXT, worker_name CITEXT, exit_status INT, output CITEXT)';

