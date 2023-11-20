-- Queue members table
CREATE TABLE queue_members (
  id      BIGINT  PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

  queue   CITEXT NOT NULL,
  worker  CITEXT NOT NULL UNIQUE,

  deleted_at TIMESTAMP(0)
);

-- Enable RLS
ALTER TABLE queue_members ENABLE ROW LEVEL SECURITY;

-- Permit wq_admin full access to the table
CREATE POLICY queue_members_admin_all_policy ON queue_members
  TO pgwq
  USING (true) WITH CHECK (true);

-- workers can see only their queues
CREATE POLICY queue_members_policy ON queue_members
  USING (worker = current_user);


-- we rely only on RLS to protect the table
GRANT ALL ON queue_members TO public;
