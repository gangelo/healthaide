# frozen_string_literal: true

module Pager
  extend ActiveSupport::Concern
  include Pagy::Backend

  included do
    PAGER_ROWS_DEFAULT = 25
    PAGER_ROWS_OPTIONS = [ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 75, 100 ].freeze

    before_action :set_pager_params, only: [ :index, :pager_rows_changed ]
  end

  # Action to handle when the "Rows per page" select changes value.
  # Subclasses should override this method and respond to the appropriate response format.
  # For example, in a Turbo Stream response, you might want to update the list of records and
  # the shared/pager partial.
  def pager_rows_changed
    raise NotImplementedError, "#{self.class} must implement the #pager_rows_changed method"
  end

  private

  def set_pager_session
    session[:pager_rows] = pager_rows_or_default
  end

  # Subclasses should override this method to set the action path that
  # should be used when navigation that occurs as a result of using the
  # navigation links at the bottom of the page.
  def set_pager_pagination_path
    raise NotImplementedError, "#{self.class} must implement the #pager_pagination_path method"
  end

  # Subclasses should override this method to provide the action path for when
  # the "Rows per page" select changes.
  def set_pager_rows_changed_action_path
    raise NotImplementedError, "#{self.class} must implement #pager_rows_changed_action_path"
  end

  def set_pager_params
    set_pager_session
    set_pager_pagination_path
    set_pager_rows_changed_action_path

    @pagy, @records = pagy(
      pager_records_collection,
      limit: pager_rows_or_default,
      page_param: :pager_page,
      params: {
        pager_rows: pager_rows_or_default
      }
    )
    @pager_rows         = pager_rows_or_default
    @pager_rows_options = PAGER_ROWS_OPTIONS

    debug_show_pager_params
  end

  def pager_page_or_default
    (params[:pager_page] || 1).to_i
  end

  def pager_rows_or_default
    (params[:pager_rows] || session[:pager_rows] || PAGER_ROWS_DEFAULT).to_i
  end

  # Subclasses should override this method to provide the collection to be paginated
  def pager_records_collection
    raise NotImplementedError, "#{self.class} must implement #pager_records_collection"
  end

  def debug_show_pager_params
    Rails.logger.debug(
      <<~DEBUG
        #{(yield if block_given?) || "Pager#debug_show_pager_params:" }
        - pager_page: #{pager_page_or_default}
        - pager_rows: #{pager_rows_or_default}
        - records: #{@records.size}
        - pagy: #{@pagy.inspect}
        - params: #{params.inspect}
      DEBUG
    )
  end
end
