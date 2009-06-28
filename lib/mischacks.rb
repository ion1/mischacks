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

module MiscHacks
  VERSION = '0.0.3'

  class ChildError < RuntimeError
    attr_reader :status

    def initialize status
      @status = Integer status
      super "Child failed with status #{status}"
    end
  end

  def self.sh cmd, *args
    env = if args.last.is_a? Hash then args.pop else {} end

    fork_and_check do
      do_and_exit! do
        begin
          env.each_pair do |k, v| ENV[k.to_s] = v.to_s end
          exec *(%W{sh -e -c #{cmd} sh} + args.map {|a| a.to_s })
        rescue Exception => e
          warn e.to_formatted_string
        end
      end
    end

    nil
  end

  def self.fork_and_check
    fork do
      yield
    end.tap do |pid|
      _, status = Process.wait2 pid
      raise ChildError, status.exitstatus if status.exitstatus != 0
    end

    nil
  end

  def self.catching_exit final_proc, fallthrough_status
    status = fallthrough_status

    begin
      yield
    rescue SystemExit => e
      status = e.status
    ensure
      final_proc.call status
    end

    status
  end

  def self.do_and_exit status=1, &block
    catching_exit method(:exit), status, &block
  end

  def self.do_and_exit! status=1, &block
    catching_exit method(:exit!), status, &block
  end

  def self.overwrite path, mode=nil
    begin
      stat = File.stat path

      raise ArgumentError, "Not a file: #{path}",   caller unless stat.file?
      raise ArgumentError, "Not writable: #{path}", caller unless stat.writable?

      mode ||= stat.mode & 0777
    rescue Errno::ENOENT
      stat = nil
    end

    temppath, io = try_n_times do
      t  = tempname_for path
      io = File.open t, File::RDWR|File::CREAT|File::EXCL
      [t, io]
    end

    begin
      ret = yield io

      File.chmod mode, temppath if mode

      File.rename temppath, path

    rescue
      File.unlink temppath
      raise

    ensure
      io.close
    end

    ret
  end

  def self.tempname_for path
    dirname  = File.dirname  path
    basename = File.basename path

    '%s/.%s.%s%s%s' % [
      dirname,
      basename,
      Time.now.to_i.to_s(36),
      $$.to_s(36),
      rand(1<<32).to_s(36)
    ]
  end

  def self.try_n_times n=10
    i = 0
    begin
      ret = yield
    rescue
      i += 1
      retry if i < n
      raise
    end

    ret
  end
end

module MiscHacks
  module ExceptionMixin
    def to_formatted_string
      bt   = backtrace.dup
      head = bt.shift
      (
        ["#{head}: #{self} (#{self.class})"] +
        bt.map do |l| "\tfrom #{l}" end
      ).map do |l| "#{l}\n" end.join
    end
  end
end

Exception.class_eval do
  include MiscHacks::ExceptionMixin
end

# vim:set et sw=2 sts=2:
