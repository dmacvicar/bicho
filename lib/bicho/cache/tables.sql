CREATE TABLE IF NOT EXISTS bugs_orig (
  id integer,
  alias text,
  assigned_to text,
  component text,
  creation_time text,
  dupe_of integer,
  is_open boolean,
  last_change_time text,
  priority text,
  product text,
  resolution text,
  severity text,
  status text,
  summary text,
  PRIMARY KEY(id)
);
CREATE INDEX IF NOT EXISTS bug_status_idx ON bugs_orig(status);
CREATE INDEX IF NOT EXISTS bug_open_idx ON bugs_orig(is_open);
CREATE INDEX IF NOT EXISTS bug_creation_idx bugs_orig(creation_time);

CREATE TABLE IF NOT EXISTS history_entries (
  id integer,
  bug_id integer,
  [when] text,
  who text,
  PRIMARY KEY(id),
  FOREIGN KEY(bug_id) REFERENCES bugs_orig(id)
);
CREATE INDEX IF NOT EXISTS history_bug_id_idx ON history_entries(bug_id);

CREATE TABLE IF NOT EXISTS changes (
id integer,
history_entry_id integer integer,
field_name text,
removed text,
added text,
attachment_id integer,
PRIMARY KEY(id),
FOREIGN KEY(history_entry_id) REFERENCES history_entries(id)
);

CREATE INDEX IF NOT EXISTS changes_history_idx ON changes(history_entry_id);
CREATE INDEX IF NOT EXISTS changes_field_idx ON changes(field_name);
