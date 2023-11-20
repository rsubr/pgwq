-- Jobs table
CREATE TABLE jobs (
  id         BIGINT  PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  queue_name CITEXT NOT NULL,
          
  -- job name, status and parameters
  name   CITEXT      NOT NULL,
  status status_enum NOT NULL DEFAULT 'new',
  params CITEXT      NOT NULL,
  
  -- worker name, job output and exit status
  worker      CITEXT,
  output      CITEXT,
  exit_status INT,
  
  -- timestaps without milliseconds
  created_at   TIMESTAMP(0) DEFAULT NOW(),
  started_at   TIMESTAMP(0),
  completed_at TIMESTAMP(0),

  -- generated fields to track duration
  waiting_time   INTERVAL GENERATED ALWAYS AS (started_at   - created_at) STORED,
  execution_time INTERVAL GENERATED ALWAYS AS (completed_at - started_at) STORED
);

-- Enable RLS
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Permit wq_admin full access the table
CREATE POLICY jobs_admin_all_policy ON jobs
  TO pgwq
  USING (true) WITH CHECK (true);

-- Workers can see only its own jobs
CREATE POLICY jobs_policy ON jobs
  USING (worker = current_user);

-- Worker can see all new jobs but from member queue only
CREATE POLICY jobs_worker_member_policy ON jobs
  USING (queue_name = (SELECT queue FROM queue_members WHERE worker = current_user) AND
    status = 'new'
  );


-- we rely only on RLS to protect the table
GRANT ALL ON jobs TO public;
