require 'sqlite3'

module Bicho

  # In memory cache for a bug collection
  class Cache

    def initialize
      initialize_database
    end

    # prepares the tables for the cache
    def initialize_database
      #@db = SQLite3::Database.new(':memory:')
      @db = SQLite3::Database.new('test.sqlite')

      @db.execute(%{
        CREATE TABLE IF NOT EXISTS bugs (
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
        );})
      @db.execute(%{
        CREATE INDEX bug_status_idx on bugs(status);
      })
      @db.execute(%{
        CREATE INDEX bug_open_idx on bugs(is_open);
      })

      @db.execute(%{
        CREATE TABLE IF NOT EXISTS history_entries (
          id integer,
          bug_id integer,
          [when] text,
          who text,
          PRIMARY KEY(id),
          FOREIGN KEY(bug_id) REFERENCES bugs(id)
        );})
      @db.execute(%{
        CREATE INDEX history_bug_id_idx on history_entries(bug_id);
      })

      @db.execute(%{
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
      })
      @db.execute(%{
        CREATE INDEX changes_history_idx on changes(history_entry_id);
      })
      @db.execute(%{
        CREATE INDEX changes_field_idx on changes(field_name);
      })

      @bug_stmt = @db.prepare(%{
        INSERT INTO bugs VALUES
          (:id, :alias, :assigned_to, :component, :creation_time, :dupe_of,
           :is_open, :last_change_time, :priority, :product, :resolution,
           :severity, :status, :summary)})
      @changeset_stmt = @db.prepare(
        'INSERT INTO history_entries (bug_id, [when], who) VALUES (?, ?, ?)')
      @change_stmt = @db.prepare(%{
        INSERT INTO changes
          (history_entry_id, field_name, removed, added, attachment_id)
        VALUES (?, ?, ?, ?, ?)})
    end

    # Adds basic bug information to the cache
    def add_bug_basic(bug)
      @bug_stmt.execute(bug.id,  bug.alias || '',
                        bug.assigned_to, bug.component,
                        bug.creation_time
                          .to_time.strftime('%Y-%m-%d %H:%M:%S'),
                        bug.dupe_of,
                        bug.is_open ? 1 : 0,
                        bug.last_change_time
                          .to_time.strftime('%Y-%m-%d %H:%M:%S'),
                        bug.priority,
                        bug.product, bug.resolution,
                        bug.severity, bug.status,
                        bug.summary)
    end

    def add_bug_history(history)
      history.each do |changeset|
        @changeset_stmt.execute(history.bug_id,
                                changeset.timestamp
                                  .strftime('%Y-%m-%d %H:%M:%S'),
                                changeset.who)
        entry_id = @db.last_insert_row_id
        add_changes_to_history_entry(entry_id, changeset)
      end
    end

    def add_changes_to_history_entry(entry_id, changeset)
      changeset.each do |change|
        @change_stmt.execute(
          entry_id, change.field_name, change.removed, change.added,
          change.attachment_id)
      end
    end

  end
end
