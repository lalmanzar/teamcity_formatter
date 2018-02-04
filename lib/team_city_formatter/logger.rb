module TeamCityFormatter
  class Logger
    attr_accessor :retried_scenarios

    def initialize(io)
      @io = io
      @retried_scenarios = {}
    end

    def test_suite_started(test_suite_name)
      render_output("##teamcity[testSuiteStarted flowId='#{flow_id}' name='#{teamcity_escape(test_suite_name)}' timestamp='#{timestamp}']")
    end

    def test_suite_finished(test_suite_name)
      render_output("##teamcity[testSuiteFinished flowId='#{flow_id}' name='#{teamcity_escape(test_suite_name)}' timestamp='#{timestamp}']")
    end

    def test_started(test_name)
      render_output("##teamcity[testStarted flowId='#{flow_id}' name='#{teamcity_escape(test_name)}' captureStandardOutput='true' timestamp='#{timestamp}']")
    end

    def test_failed_with_exception(test_name, exception)
      details = format_exception(exception)
      test_failed(test_name, details)
    end

    def test_failed(test_name, details)
      render_output("##teamcity[testFailed flowId='#{flow_id}' name='#{teamcity_escape(test_name)}' message='#{teamcity_escape(details)}' timestamp='#{timestamp}']")
    end

    def test_ignored(test_name, details)
      render_output("##teamcity[testIgnored flowId='#{flow_id}' name='#{teamcity_escape(test_name)}' message='#{teamcity_escape(details)}' timestamp='#{timestamp}']")
    end

    def test_finished(test_name)
      render_output("##teamcity[testFinished flowId='#{flow_id}' name='#{teamcity_escape(test_name)}' timestamp='#{timestamp}']")
    end

    def test_finished_with_exception(test_name, exception)
      render_output("##teamcity[testFinished flowId='#{flow_id}' name='#{teamcity_escape(test_name)}' message='#{teamcity_escape(format_exception(exception))}' timestamp='#{timestamp}']")
    end

    def retried?(test_name)
      @retried_scenarios.has_key?(test_name)
    end

    def add_retry(test_name, exception)
      @retried_scenarios[test_name] = exception
    end

    private

    def render_output(text)
      @io.puts(text)
      @io.flush
    end

    def teamcity_escape(s)
      s.to_s.strip
          .gsub(':', ' -')
          .gsub('|', '||')
          .gsub("'", "|'")
          .gsub(']', '|]')
          .gsub('[', '|[')
          .gsub("\r", '|r')
          .gsub("\n", '|n')
    end

    def timestamp_short
      now = Time.now
      '%s.%0.3d' % [now.strftime('%H:%M:%S'), (now.usec / 1000)]
    end

    def timestamp
      now = Time.now
      '%s.%0.3d' % [now.strftime('%Y-%m-%dT%H:%M:%S'), (now.usec / 1000)]
    end

    def format_exception(exception)
      lines = ["#{exception.message} (#{exception.class})"] + exception.backtrace
      lines.join("\n")
    end

    def flow_id
      Process.pid
    end
  end
end
