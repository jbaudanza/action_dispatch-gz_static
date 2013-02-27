# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "action_dispatch-gz_static"
  gem.version       = '0.0.1'
  gem.authors       = ["Jonathan Baudanza"]
  gem.email         = ["jon@jonb.org"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.add_dependency('actionpack', '>= 3.1.0', '< 4')
  gem.add_dependency('railties', '>= 3.1.0', '< 4')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
