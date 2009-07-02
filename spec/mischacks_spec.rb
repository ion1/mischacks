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
require 'fileutils'
require 'set'
require 'tmpdir'

mh = MiscHacks
ce = MiscHacks::ChildError

describe mh do
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

  describe 'fork_and_check' do
    it 'should raise an error when child fails' do
      lambda do mh.fork_and_check do exit  1 end end.should raise_error ce
      lambda do mh.fork_and_check do exit! 1 end end.should raise_error ce

      lambda do mh.fork_and_check do exit  0 end end.should_not raise_error
      lambda do mh.fork_and_check do exit! 0 end end.should_not raise_error
    end

    it 'should handle exec' do
      lambda do mh.fork_and_check do exec 'false' end end.should raise_error ce
      lambda do mh.fork_and_check do exec 'true'  end end.should_not raise_error
    end
  end

  describe 'catching_exit' do
    it 'should call final_proc with the fallthrough status when the block does not exit' do
      [0, 1, 42, 255].each do |i|
        foo = nil
        mh.catching_exit(lambda {|status| foo = status }, 2) do end
        foo.should == 2
      end

    end

    it 'should call final_proc with the exit status when the block exits' do
      [0, 1, 42, 255].each do |i|
        foo = nil
        mh.catching_exit(lambda {|status| foo = status }, 2) do exit i end
        foo.should == i
      end
    end
  end

  describe 'do_and_exit' do
    it 'should have the proper exit status when the block does not exit' do
      lambda do
        mh.do_and_exit do end
        exit 2  # Should never reach this.
      end.should exit_with 1

      lambda do
        mh.do_and_exit! do end
        exit! 2  # Should never reach this.
      end.should exit_with 1

      [0, 1, 42, 255].each do |i|
        lambda do
          mh.do_and_exit i do end
          exit 2  # Should never reach this.
        end.should exit_with i
      end

      [0, 1, 42, 255].each do |i|
        lambda do
          mh.do_and_exit! i do end
          exit! 2  # Should never reach this.
        end.should exit_with i
      end
    end

    it 'should have the proper exit status when the block exits' do
      [0, 1, 42, 255].each do |i|
        lambda do
          mh.do_and_exit do exit i end
          exit 2  # Should never reach this.
        end.should exit_with i
      end

      [0, 1, 42, 255].each do |i|
        lambda do
          mh.do_and_exit! do exit! i end
          exit! 2  # Should never reach this.
        end.should exit_with i
      end
    end

    it 'should handle exec' do
      [0, 1, 42, 255].each do |i|
        lambda do
          mh.do_and_exit! do exec *%W{sh -c #{'exit "$1"'} sh #{i}} end
          exit! 2  # Should never reach this.
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
          mh.do_and_exit! do end
        rescue SystemExit => e
          exit 2  # Should never reach this.
        end
      end.should exit_with 1
    end
  end

  describe 'overwrite' do
    before :all do
      @dir      = Dir.mktmpdir
      @file     = "#{@dir}/foo"
      @content0 = "bar\n"
      @content1 = "baz\n"
      @mode0    = 0714
      @mode1    = 0755
    end

    after :all do
      FileUtils.rm_rf @dir
    end

    it 'should create a fresh file' do
      mh.overwrite @file do |io|
        io << @content0
        File.exists?(@file).should == false
      end
      File.read(@file).should == @content0
    end

    it 'should overwrite a file' do
      mh.overwrite @file do |io|
        io << @content1
        File.read(@file).should == @content0
      end
      File.read(@file).should == @content1
    end

    it 'should retain the mode' do
      File.chmod @mode0, @file
      mh.overwrite @file do end
      (File.stat(@file).mode & 07777).should == @mode0
    end

    it 'should set the mode' do
      mh.overwrite @file, @mode1 do end
      (File.stat(@file).mode & 07777).should == @mode1
    end
  end

  describe 'tempname_for' do
    it 'should generate an unique temporary path' do
      path = '/foo/bar/baz'
      tempnames = (0...10).map { mh.tempname_for(path) }.to_set

      # It is very, very unlikely there are duplicates.
      tempnames.length.should > 8

      tempnames.each do |n|
        n.should =~ %r{\A/foo/bar/.baz.[a-z0-9]+\z}
      end
    end
  end

  describe 'try_n_times' do
    it 'should try 10 times' do
      e = Class.new RuntimeError

      i = 0
      mh.try_n_times do
        i += 1
        42
      end.should == 42
      i.should == 1

      i = 0
      mh.try_n_times do
        i += 1
        raise e if i < 10
        42
      end.should == 42
      i.should == 10

      i = 0
      lambda do
        mh.try_n_times do
          i += 1
          raise e if i < 11
          42
        end
      end.should raise_error e
      i.should == 10
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

  describe 'IOMixin best_datasync' do
    before :all do
      @dir     = Dir.mktmpdir
      @file    = "#{@dir}/foo"
      @content = "f"
    end

    after :all do
      FileUtils.rm_rf @dir
    end

    it 'should flush any buffered data to the OS' do
      open @file, 'w' do |io|
        io << @content

        File.read(@file).should == ''

        io.best_datasync

        File.read(@file).should == @content
      end
    end

    sync_meths = [:fdatasync, :fsync, :flush]

    sync_meths.length.times do |i|
      sync_meths_dup = sync_meths.dup

      fails    = sync_meths_dup.shift i
      succeeds = sync_meths_dup.shift
      ignored  = sync_meths_dup

      desc = "should call #{succeeds}"

      if fails.empty?
        desc << " if available"
      else
        desc << " if #{fails.join(', ')} unavailable"
      end

      desc << " (ignoring #{ignored.join(', ')})" unless ignored.empty?

      it desc do
        [NoMethodError, NotImplementedError].each do |error|
          open @file, 'w' do |io|
            fails.each do |meth|
              if error == NoMethodError
                io.metaclass.send :undef_method, meth rescue nil
              else
                io.should_receive(meth).once.ordered.and_raise error
              end
            end

            io.should_receive(succeeds).once.ordered.and_return nil

            ignored.each do |meth|
              io.should_not_receive(meth)
            end

            io.best_datasync
          end
        end
      end
    end

    it "should fail if none of #{sync_meths.join(', ')} are available" do
      [NoMethodError, NotImplementedError].each do |error|
        lambda do
          open @file, 'w' do |io|
            sync_meths.each do |meth|
              if error == NoMethodError
                io.metaclass.send :undef_method, meth rescue nil
              else
                io.should_receive(meth).once.ordered.and_raise error
              end
            end

            io.best_datasync
          end
        end.should raise_error error
      end
    end
  end
end

# vim:set et sw=2 sts=2:
