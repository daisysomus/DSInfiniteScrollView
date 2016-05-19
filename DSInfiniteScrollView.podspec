Pod::Spec.new do |spec|
  spec.name             = 'DSInfiniteScrollView'
  spec.version          = '0.0.1'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'hhttps://github.com/daisysomus/DSInfiniteImagePlayerView'
  spec.authors          = { 'Daisy' => 'daisysomus@gmail.com' }
  spec.platform         = :ios, "8.0"
  spec.summary          = 'Infinite scroll view for iOS'
  spec.source           = { :git => 'https://github.com/daisysomus/DSInfiniteImagePlayerView.git', :tag => '0.0.1' }
  spec.source_files     = 'DSInfiniteScrollView/DSInfiniteScrollView.swift'
  spec.framework        = 'UIKit'
  spec.requires_arc     = true
end