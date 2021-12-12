# frozen_string_literal: true

begin
  require_relative 'library/ua_rake_template'
rescue LoadError
  puts 'installing build library:'
  build_library_url = 'https://github.com/ua-oit-devops/ua-build-library.git'

  pinned_version = begin
    IO.read(File.join(__dir__, 'VERSION')).strip
  rescue Errno::ENOENT
    nil
  end

  Dir.chdir(__dir__) do
    command = %w[git clone --quiet]
    command << "--branch=#{pinned_version}" if pinned_version
    command.append('--filter=tree:0', build_library_url, 'library')

    puts command.join(' ')
    raise 'failed to install build library' unless system(*command)
  end

  puts "build library installation complete\n\n"

  require_relative 'library/ua_rake_template'
end
