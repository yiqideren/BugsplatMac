Pod::Spec.new do |s|
  s.name         = 'BugsplatMac'
  s.version      = '1.0.8'
  s.license      = 'MIT'
  s.homepage	 = 'http://bugsplatsoftware.com'
  s.summary      = 'Bugsplat OS X framework'
  s.author       = 'Geoff Raeder'
  s.source 		 = { :http => "https://github.com/BugSplatGit/BugsplatMac/releases/download/#{s.version}/BugsplatMac.framework.zip" }
  s.platform     = :osx, '10.9'
  s.requires_arc = true
  s.vendored_frameworks = 'Carthage/Build/Mac/BugsplatMac.framework'
  s.resource = 'Carthage/Build/Mac/BugsplatMac.framework'
  s.xcconfig = { 'LD_RUNPATH_SEARCH_PATHS' => '@executable_path/../Frameworks' }
end
