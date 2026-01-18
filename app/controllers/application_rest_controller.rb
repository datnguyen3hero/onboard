class ApplicationRestController < ActionController::API
  include ErrorHandling
  include Pundit
  include PaginationHelper
end
