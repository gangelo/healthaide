module NameNormalizable
  extend ActiveSupport::Concern

  included do
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
