class ControllrFetcher
  def initialize
    @controllr = Controllr.new
  end

  def run
    employment
    current_performance
    working_hours
    salaries
    average_age
    commute_distances
    children_per_employee
  end

  private

  attr_reader :controllr

  def employment
    employees = controllr.employee_count
    historic_employees = controllr.employee_historic_count
    contractors = controllr.contractor_count

    DataStore.set('employees', count: employees, historicCount: historic_employees)
    DataStore.set('contractors', count: contractors)
  end

  def current_performance
    current_month = Date.today.prev_month.prev_month
    previous_month = current_month.prev_month
    previous_performance = controllr.performance(previous_month.month, previous_month.year)
    current_performance = controllr.performance(current_month.month, current_month.year)

    DataStore.set(
      'currentPerformance',
      {
        lastMonth: current_performance,
        secondToLastMonth: previous_performance
      }
    )
  end

  def working_hours
    hours_worked = controllr.hours_worked(Date.today.month, Date.today.year)
    DataStore.set('hoursWorked', currentMonth: hours_worked)
  end

  def salaries
    years_salaries = YAML.load_file(Rails.root.join('config/salaries.yml'))

    to_month = Date.today.prev_month.prev_month
    # get the first day of the month to be able to properly iterate
    # (see iteration comment below)
    to_month = Date.new(to_month.year, to_month.month, 1)
    from_month = to_month << 11
    # select the first day only, otherwise the iteration includes every day
    months = (from_month..to_month).select { |month| month.day == 1 }

    salaries = months.map do |month|
      salary, workload = years_salaries[month.year][month.month]
      {
        month: month.month,
        year: month.year,
        salary: salary,
        workload: workload
      }
    end

    DataStore.set('salaries', oneYearBack: salaries)
  end

  def average_age
    average_age = controllr.average_age
    DataStore.set('age', average: average_age)
  end

  def commute_distances
    distances = controllr.commute_distances.map { |distance| distance.round(1) }
    durations = controllr.commute_durations.map do |duration|
      hours, minutes = duration.divmod(60)
      if hours == 0
        "#{minutes}min"
      else
        total_hours = hours + (minutes / 60.0).round(2)
        "#{total_hours}h"
      end
    end

    DataStore.set(
      'commuteDistances',
      {
        shortest: {
          duration: durations.first,
          distance: "#{distances.first}km"
        },
        longest: {
          duration: durations.last,
          distance: "#{distances.last}km"
        }
      }
    )
  end

  def children_per_employee
    children_per_employee = controllr.children_per_employee
    DataStore.set('childrenPerEmployee', count: children_per_employee);
  end
end
