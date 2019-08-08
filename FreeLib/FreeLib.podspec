
Pod::Spec.new do |spec|

  spec.name          = "FreeLib"
  spec.version       = "1.0.0"
  spec.summary       = "FreeLib is an example lib."
  spec.description   = "This is a trial example lib, made to test process of making a library"
  spec.homepage      = "https://github.com/rodrigocasillas/FreeLib"
  spec.license       = "MIT"
  spec.author        = { "Rodrigo Casillas" => "rodrigocasillas@live.com" }
  spec.platform      = :ios, "12.2"
  spec.source        = { :git => "https://github.com/rodrigocasillas/FreeLib.git", :tag => "1.0.0" }
  spec.source_files  = "FreeLib/**/*"
  spec.exclude_files = "FreeLib/FreeLib/*.plist"

end
