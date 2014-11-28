Pod::Spec.new do |s|
  s.name             = "BonjourDevAPIFinder"
  s.version          = "0.1.0"
  s.summary          = "BonjourDevAPIFinder lets you find your local development API servers automatically and choose it instead of the production API in run-time."
  s.description      = <<-DESC
                       BonjourDevAPIFinder uses Tweaks.

                       You need to make sure Tweaks have a way to be opened (see [Tweaks docs](https://github.com/facebook/Tweaks)).

                       See example project for usage.
                       Sample Bonjour-enabled node server project attached in the `Server Example` folder.

                       DESC
  s.homepage         = "https://github.com/swingdev/BonjourDevAPIFinder"
  s.license          = 'MIT'
  s.author           = { "Tomek Kopczuk" => "tkopczuk@gmail.com" }
  s.source           = { :git => "https://github.com/swingdev/BonjourDevAPIFinder.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tkopczuk'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'BonjourDevAPIFinder' => []
  }

  s.frameworks = 'UIKit'

  s.dependency 'Tweaks', '~> 1.1'

end
