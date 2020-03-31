Pod::Spec.new do |s|
  s.name             = 'ChatBird'
  s.version          = '1.0.0'
  s.summary          = 'Provides a framework that connects the SendBird chat service to the Chatto UI'

  s.description      = <<-DESC
                        This pod provides the glue to connect the SendBird chat service with the Chatto UI.
                        DESC
  s.homepage         = 'https://github.com/velos/chatbird-ios'
  s.screenshots     = 'https://github.com/velos/chatbird-ios/raw/master/ChatBird.gif
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'David Rajan' => 'david@velosmobile.com' }
  s.source           = { :git => 'https://github.com/velos/ChatBird.git', :tag => s.version.to_s }
  s.platform = :ios, '12.0'
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = 'ChatBird/Classes/**/*'
  s.resources = 'ChatBird/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'
  s.dependency 'SendBirdSDK'
  s.dependency 'Chatto'
  s.dependency 'ChattoAdditions'
  s.dependency 'Nuke'
end
