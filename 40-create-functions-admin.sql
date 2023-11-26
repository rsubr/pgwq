CREATE OR REPLACE FUNCTION wq_add_queue_worker (
    p_queue  queue_members.queue%TYPE,
    p_worker queue_members.worker%TYPE
) RETURNS BIGINT AS
$$
DECLARE
    new_id queue_members.id%TYPE;
BEGIN
    INSERT INTO queue_members (queue, worker)
    VALUES (p_queue, p_worker)
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$
LANGUAGE plpgsql;


COMMENT ON FUNCTION wq_add_queue_worker(CITEXT, CITEXT) IS
  'Add a worker to a queue wq_add_worker(queue_name CITEXT, worker_name CITEXT)';



CREATE OR REPLACE FUNCTION wq_add_job (
    p_queue  jobs.queue_name%TYPE,
    p_worker jobs.worker%TYPE,
    p_params jobs.params%TYPE
) RETURNS BIGINT AS
$$
DECLARE
    new_id jobs.id%TYPE;
BEGIN
    INSERT INTO jobs (queue_name, name, params)
    VALUES (p_queue, p_name, p_params)
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$
LANGUAGE plpgsql;


COMMENT ON FUNCTION wq_add_job(CITEXT, CITEXT, CITEXT) IS
  'Add a worker to a queue wq_add_job(queue_name CITEXT, job_name CITEXT, params CITEXT)';
