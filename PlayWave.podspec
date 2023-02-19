Pod::Spec.new do |spec|
  spec.name         = 'PlayWave'
  spec.version      = '0.0.1'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/Sherlocked1/WavePlayer'
  spec.authors      = { 'Mohammed Sayed' => 'mohamadsayed7070@gmail.com' }
  spec.summary      = 'Custom video player using avplayer'
  spec.source       = { :git => 'https://github.com/Sherlocked1/WavePlayer.git', :tag => spec.version }
  spec.source_files = 'PlayWave/'
  spec.framework    = 'SystemConfiguration'
  spec.ios.framework  = 'UIKit'
  spec.platform = :ios
end