#--
# Copyright (c) 2016 SUSE LLC
#
# Author: Duncan Mac-Vicar P. <dmacvicar@suse.de>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
require 'stringio'

module Bicho

  class Attachment
    attr_reader :props

    def initialize(client, xmlrpc_client, props)
      @client = client
      @xmlrpc_client = xmlrpc_client
      @props = props
    end

    # @return [Fixnum] attachment id
    def id
      props['id'].to_i
    end

    # @return [Fixnum] attachment bug id
    def bug_id
      props['bug_id'].to_i
    end

    # @return [String] attachment content type
    def content_type
      props['content_type']
    end

    # @return [Fixnum] attachment size
    def size
      props['size'].to_i
    end

    # @return [String] attachment summary
    def summary
      props['summary']
    end

    # @return [StringIO] attachmentdata
    # This will be loaded lazyly every time called
    def data
      ret = @xmlrpc_client.call('Bug.attachments',
                                attachment_ids: [id], include_fields: ['data'])
      @client.handle_faults(ret)
      StringIO.new(ret['attachments'][id.to_s]['data'])
    end
  end

end
