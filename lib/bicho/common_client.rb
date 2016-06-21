#--
# Copyright (c) 2011 SUSE LINUX Products GmbH
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
require 'logger'

# All classes go into this module.
module Bicho
  # This module allows the [Bug] and other
  # classes to offer an ActiveRecord like query
  # API by allowing to set a default [Client]
  # to make operations.
  module CommonClient
    class << self
      attr_writer :common_client
    end

    def self.common_client
      @common_client ||= (raise 'No common client set')
    end

    def common_client
      CommonClient.common_client
    end
  end

  # Sets the common client to be used by
  # the library
  def self.client=(client)
    CommonClient.common_client = client
  end

  # Current client used by the library
  def self.client
    CommonClient.common_client
  end
end
