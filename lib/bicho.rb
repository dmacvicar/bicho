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
require 'rubygems'
require 'logger'
require 'bicho/version'
require 'bicho/logging'
require 'bicho/client'
require 'bicho/bug'

module Bicho

  SEARCH_FIELDS = [
    # name, type, description, multi
    [ :alias, :strings, "The unique alias for this bug", true],
    [ :assigned_to, :strings, "The login name of a user that a bug is assigned to.", true],
    [ :component, :strings, "The name of the Component", true],
    [ :creation_time, :string, "Searches for bugs that were created at this time or later.", false],
    [ :id, :ints, "The numeric id of the bug.", true],
    [ :last_change_time, :string, "Searches for bugs that were modified at this time or later.", false],
    [ :limit, :ints, "Limit the number of results returned to int records.", true],
    [ :offset, :ints, "Used in conjunction with the limit argument, offset defines the starting position for the search.", true],
    [ :op_sys, :strings, "The 'Operating System' field of a bug.", true],
    [ :platform, :strings, "The Platform field of a bug.", true],
    [ :priority, :strings, "The Priority field on a bug.", true],
    [ :product, :strings, "The name of the Product that the bug is in.", true],
    [ :reporter, :strings, "The login name of the user who reported the bug.", true],
    [ :resolution, :strings, "The current resolution--only set if a bug is closed.", true],
    [ :severity, :strings, "The Severity field on a bug.", true],
    [ :status, :strings, "The current status of a bug", true],
    [ :summary, :strings, "Searches for substrings in the single-line Summary field on bugs.", true],
    [ :target_milestone, :strings, "The Target Milestone field of a bug.", true],
    [ :qa_contact, :strings, "The login name of the bug's QA Contact.", true],
    [ :url, :strings, "The 'URL' field of a bug.", true],
    [ :version, :strings, "The Version field of a bug.", true],
    [ :votes, :ints, "Searches for bugs with this many votes or greater", false],
    [ :whiteboard, :strings, "Search the 'Status Whiteboard' field on bugs for a substring.", true]
  ]

end
