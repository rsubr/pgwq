# Postgres Worker Queue

A worker queue implementation for Postgres.
## Usage

### Install `pgwq` into a new DB
```bash
echo 'CREATE DATABASE IF NOT EXISTS pgwq' | psql -U pgwq -h localhos pgwq
cat *.sql | psql -U pgwq -h localhost pgwq
```

### Setup workers, queues and assign workers to queues
```sql
-- Creating queues and assigning
-- psql -U pgwq -h localhost pgwq

-- create some workers
CREATE USER w1 WITH PASSWORD 'w1';
CREATE USER w2 WITH PASSWORD 'w2';
CREATE USER x1 WITH PASSWORD 'x1';
CREATE USER x2 WITH PASSWORD 'x2';

-- Add some queues assign members

SELECT * FROM wq_add_queue_worker('q1', 'w1');
SELECT * FROM wq_add_queue_worker('q1', 'w2');
SELECT * FROM wq_add_queue_worker('q2', 'x1');
SELECT * FROM wq_add_queue_worker('q2', 'x1');
```

### Add jobs to the queue
```sql
-- psql -U pgwq -h localhost pgwq
-- Add some tasks to the queue
SELECT * FROM wq_add('q1', 'Download Google', 'https://www.google.com');
SELECT * FROM wq_add('q1', 'Download MSN',    'https://www.microsoft.com');

SELECT * FROM wq_add('q2', 'Validate Google', 'https://www.google.com');
SELECT * FROM wq_add('q3', 'Validate MSN',    'https://www.microsoft.com');
```

### Worker `w1` fetch oldest job from queue
```sql
-- psql -U w1 -h localhost pgwq

-- Fetch the oldest job from the queue
SELECT * FROM wq_fetch();

-- Save job completion status
SELECT * FROM wq_completed(1, 0, 'Download success!');
```

### Worker `x1` get latest job from queue
```sql
-- psql -U x1 -h localhost pgwq
SELECT * FROM wq_fetch(true);
```

### Fetch task status
```sql
-- psql -U pgwq -h localhost pgwq
SELECT * FROM wq_list_running() ORDER BY started_at;

```
