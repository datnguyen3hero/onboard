# frozen_string_literal: true

# Rack middleware for monitoring application performance metrics.
#
# This middleware tracks request processing time, database query counts,
# and logs performance data for each request. It also adds custom headers
# to responses with performance information and warns about slow requests.
#
# @example Usage in Rails application
#   # config/application.rb
#   config.middleware.use PerformanceMonitor
#
# @example Response headers added
#   X-Response-Time: 123.45ms
#   X-DB-Query-Count: 15
#   X-Worker-PID: 12345
class PerformanceMonitor
  def initialize(app)
    @app = app
  end

  def call(env)
    start_time = Time.current
    # Track database queries
    query_count_start = query_count
    status, headers, response = @app.call(env)
    end_time = Time.current
    duration_ms = (end_time - start_time) * 1000
    query_count_total = query_count - query_count_start
    # Log performance metrics
    Rails.logger.info({
                        method: env['REQUEST_METHOD'],
                        path: env['REQUEST_PATH'],
                        status: status,
                        duration_ms: duration_ms.round(2),
                        db_queries: query_count_total,
                        process_id: Process.pid,
                        thread_id: Thread.current.object_id
                      }.to_json)
    # Add performance headers
    headers['X-Response-Time'] = "#{duration_ms.round(2)}ms"
    headers['X-DB-Query-Count'] = query_count_total.to_s
    headers['X-Worker-PID'] = Process.pid.to_s
    # Alert on slow requests
    if duration_ms > 500
      Rails.logger.warn("SLOW REQUEST: #{env['REQUEST_METHOD']} #{env['REQUEST_PATH']} - #{duration_ms.round(2)}ms")
    end
    [status, headers, response]
  end

  private

  def query_count
    ActiveSupport::Notifications.monotonic_subscribe('sql.active_record') { }
    Thread.current[:query_count] ||= 0
  rescue StandardError
    0
  end
end


