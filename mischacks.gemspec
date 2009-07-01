# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mischacks}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Johan Kiviniemi"]
  s.date = %q{2009-07-01}
  s.description = %q{Miscellaneous methods that may or may not be useful.  sh:: Safely pass untrusted parameters to sh scripts.  fork_and_check:: Run a block in a forked process and raise an exception if the process returns a non-zero value.  do_and_exit, do_and_exit!:: Run a block. If the block does not run exit!, a successful exec or equivalent, run exit(1) or exit!(1) ourselves. Useful to make sure a forked block either runs a successful exec or dies.  Any exceptions from the block are printed to standard error.  overwrite:: Safely replace a file. Writes to a temporary file and then moves it over the old file.  tempname_for:: Generates an unique temporary path based on a filename. The generated filename resides in the same directory as the original one.  try_n_times:: Retries a block of code until it succeeds or a maximum number of attempts (default 10) is exceeded.  Exception#to_formatted_string:: Returns a string that looks like how Ruby would dump an uncaught exception.  IO#best_datasync:: Tries fdatasync, falling back to fsync, falling back to flush.}
  s.email = ["devel@johan.kiviniemi.name"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["COPYING", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/mischacks.rb", "mischacks.gemspec", "spec/mischacks_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://johan.kiviniemi.name/software/mischacks/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mischacks}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Miscellaneous methods that may or may not be useful}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.1"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.1"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.1"])
  end
end
