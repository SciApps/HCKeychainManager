Pod::Spec.new do |spec|
  spec.name             = 'HCKeychainManager'
  spec.version          = '0.1.0'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/SciApps/HCKeychainManager'
  spec.authors          = { 'Arpad Goretity' => 'h2co3@h2co3.org' }
  spec.summary          = 'Storing stuff in the Keychain painlessly'
  spec.source           = { :git => 'https://github.com/SciApps/HCKeychainManager.git', :tag => '0.1.0' }
  spec.source_files     = 'HCKeychainManager.{h,m}'
  spec.requires_arc     = true
  spec.framework        = 'Security'
end
