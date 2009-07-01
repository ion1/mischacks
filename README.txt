= MiscHacks

* http://johan.kiviniemi.name/software/mischacks/

== DESCRIPTION:

Miscellaneous methods that may or may not be useful.

sh:: Safely pass untrusted parameters to sh scripts.

fork_and_check:: Run a block in a forked process and raise an exception if the
process returns a non-zero value.

do_and_exit, do_and_exit!:: Run a block. If the block does not run exit!, a
successful exec or equivalent, run exit(1) or exit!(1) ourselves. Useful to
make sure a forked block either runs a successful exec or dies.

Any exceptions from the block are printed to standard error.

overwrite:: Safely replace a file. Writes to a temporary file and then moves it
over the old file.

tempname_for:: Generates an unique temporary path based on a filename. The
generated filename resides in the same directory as the original one.

try_n_times:: Retries a block of code until it succeeds or a maximum number of
attempts (default 10) is exceeded.

Exception#to_formatted_string:: Returns a string that looks like how Ruby would
dump an uncaught exception.

IO#best_datasync:: Tries fdatasync, falling back to fsync, falling back to
flush.

== FEATURES/PROBLEMS:

The sh method is only safe if your sh script is safe. If unsure, add double
quotation marks around all variable references ("$1", "$foo", "$@"), and never,
ever use an untrusted variable as a command.

== SYNOPSIS:

  # sh

  MiscHacks.sh %q{
    diff -u "$1" "$2" | tr a-z A-Z >"$output"
  }, '/dev/null', '/etc/motd', :output => 'foo'

  unsafe_str = %q{" 'foo' $(bar) `baz` "}
  MiscHacks.sh 'printf "%s\n" "$1"', unsafe_str

  # fork_and_check

  # These examples raise MiscHacks::ChildError.
  MiscHacks.fork_and_check do exit! 42 end
  MiscHacks.fork_and_check do exec 'sh', '-c', 'exit 42' end
  MiscHacks.fork_and_check do exec 'failure' end

  # Does not raise an error.
  MiscHacks.fork_and_check do exit! 0 end

  # do_and_exit

  # Prints foo if there are no failures. If anything fails, raises an
  # exception.
  MiscHacks.fork_and_check do
    MiscHacks.do_and_exit! do
      exec 'sh', '-c', 'echo foo'
    end
  end

  # overwrite

  MiscHacks.overwrite 'myconfig' do |io|
    io << config.to_yaml
  end

  # tempname_for

  MiscHacks.tempname_for '/foo/bar/baz'  # => '/foo/bar/.baz.klyce3f517qkh9l'

  # try_n_times

  io = MiscHacks.try_n_times do
    File.open path, File::RDWR|File::CREAT|File::EXCL
  end

  # Exception#to_formatted_string

  begin
    # Do something
  rescue => e
    warn e.to_formatted_string
  end

== REQUIREMENTS:

* POSIX sh
* A system that implements fork

== INSTALL:

* sudo gem install ion1-mischacks --source http://gems.github.com/

== LICENSE:

Copyright © 2009 Johan Kiviniemi

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
