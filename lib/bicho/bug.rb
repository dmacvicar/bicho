require 'bicho/query'

module Bicho
  # A single bug inside a bugzilla instance.
  class Bug
    # ActiveRecord like interface
    #
    # @example Searching for bugs
    #     Bug.where(:summary => "crash").each do |bug|
    #       #...do something with bug
    #     end
    #
    # Requires Bicho.client to be set
    #
    # @param [Hash] conds the conditions for the query.
    # alias
    # @option conds [String] The unique alias for this bug.
    # @option conds assigned_to [String] The login name of a user that a bug is assigned to.
    # @option conds component [String] The name of the Component that the bug is in.
    # @option conds creation_time [DateTime] Searches for bugs that were created at this time or later. May not be an array.
    # @option conds creator [String] The login name of the user who created the bug.
    # @option conds id [Integer] The numeric id of the bug.
    # @option conds last_change_time [DateTime] Searches for bugs that were modified at this time or later. May not be an array.
    # @option conds limit [Integer] Limit the number of results returned to int records.
    # @option conds offset [Integer] Used in conjunction with the limit argument, offset defines the starting position for the search. For example, given a search that would return 100 bugs, setting limit to 10 and offset to 10 would return bugs 11 through 20 from the set of 100.
    # @option conds op_sys [String] The "Operating System" field of a bug.
    # @option conds platform [String] The Platform (sometimes called "Hardware") field of a bug.
    # @option conds priority [String] The Priority field on a bug.
    # @option conds product [String] The name of the Product that the bug is in.
    # @option conds creator [String] The login name of the user who reported the bug.
    # @option conds resolution [String] The current resolution--only set if a bug is closed. You can find open bugs by searching for bugs with an empty resolution.
    # @option conds severity [String] The Severity field on a bug.
    # @option conds status [String] The current status of a bug (not including its resolution, if it has one, which is a separate field above).
    # @option conds summary [String] Searches for substrings in the single-line Summary field on bugs. If you specify an array, then bugs whose summaries match any of the passed substrings will be returned.
    # @option conds target_milestone [String] The Target Milestone field of a bug. Note that even if this Bugzilla does not have the Target Milestone field enabled, you can still search for bugs by Target Milestone. However, it is likely that in that case, most bugs will not have a Target Milestone set (it defaults to "---" when the field isn't enabled).
    # @option conds qa_contact [String] The login name of the bug's QA Contact. Note that even if this Bugzilla does not have the QA Contact field enabled, you can still search for bugs by QA Contact (though it is likely that no bug will have a QA Contact set, if the field is disabled).
    # @option conds url [String] The "URL" field of a bug.
    # @option conds version [String] The Version field of a bug.
    # @option conds whiteboard [String] Search the "Status Whiteboard" field on bugs for a substring. Works the same as the summary field described above, but searches the Status Whiteboard field.
    #
    # @return [Array]
    #
    # @see http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html#search bugzilla search API and allowed attributes
    #
    def self.where(conditions = {})
      Query.new(conditions)
    end

    # Normally you will not use this constructor as
    # bugs will be constructed by a query result
    #
    # @param client [Bicho::Client] client where this bug gets its data
    # @param data [Hash] retrieved data for this bug
    def initialize(client, data)
      @client = client
      @data = data
    end

    def method_missing(method_name, *_args)
      return super unless @data.key?(method_name.to_s)
      @data[method_name.to_s]
    end

    def respond_to_missing?(method_name, _include_private = false)
      @data.key?(method_name.to_s) || super
    end

    def id
      # we define id to not get the deprecated
      # warning of object_id
      @data['id']
    end

    def to_s
      "##{id} - #{summary} (#{url})"
    end

    def [](name, subname = nil)
      v = @data[name.to_s]
      v = v[subname.to_s] if subname # for 'internals' properties
      v
    end

    # URL where the bug can be viewed
    # Example: http://bugs.foo.com/2345
    def url
      "#{@client.site_url}/#{id}"
    end

    # @return [History] history for this bug
    def history
      @client.get_history(id).first
    end

    # @return [Array<Attachment>] attachments for this bug
    def attachments
      @client.get_attachments(id)
    end

    # @param format_string For Kernel#sprintf; named params supplied by the bug
    def format(format_string)
      sym_data = Hash[@data.to_a.map { |k, v| [k.to_sym, v] }]
      Kernel.format(format_string, sym_data)
    end
  end
end
