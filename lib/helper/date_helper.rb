module DateHelper

  def human_readable_time(start_dt, end_dt)
    sec_diff = end_dt.to_i - start_dt.to_i
    desc = end_dt > start_dt ? 'ago' : 'from now'
    "#{::ChronicDuration.output(sec_diff, format: :long, units: 3)} #{desc}"
  end
end
