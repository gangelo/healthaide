module NameNormalizable
  extend ActiveSupport::Concern

  included do
    const_set("VALID_NAME_REGEX", /\A[a-zA-Z0-9 \-',\/\.\(\)\+]+\z/.freeze)
    const_set("INVALID_NAME_REGEX_MESSAGE", "can only contain letters, numbers, spaces, hyphens, apostrophes, commas, periods, forward slashes, plus signs and parentheses".freeze)

    before_validation :normalize_name
  end

  module ClassMethods
    def normalize_name(name)
      name&.squish&.downcase&.capitalize
    end
  end

  private

  def normalize_name
    # For example: self.<name> = self.class.normalize_name(self.<name>)
    raise NotImplementedError, "You must implement the normalize_name method"
  end
end
