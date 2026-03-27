Pod::Spec.new do |s|
    s.name             = "mParticle-Mixpanel"
    s.version          = "1.0.0"
    s.summary          = "Mixpanel integration for mParticle"

    s.description      = <<-DESC
                       This is the Mixpanel integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mixpanel/mparticle-apple-integration-mixpanel.git", :tag => "v" + s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"
    s.swift_versions   = ['5.7', '5.8', '5.9']

    s.ios.deployment_target = "12.0"
    s.tvos.deployment_target = "12.0"

    s.source_files = 'Sources/mParticle-Mixpanel/**/*.swift'

    s.dependency 'mParticle-Apple-SDK', '~> 8.0'
    s.dependency 'Mixpanel-swift', '~> 4.0'
    s.ios.dependency 'MixpanelSessionReplay', '~> 1.0'
end
