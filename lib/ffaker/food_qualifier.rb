module FFaker
  module FoodQualifier
    extend ModuleUtils
    extend self

    PREPARATIONS = [
      "fresh", "frozen", "dried", "canned", "smoked", "pickled",
      "fermented", "preserved", "raw", "cooked", "pre-cooked"
    ]

    PACKAGING = [
      "in water", "in olive oil", "in brine", "in tomato sauce",
      "in spring water", "in own juice", "vacuum-sealed", "in salt"
    ]

    CUTS = [
      "sliced", "diced", "whole", "filleted", "ground", "minced",
      "cubed", "shredded", "pureed", "chopped"
    ]

    QUALITIES = [
      "organic", "non-GMO", "wild-caught", "free-range", "grass-fed",
      "sustainable", "fair-trade", "locally sourced", "premium"
    ]

    def preparation
      PREPARATIONS.sample
    end

    def packaging
      PACKAGING.sample
    end

    def cut
      CUTS.sample
    end

    def quality
      QUALITIES.sample
    end

    def qualifier
      case rand(4)
      when 0 then "#{preparation}, #{packaging}"
      when 1 then "#{cut}, #{packaging}"
      when 2 then "#{quality}, #{preparation}"
      when 3 then "#{preparation}, #{cut}"
      end
    end

    def qualifiers(count = 2)
      Array.new(count) { qualifier }.uniq
    end
  end
end
