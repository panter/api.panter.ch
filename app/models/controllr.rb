class Controllr
  def employee_count
    active_employees.count
  end

  def contractor_count
    active_contractors.count
  end

  def average_age
    data = active_employees

    ages = data.map { |user|
      date_of_birth = Date.parse(user['date_of_birth'])
      Age.from_date(date_of_birth)
    }.compact

    ages.inject(&:+) / ages.length
  end

  # @param month [Fixnum] the month as a number (starting at 1 for January), see `Date#month`.
  def performance(month, year)
    data = fetch('/api/monthly_salaries/spreadsheet_data.json', { month: month, year: year })
    data_totals = data['totals']

    hours_worked = data_totals['internal_hours_worked'].to_f
    hours = {
      billable: data_totals['internal_hours_billable'].to_f,
      nonBillable: hours_worked - data_totals['internal_hours_billable'].to_f,
      neutral: data_totals['internal_hours_holidays'].to_f,
      total: data_totals['monthly_total_hours'].to_f
    }

    performance = hours[:billable] / hours_worked

    {
      hours: hours,
      performance: performance.round(2)
    }
  end

  def hours_worked(month, year)
    data = fetch('/api/monthly_salaries/spreadsheet_data.json', { month: month, year: year })
    data_totals = data['totals']
    data_totals['internal_hours_worked'].to_i
  end

  def commute_distances
    Geocoder.configure(units: :km, cache: Redis.new)

    user_addresses.map { |address|
      Geocoder::Calculations.distance_between(address, office_address)
    }.reject(&:nan?).sort
  end

  def commute_durations
    user_addresses.map { |address|
      PublicTransport.connection_duration(address, office_address)
    }.compact.sort
  end

  def office_address
    @office_address ||=
      begin
        data = fetch('/api/system_settings.json')
        data = data.find { |entry| entry['name'] == 'tenant' }['options']

        "#{data['address']}, #{data['zip']} #{data['city']}"
      end
  end

  def children_per_employee
    employees = active_employees

    children_count = employees
      .map { |user|
        if user['children']
          lines = user['children'].split(/\n/)
          # lines without a date are comments and not actual children
          lines = lines.select { |line| line =~ /\d{2}\.\d{2}\.\d{4}/ }

          lines.length
        end
      }
      .flatten
      .map(&:to_f)
      .inject(&:+)

      (children_count / employees.length.to_f).round(2)
  end

  def employee_historic_count
    all_employees = employees

    dates = all_employees.map do |user|
      # to simplify checking the date range set the end date if not set
      exit_date = user['exit_date'] || Date.today.to_s
      [
        Date.parse(user['entry_date']),
        Date.parse(exit_date)
      ]
    end

    oldest_date = dates.flatten.compact.sort.first

    (oldest_date..Date.today).select { |date| date.day == 1 }.map do |date|
      {
        date: date,
        count: dates.select do |entry_date, exit_date|
          (entry_date..exit_date).cover?(date)
        end.length
      }
    end
  end

  def salary(month, year)
    @total_salaries ||= fetch('/accounting_months/total_salaries')

    url = @total_salaries.find { |total_salary| total_salary['year'] == year && total_salary['month'] == month }['monthly_salaries_url']

    salary = fetch(url)

    employees = salary['employees']
    average_workload = employees.map { |employee| employee['workload'] }.sum / employees.count.to_f

    {
      month: month,
      year: year,
      salary: (salary['totals']['salary_gross'] * average_workload).round,
      workload: (average_workload * 100).round
    }
  end

  private

  def users(filters = {})
    @users ||= fetch('/api/users.json')

    filters.inject(@users) do |users, filter|
      users = users.select { |user| user[filter[0].to_s] == filter[1] }
    end
  end

  def active_users(filters = {})
    users(filters.merge(active: true))
  end

  def employees
    users(employment: 'employee')
      .select { |user| user['entry_date'] } # some users aren't real employees...
  end

  def active_employees
    active_users(employment: 'employee')
      .select { |user| user['entry_date'] } # some users aren't real employees...
  end

  def active_contractors
    active_users(employment: 'external')
  end

  def user_addresses
    @user_addresses ||=
      begin
        active_employees
          .map { |user|
            if user['address']
              user['address'].gsub(/[\n\r]+/, ', ')
            end
          }
          .compact
      end
  end

  def fetch(url, params = {})
    url = ENV['CONTROLLR_URL'] + url
    params = params.merge(user_token: ENV['CONTROLLR_TOKEN'], format: :json)

    JsonApi.fetch(url, params)
  end
end
