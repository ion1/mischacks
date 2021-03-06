# mischacks – Miscellaneous methods that may or may not be useful
# Copyright © 2010 Johan Kiviniemi
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)+'/../lib')

require 'mischacks'

class Object
  def metaclass
    class << self; self; end
  end
end

module Enumerable
  def mean
    inject(:+) / length.to_f
  end

  def stddev
    Math.sqrt variance
  end

  def variance
    mean_ = mean
    inject(0) {|sum, e| sum + (e - mean_)**2} / length.to_f
  end
end

Spec::Matchers.define :exit_with do |expected|
  match do |block|
    @status = 0

    begin
      MiscHacks.fork_and_check do
        block.call
      end
    rescue MiscHacks::ChildError => e
      @status = e.status
    end

    @status.eql? expected
  end

  failure_message_for_should do |block|
    "expected exit value #{expected}, got #{@status}"
  end

  failure_message_for_should do |block|
    "did not expect exit value #{@status}"
  end
end

# vim:set et sw=2 sts=2:
