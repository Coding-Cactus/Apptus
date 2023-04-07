module ApplicationHelper
  def nice_time(time)
    now = Time.now

    if time.day == now.day && time.month == now.month && time.year == now.year
      time.strftime('%k:%M')
    elsif time.year == now.year
      time.strftime('%d/%m')
    else
      time.strftime('%d/%m/%y')
    end
  end
end
