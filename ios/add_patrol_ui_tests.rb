require 'xcodeproj'

project_path = File.expand_path('Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)
name = 'RunnerUITests'

if project.targets.any? { |t| t.name == name }
  puts "#{name} already exists - nothing to do"
  exit 0
end

runner = project.targets.find { |t| t.name == 'Runner' }

target = project.new_target(:ui_test_bundle, name, :ios, '15.0', nil, :objc)
target.add_dependency(runner)

group = project.main_group.new_group(name, name)
target.add_file_references([group.new_file('RunnerUITests.m')])

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)' # ADDED: empty name produced ".xctest" and clashed
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.basicModernApp.RunnerUITests'
  config.build_settings['TEST_TARGET_NAME'] = 'Runner'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
end
project.save

scheme_path = Xcodeproj::XCScheme.shared_data_dir(project_path) + 'Runner.xcscheme'
scheme = Xcodeproj::XCScheme.new(scheme_path)
scheme.add_test_target(target)
scheme.save!

puts "Added #{name} target"