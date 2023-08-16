# frozen_string_literal: true

desc "Checks Apptus version has been correctly updated"
task :version_check do
  new_version = File.read("config/application.rb").match(/APPTUS_VERSION = "(.*)"/)[1]
  current_live_version = Nokogiri::HTML(URI.open("https://apptus.online/ping")).css("#version").text

  if new_version.nil? || current_live_version == ""
    puts "Could not fetch Apptus version. Manual review required"
    exit 1
  end

  if Gem::Version.new(new_version) <= Gem::Version.new(current_live_version)
    puts "Apptus version is not correctly updated. Please update config/application.rb"
    exit 1
  end
end
