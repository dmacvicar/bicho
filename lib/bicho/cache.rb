require 'sqlite3'

module Bicho

  # In memory cache for a bug collection
  class Cache

    attr_reader :db

    def initialize
      initialize_database
    end

    # prepares the tables for the cache
    def initialize_database
      sql_dir = File.join(File.dirname(__FILE__), 'cache')

      # @db = SQLite3::Database.new(':memory:')
      @db = SQLite3::Database.new('test.sqlite')
      @db.execute_batch(
        File.read(File.expand_path('tables.sql', sql_dir)))

      # add views for metrics
      @db.execute_batch(
        File.read(File.expand_path('views.sql', sql_dir)))

      @bug_stmt = @db.prepare(
        File.read(File.expand_path('insert_bugs.sql', sql_dir)))
      @changeset_stmt = @db.prepare(
        File.read(File.expand_path('insert_history.sql', sql_dir)))
      @change_stmt = @db.prepare(
        File.read(File.expand_path('insert_changes.sql', sql_dir)))
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
