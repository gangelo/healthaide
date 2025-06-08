module Frequentable
  extend ActiveSupport::Concern

  FREQUENCIES = {
     as_needed: 10,
      daily: 20,
      every_other_day: 25,
      four_times_daily: 30,
      monthly: 40,
      three_times_daily: 50,
      twice_daily: 60,
      twice_weekly: 70,
      weekly: 80,
      other: 999
  }

  included do
    enum :frequency, FREQUENCIES, prefix: true

    validates :frequency, presence: true
  end

  class_methods do
    def frequencies_by_value
      frequencies.sort_by { |_key, value| value }
    end
  end
end
