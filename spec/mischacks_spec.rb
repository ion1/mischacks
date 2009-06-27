# mischacks – Miscellaneous methods that may or may not be useful
# Copyright © 2009 Johan Kiviniemi
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

require File.expand_path(File.dirname(__FILE__)+'/spec_helper.rb')
require 'mischacks'

require 'digest/sha1'

mh = MiscHacks
ce = MiscHacks::ChildError

describe mh do
  describe 'checking_exit_status' do
    it 'should raise an error when child fails' do
      lambda do mh.checking_exit_status do exit  1 end end.should raise_error ce
      lambda do mh.checking_exit_status do exit! 1 end end.should raise_error ce

      lambda do mh.checking_exit_status do exit  0 end end.should_not raise_error
      lambda do mh.checking_exit_status do exit! 0 end end.should_not raise_error
    end

    it 'should handle exec' do
      lambda do mh.checking_exit_status do exec 'false' end end.should raise_error ce
      lambda do mh.checking_exit_status do exec 'true'  end end.should_not raise_error
    end
  end

  describe 'do_and_exit' do
    it 'should have an exit status of 1 when the block does not exit' do
      lambda do
        mh.do_and_exit do end
        exit 2  # Should never reach this.
      end.should exit_with 1
    end

    it 'should have the proper exit status when the block exits' do
      [0, 1, 42, 255].each do |i|
        lambda do
          mh.do_and_exit do exit i end
          exit 2  # Should never reach this.
        end.should exit_with i
      end
    end

    it 'should handle exec' do
      [0, 1, 42, 255].each do |i|
        lambda do
          mh.do_and_exit do exec *%W{sh -c #{'exit "$1"'} sh #{i}} end
          exit 2  # Should never reach this.
        end.should exit_with i
      end
    end

    it 'should handle exit! and plain exit' do
      lambda do
        begin
          mh.do_and_exit do end
        rescue SystemExit => e
          exit 2
        end
      end.should exit_with 2

      lambda do
        begin
          mh.do_and_exit true do end
        rescue SystemExit => e
          exit 2  # Should never reach this.
        end
      end.should exit_with 1

      lambda do
        begin
          mh.do_and_exit! do end
        rescue SystemExit => e
          exit 2  # Should never reach this.
        end
      end.should exit_with 1
    end
  end

  describe 'sh' do
    unsafe_str = %q{" 'foo' $(bar) `baz` "}
    checksum   = Digest::SHA1.hexdigest unsafe_str

    it "should raise #{ce} on error" do
      good = ['true', '', 'printf ""']
      bad  = ['false', 'exit 2', 'return 2']

      bad.each do |c|
        lambda do mh.sh c end.should raise_error ce
      end

      good.each do |c|
        lambda do mh.sh c end.should_not raise_error
      end
    end

    it 'should call sh with -e' do
      lambda do mh.sh 'false; true' end.should raise_error ce
    end

    it 'should pass normal parameters safely' do
      test = lambda do |str, sha|
        mh.sh %q{
          temp="$(mktemp -t mischacks.XXXXXXXXXX)"
          trap 'rm -f "$temp"' 0 1 2 13 15
          printf "%s" "$1" >"$temp"
          printf "%s *%s\n" "$2" "$temp" | sha1sum -c >/dev/null 2>&1
        }, str, sha
      end

      lambda do test.call unsafe_str, checksum end.should_not raise_error
      lambda do test.call 'foo',      checksum end.should raise_error ce
    end

    it 'should pass environment variables safely' do
      test = lambda do |str, sha|
        mh.sh %q{
          temp="$(mktemp -t mischacks.XXXXXXXXXX)"
          trap 'rm -f "$temp"' 0 1 2 13 15
          printf "%s" "$string" >"$temp"
          printf "%s *%s\n" "$checksum" "$temp" | sha1sum -c >/dev/null 2>&1
        }, :string => str, :checksum => sha
      end

      lambda do test.call unsafe_str, checksum end.should_not raise_error
      lambda do test.call 'foo',      checksum end.should raise_error ce
    end
  end

  describe 'ExceptionMixin to_formatted_string' do
    it 'should return the proper string for an exception' do
      klass = Class.new RuntimeError

      begin
        raise klass, 'foo'

      rescue klass => e
        lines = e.to_formatted_string.split /\n/
        head  = lines.shift

        e_class_re  = Regexp.quote e.class.to_s
        e_msg_re    = Regexp.quote e.to_s
        filename_re = Regexp.quote File.basename(__FILE__)

        head_re = %r{\A.+/#{filename_re}:\d+: #{e_msg_re} \(#{e_class_re}\)\z}
        head.should match head_re

        lines.length.should == caller.length
        lines.zip caller do |a, b|
          a.should == "\tfrom #{b}"
        end
      end
    end
  end
end

# vim:set et sw=2 sts=2:
