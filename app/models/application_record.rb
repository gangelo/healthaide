class ApplicationRecord < ActiveRecord::Base
  include NameNormalizable

  primary_abstract_class
end
