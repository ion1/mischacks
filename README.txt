= MiscHacks

* http://johan.kiviniemi.name/software/mischacks/

== DESCRIPTION:

sh::        Safely pass untrusted parameters to sh scripts.
overwrite:: Safely replace a file.

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

  # overwrite

  MiscHacks.overwrite 'myconfig' do |io|
    io << config.to_yaml
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
