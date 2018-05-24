Pod::Spec.new do |s|
  s.name             = 'Leaf'
  s.version          = '1.2.0'
  s.summary          = 'Versatile HTTP networking framework written in Swift.'

  s.homepage         = 'https://github.com/Meniny/Leaf'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.authors          = { 'Elias Abel' => 'admin@meniny.cn' }
  s.source           = { :git => 'https://github.com/Meniny/Leaf.git', :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn'

  s.swift_version    = "4.1"

  s.ios.deployment_target     = '8.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target    = '9.0'
  s.osx.deployment_target     = '10.10'

  s.framework        = 'Foundation'
  s.module_name      = 'Leaf'
  s.default_subspecs = 'Core', 'URLSession', 'Simple'

  s.subspec 'Core' do |ss|
    ss.source_files  = "Leaf/Core/*.{h,swift}"
  end

  s.subspec 'URLSession' do |ss|
    ss.dependency 'Leaf/Core'
    ss.source_files  = "Leaf/URLSession/*.{h,swift}"
  end

  s.subspec 'Simple' do |ss|
    ss.dependency 'Leaf/Core'
    ss.dependency 'Leaf/URLSession'
    ss.source_files  = "Leaf/Simple/*.{h,swift}"
  end

  # s.subspec 'Promise' do |ss|
  #   ss.dependency 'Leaf/Core'
  #   ss.dependency 'Leaf/URLSession'
  #   ss.dependency 'Leaf/Simple'
  #   ss.dependency 'Oath'
  #   ss.source_files  = "Leaf/Promise/*.{h,swift}"
  # end

end
