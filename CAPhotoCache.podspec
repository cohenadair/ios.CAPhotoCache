#
# Be sure to run `pod lib lint CAPhotoCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Remember to run `pod install` after updating this file, or adding new files to the library.
#

Pod::Spec.new do |s|
  s.name                = 'CAPhotoCache'
  s.version             = '0.1.0'
  s.summary             = 'CAPhotoCache is a robust cacheing system for local photos on iOS.'

  s.description         = <<-DESC
                        CAPhotoCache is a very small, simple library that will manage a memory and disk cache for
                        displaying photos in different sized UIImageViews iOS. This allows for seamless, fluid UI
                        movement and user experience. CAPhotoCache was created to be used with another project of
                        mine, Anglers’ Log.  No other cacheing systems works quite like I needed, and I thought
                        it might be fun to create an iOS library for others to use.
                        DESC

  s.homepage            = 'https://github.com/cohenadair/ios.CAPhotoCache'
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { 'Cohen Adair' => 'cohenadair@gmail.com' }
  s.source              = { :git => 'https://github.com/cohenadair/ios.CAPhotoCache.git', :tag => s.version.to_s }

  s.platform            = :ios, '8.4'
  s.requires_arc        = true

  s.source_files        = 'CAPhotoCache/*'
  s.public_header_files = 'CAPhotoCache/*.h'

  s.dependency 'UIImage-ResizeMagick'
end
