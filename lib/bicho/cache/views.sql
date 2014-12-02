CREATE VIEW IF NOT EXISTS months AS
  WITH RECURSIVE months_seq(month) AS
     (SELECT datetime('2010-09-01 00:00:00')
        UNION ALL
        SELECT datetime(month, 'start of month','+1 month') FROM months_seq WHERE month <=  datetime('now')
      )
      SELECT month, strftime('%Y-%m', month) AS shortmonth from months_seq;

CREATE VIEW IF NOT EXISTS bugs AS
  SELECT
    b.*,
    (SELECT MIN(h.[when]) FROM history_entries h, changes c
       WHERE h.bug_id=b.id
         AND c.history_entry_id=h.id
         AND c.field_name='status'
         AND (c.added='RESOLVED' OR c.added='VERIFIED')
    ) AS closed_time
  FROM bugs_orig b;

CREATE VIEW IF NOT EXISTS months_open AS
 SELECT m.shortmonth, COUNT(b.id) AS open_count FROM bugs b
    CROSS JOIN months m
    WHERE b.creation_time < datetime(m.month, '+1 month')
      AND
        (b.is_open=1
         OR datetime(m.month, '+1 month') =< b.closed_time)
    GROUP BY m.shortmonth;

CREATE VIEW IF NOT EXISTS months_closed AS
 SELECT m.shortmonth, COUNT(b.id) AS closed_count FROM bugs b
    CROSS JOIN months m
    WHERE b.creation_time < datetime(m.month, '+1 month')
      AND b.closed_time IS NOT NULL
      AND b.closed_time < datetime(m.month, '+1 month')
      AND b.closed_time >= m.month
    GROUP BY m.shortmonth;

CREATE VIEW IF NOT EXISTS months_new AS
 SELECT m.shortmonth, COUNT(b.id) AS new_count FROM bugs b
    CROSS JOIN months m
    WHERE b.creation_time >= m.month
      AND b.creation_time < datetime(m.month, '+1 month')
    GROUP BY m.shortmonth;

CREATE VIEW IF NOT EXISTS months_stat AS
  SELECT o.shortmonth, o.open_count, c.closed_count, n.new_count
  FROM months_open o, months_closed c, months_new n
  WHERE o.shortmonth=c.shortmonth
    AND c.shortmonth=n.shortmonth;

