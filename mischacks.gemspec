# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mischacks}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Johan Kiviniemi"]
  s.date = %q{2009-06-28}
  s.description = %q{Safely pass untrusted parameters to sh scripts}
  s.email = ["devel@johan.kiviniemi.name"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["COPYING", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/mischacks.rb", "mischacks.gemspec", "spec/mischacks_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://johan.kiviniemi.name/software/mischacks/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mischacks}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Safely pass untrusted parameters to sh scripts}

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
