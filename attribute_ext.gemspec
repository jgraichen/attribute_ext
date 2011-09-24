# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "attribute_ext"
  s.version     = "1.2.2"
  s.authors     = ["Jan Graichen"]
  s.email       = ["jan.graichen@altimos.de"]
  s.homepage    = "https://github.com/jgraichen/attribute_ext"
  s.summary     = %q{AttributeExt provides additional access control for rails model attributes.}
  s.description = %q{AttributeExt provides additional access control for rails model attributes.}

  s.rubyforge_project = "attribute_ext"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end