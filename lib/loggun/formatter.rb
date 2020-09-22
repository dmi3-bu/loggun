require 'time'
require 'json'

module Loggun
  class Formatter
    DEFAULT_VALUE = '-'.freeze

    def call(severity, time, _program_name, message, loggun_type: nil)
      data = Hash.new(DEFAULT_VALUE)
      time = time.utc if config.force_utc

      process_message(data, message)

      data[:type] = loggun_type || Loggun.type || DEFAULT_VALUE.dup

      data[:timestamp] = time.iso8601(config.timestamp_precision)
      data[:time] = data[:timestamp] if config.log_format == :plain

      data[:severity] = severity&.to_s || 'INFO'
      data[:pid] = Process.pid
      data[:tags_text] = tags_text
      data[:transaction_id] = Loggun.transaction_id
      data[:parent_transaction] = parent_transaction if parent_transaction

      prepare_to_output(data)
    end

    def tagged(*tags)
      new_tags = push_tags(*tags)
      yield self
    ensure
      pop_tags(new_tags.size)
    end

    def push_tags(*tags)
      tags.flatten.reject(&:blank?).tap do |new_tags|
        current_tags.concat new_tags
      end
    end

    def pop_tags(size = 1)
      current_tags.pop size
    end

    def clear_tags!
      current_tags.clear
    end

    def current_tags
      thread_key = @thread_key ||= "loggun_tagged_logging_tags:#{object_id}"
      Thread.current[thread_key] ||= []
    end

    def tags_text
      tags = current_tags
      if tags.one?
        "[#{tags[0]}] "
      elsif tags.any?
        tags.collect { |tag| "[#{tag}] " }.join
      end
    end

    private

    def process_message(data, message)
      if message.is_a?(Hash)
        if config.parent_transaction_to_message && parent_transaction
          message[:parent_transaction] = parent_transaction
        end

        if config.log_format == :plain
          message = format_message(message)
        else
          simple_message = message.delete(:message)
          data[:metadata] = message if message != {}
          message = simple_message
        end
      end

      message = message.to_s.tr("\r\n", ' ').strip if config.log_format == :plain

      data[:message] = message
    end

    def prepare_to_output(data)
      if data[:transaction_id] && data[:type] != DEFAULT_VALUE &&
        data[:transaction_id].to_i != Process.pid
        data[:type] = "#{data[:type]}##{data[:transaction_id]}"
      end

      if config.log_format == :json
        data.except!(*config.exclude_keys) if config.only_keys.empty?
        data.slice!(*config.only_keys) if config.only_keys.any?
        JSON.generate(data) + "\n"
      else
        format(config.pattern + "\n", data)
      end
    end

    def parent_transaction
      return unless Loggun.parent_type && Loggun.parent_transaction_id

      "#{Loggun.parent_type}##{Loggun.parent_transaction_id}"
    end

    def config
      Loggun::Config.instance
    end

    def format_message(message)
      if config.message_format == :json
        JSON.generate(message)
      elsif config.message_format == :key_value
        message.map { |key, value| "#{key}=#{value}" }.join(' ')
      else
        warn('Unknown value for message_format')
        JSON.generate(message)
      end
    end
  end
end
