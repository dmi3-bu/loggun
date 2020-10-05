class LoggerWorker
  include Sidekiq::Worker

  def perform
    logger.info 'worker'
  end
end