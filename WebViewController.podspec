Pod::Spec.new do |spec|
#Information
  spec.name         = 'WebViewController'
  spec.version      = '1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/mergesort/WebViewController'
  spec.author       =  { 'Joe Fabisevich' => 'github@fabisevi.ch' }
  spec.summary      = "The web view controller I'm going to use, because everyone has their own version, but this one is simple with minimal chrome."
  spec.source       =  { :git => 'https://github.com/mergesort/WebViewController.git', :tag => "#{spec.version}" }
  spec.source_files = '*.{h,m}'
  spec.framework    = 'Foundation'
  spec.requires_arc = true
  spec.social_media_url = 'https://twitter.com/mergesort'
  spec.ios.deployment_target = '7.0'

#Depdencies
  spec.dependency 'PureLayout'
end
