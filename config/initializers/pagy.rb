# frozen_string_literal: true

# Load Pagy
require "pagy"

# Pagination defaults
Pagy::DEFAULT[:limit] = 25           # default items per page
Pagy::DEFAULT[:size]  = 9            # nav bar links
Pagy::DEFAULT[:page_param] = :page   # parameter name for page number

# Add Pagy extras as needed
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page  # default handling of out-of-range pages
