module CarrierWave
  module Aliyun
    class Version
      MAJOR, MINOR, PATCH = 0, 3, 0

      ##
      # Returns the major version ( big release based off of multiple minor releases )
      def self.major
        MAJOR
      end

      ##
      # Returns the minor version ( small release based off of multiple patches )
      def self.minor
        MINOR
      end

      ##
      # Returns the patch version ( updates, features and (crucial) bug fixes )
      def self.patch
        PATCH
      end

      ##
      # Returns the current version of the Backup gem ( qualified for the gemspec )
      def self.current
        "#{major}.#{minor}.#{patch}"
      end

    end
  end
end
