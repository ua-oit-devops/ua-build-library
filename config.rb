# frozen_string_literal: true

module UaBuild
  # Reads build configuration from repoistory.
  class Config
    class << self
      attr_accessor :options

      def from_file(filename)
        require 'yaml'
        self.options = YAML.safe_load(IO.read(filename))
      end

      def _load
        from_file(File.join(__dir__, '..', '..', 'uabuild.yaml'))
      end

      def [](key)
        (options || _load)[key]
      end
    end
  end
end
