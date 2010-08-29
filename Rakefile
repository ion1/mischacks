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

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)+'/lib')

require 'rubygems'

require 'rake'
require 'rake/clean'

task :default => :spec

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "mischacks"
    gemspec.summary = "Miscellaneous methods that may or may not be useful"
    gemspec.description = \
      "sh: Safely pass untrusted parameters to sh scripts.  " \
      "overwrite: Safely replace a file.  " \
      "Exception#to_formatted_string: Return a string that looks like how Ruby would dump an uncaught exception.  " \
      "Random: Generate various types of random numbers using SecureRandom.  " \
      "Password: A small wrapper for String#crypt that does secure salt generation and easy password verification."
    gemspec.email = "devel@johan.kiviniemi.name"
    gemspec.homepage = "http://johan.kiviniemi.name/software/mischacks/"
    gemspec.authors = ["Johan Kiviniemi"]
  end

  Jeweler::GemcutterTasks.new

rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

CLOBBER << %w{mischacks.gemspec pkg}

# vim:set et sw=2 sts=2:
