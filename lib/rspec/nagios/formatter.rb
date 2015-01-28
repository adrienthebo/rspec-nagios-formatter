require 'rspec/nagios'

class RSpec::Nagios::Formatter
  ::RSpec::Core::Formatters.register self, :dump_summary

  attr_reader :output
  attr_reader :failed_examples

  def initialize(output)
    @output = output
  end

  def dump_summary(summary)
    output.puts summary_line(summary)
  end

  def summary_line(summary)
    duration      = summary.duration
    example_count = summary.examples.count
    failure_count = summary.failed_examples.count
    pending_count = summary.pending_examples.count

    failed_examples = summary.failed_examples


    passing_count = example_count - failure_count
    # conformance is expressed as a percentage
    # if example_count is zero we need to avoid div by 0
    if example_count > 0
      conformance  = passing_count / example_count.to_f
      conformance *= 100
      conformance  = conformance.round
    else
      conformance  = 0
    end
    # limit duration precision to microseconds
    time = rounding(duration, 6)

    summary = 'RSPEC'
    if failure_count == 0
      summary << " OK"
    else
      summary << " Critical"
    end

    summary << " - " << pluralize(example_count, "example")
    summary << ", " << pluralize(failure_count, "failure")
    summary << ", #{pending_count} pending" if pending_count > 0
    summary << ", finished in #{time} seconds"

    summary << " | examples=#{example_count}"
    summary << " passing=#{example_count - failure_count}"
    summary << " failures=#{failure_count}"
    summary << " pending=#{pending_count}"
    summary << " conformance=#{conformance}%"
    summary << " time=#{time}s"

    if failed_examples.any?
      summary << "\n"
      summary << "#{failed_examples.map { |e| "#{e.location} #{e.full_description}" }.join("\n") }"
    end

    summary
  end

  private

  def rounding(float, precision)
    return ((float * 10**precision).round.to_f) / (10**precision)
  end

  def pluralize(int, str)
    int.to_s + " " + (int == 1 ? str : str + 's')
  end
end
