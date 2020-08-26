module TeamCityFormatter
  class Logger
    def initialize(io)
      @io = io
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

    def test_failed_with_exceptions(test_name, exceptions)
      details = exceptions.map { |x| format_exception(x)} .join("\n\n and \n\n")
      test_failed(test_name, details)
    end

    def test_failed(test_name, details)
      render_output("##teamcity[testFailed flowId='#{flow_id}' name='#{teamcity_escape(test_name)}' message='#{teamcity_escape(details)}' timestamp='#{timestamp}']")
    end

    def test_finished(test_name)
      render_output("##teamcity[testFinished flowId='#{flow_id}' name='#{teamcity_escape(test_name)}' timestamp='#{timestamp}']")
    end

    def format_exception(exception)
      lines = ["#{exception.message} (#{exception.class})"] + exception.backtrace
      lines.join("\n")
    end


    def render_output(text)
      @io.puts(text)
      @io.flush
    end

    private

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
    
    def flow_id
      Process.pid
    end
  end
end
