module NameNormalizable
  extend ActiveSupport::Concern

  module ClassMethods
    def normalize_name(name)
      name&.squish&.downcase&.capitalize
    end
  end

  def normalize_name(name)
    self.class.normalize_name(name)
  end
end
