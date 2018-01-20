Pod::Spec.new do |spec|
	spec.name = "SemiSingleton"
	spec.version = "1.1.0"
	spec.summary = "Simple thread-safe uniquing of objects"
	spec.homepage = "https://www.happn.com/"
	spec.license = {type: 'TBD', file: 'License.txt'}
	spec.authors = {"François Lamboley" => 'francois.lamboley@happn.com'}
	spec.social_media_url = "https://twitter.com/happn_tech"

	spec.requires_arc = true
	spec.source = {git: "git@github.com:happn-app/SemiSingleton.git", tag: spec.version}
	spec.source_files = "Sources/SemiSingleton/*.swift"

	spec.osx.deployment_target = '10.10'
	spec.tvos.deployment_target = '9.0'
	spec.ios.deployment_target = '8.0'
	spec.watchos.deployment_target = '2.0'
end
