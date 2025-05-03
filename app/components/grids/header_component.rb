class Grids::HeaderComponent < ViewComponent::Base
  ALLOWED_COLUMN_KEY_VALUE_PAIRS = %i[css_class]

  def initialize(columns)
    @columns = columns_hash_for(columns[:columns])
  end

  attr_reader :columns

  private

  # Converts an array of column definitions into a hash.
  # @param columns [Array<Hash, Symbol>] An array where each element is either:
  #   - A Hash: The key is the column name, and the value is a hash of attributes (e.g., { css_class: "value" }).
  #   - A Symbol: Represents a column name with no additional attributes.
  # @return [Hash] A hash where keys are column names and values are attribute hashes.
  def columns_hash_for(columns)
    hash = {}
    columns.each do |column|
      if column.is_a?(Hash)
        hash[column.keys.first] = column[column.keys.first].slice(*ALLOWED_COLUMN_KEY_VALUE_PAIRS)
        next
      end

      hash[column] = {}
    end
    hash
  end

  # NOTE: tailwind does not understand dynamic css classes, so
  # we have to do this silliness.
  # https://tailwindcss.com/docs/detecting-classes-in-source-files#dynamic-class-names
  def grid_cols_css_class
    column_count = columns.keys.length
    case column_count
    when 1
      "grid-cols-1"
    when 2
      "grid-cols-2"
    when 3
      "grid-cols-3"
    when 4
      "grid-cols-4"
    when 5
      "grid-cols-5"
    when 6
      "grid-cols-6"
    when 7
      "grid-cols-7"
    when 8
      "grid-cols-8"
    when 9
      "grid-cols-9"
    when 10
      "grid-cols-10"
    else
      raise ArgumentError, "Unhandled number of columns: #{column_count}"
    end
  end
end
