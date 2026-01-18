# frozen_string_literal: true
module PaginationHelper
  MAX_ITEMS_PER_PAGE = 100
  DEFAULT_ITEMS_PER_PAGE = 20

  # This helper ensures that pagination requests stay within safe bounds to prevent performance issues
  # or excessive resource consumption.
  # How It Works
  # If no value provided: Returns the smaller of default or max (typically 20)
  # If value provided: Returns the smaller of requested or max (caps at 100)
  # Logging: Warns when either the default or requested value exceeds the maximum
  def get_capped_items_number_per_page(items_number_per_page,
                                default_items_per_page: DEFAULT_ITEMS_PER_PAGE,
                                max_items_per_page: MAX_ITEMS_PER_PAGE,
                                request_path: nil)
    if items_number_per_page.blank?
      if default_items_per_page > max_items_per_page
        Rails.logger.warn("Exceeded max items per page: #{default_items_per_page} - #{request_path}")
      end

      return [default_items_per_page, max_items_per_page].min
    end

    if items_number_per_page > max_items_per_page
      Rails.logger.warn("Exceeded max items per page: #{items_number_per_page} - #{request_path}")
    end

    [items_number_per_page, max_items_per_page].min
  end
end
