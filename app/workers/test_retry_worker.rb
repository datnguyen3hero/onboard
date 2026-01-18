class TestRetryWorker
  include Sidekiq::Worker

  sidekiq_options queue: :retry,
                  backtrace: true,
                  dead: true

  def perform
    puts "TestRetryWorker is executing..."
    end
end
