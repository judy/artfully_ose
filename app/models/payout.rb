class Payout
  def range_for(now)
    start = start_from(now.beginning_of_day)
    stop  = offset_from(start)
    [ start, stop ]
  end

  def performances
    start, stop = range_for(Time.now)
    AthenaPerformance.in_range(start, stop)
  end

  private

  def start_from(now)
    business_days = 3
    while(business_days > 0) do
      now -= 1.day
      business_days -= 1 unless weekend?(now)
    end
    now
  end

  def offset_from(start)
    stop = start + 1.day
    stop += 2.days if stop.saturday?

    end_of_day_before(stop)
  end

  def end_of_day_before(day)
    (day - 1.day).end_of_day
  end

  def weekend?(day)
    day.saturday? or day.sunday?
  end

  def weekend_offset(day)
    weekend?(day) ? 2.days : 0
  end
end