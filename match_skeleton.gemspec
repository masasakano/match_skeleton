# -*- encoding: utf-8 -*-

require 'rake'

Gem::Specification.new do |s|
  s.name = %q{match_skeleton}.sub(/.*/){|c| (c == File.basename(Dir.pwd)) ? c : raise("ERROR: s.name=(#{c}) in gemspec seems wrong!")}
  s.version = "1.1.0"
  # s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  # s.executables << 'hola'
  # s.bindir = 'bin'
  s.authors = ["Masa Sakano"]
  s.date = %q{2019-10-29}
  s.summary = %q{MatchSkeleton - class equivalent to MatchData with negligible memory use}
  s.description = %q{MatchSkeleton is a class equivalent to MatchData with negligible memory use when the identical strings are matched repeatedly while matched data are kept in the memory.  As long as the original string is not destructively modified, it behaves almost icentical to MatchData.}
  s.email = %q{info@wisebabel.com}
  s.extra_rdoc_files = [
    # "LICENSE",
     #"README.en.rdoc",
     "README.ja.rdoc",
  ]
  s.license = 'MIT'
  s.files = FileList['.gitignore','lib/**/*.rb','[A-Z]*','test/**/*.rb'].to_a.delete_if{ |f|
    ret = false
    arignore = IO.readlines('.gitignore')
    arignore.map{|i| i.chomp}.each do |suffix|
      if File.fnmatch(suffix, File.basename(f))
        ret = true
        break
      end
    end
    ret
  }
  s.files.reject! { |fn| File.symlink? fn }
  # s.add_runtime_dependency 'library', '~> 2.2', '>= 2.2.1'	# 2.2.1 <= Ver < 2.3.0
  # s.add_development_dependency "bourne", [">= 0"]
  s.homepage = %q{https://www.wisebabel.com/}
  s.rdoc_options = ["--charset=UTF-8"]

  # s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.0'
  s.test_files = Dir['test/**/*.rb']
  s.test_files.reject! { |fn| File.symlink? fn }
  # s.requirements << 'libmagick, v6.0'	# Simply, info to users.
  # s.rubygems_version = %q{1.3.5}	# This is always set automatically!!

  s.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.
end

