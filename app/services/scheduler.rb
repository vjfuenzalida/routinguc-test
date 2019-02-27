# frozen_string_literal: true

class Scheduler
  def initialize
    @routes = Route.all.order(ends_at: :asc).to_a
    puts "ordered routes: #{@routes.pluck(:id)}"
    @vehicles = Vehicle.all.to_a
    @drivers = Driver.all.to_a
    # hash that relations vehicles to drivers
    # to save assignations ( driver_id => vehicle_id)
    @vehicle_assignations = {}
    # hash that only saves vehicle/driver mappings for
    # vehicles without owner (and drivers not owning vehicles)
    @free_assignations = {}
    # hash that stores which driver has which routes
    # (driver_id => [route_1, route_2, ...])
    @planification = {}
    @handled_routes = []
    @unhandled_routes = []
  end

  def schedule
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    @routes.each do |route|
      puts "\nFinding driver for route #{route.id}..."
      puts
      # find the best driver for the route
      resource = best_driver(route)
      if resource.nil? || resource.empty?
        puts "\t> [FAIL]\tCompatible resource (driver/vehicle) not found."
        @unhandled_routes << route.id
        next
      end
      puts "\t> [SUCCESS]\tResource found: Driver: #{resource[:driver].id}, Vehicle: #{resource[:vehicle].id}."
      # assign the vehicle to the driver if they are independent
      assign_vehicle(resource)
      # save route assignation (driver/route)
      assign_route(route, resource)
      @handled_routes << route.id
    end
    show_plan
    ActiveRecord::Base.logger = logger
    nil
  end

  def assign_vehicle(resource)
    driver_id = resource[:driver].id
    vehicle_id = resource[:vehicle].id
    puts "\t> [TASK]\tAssigning Vehicle #{vehicle_id} to Driver #{driver_id}."
    @vehicle_assignations[driver_id] = vehicle_id
    @free_assignations[driver_id] = vehicle_id unless resource[:driver].vehicle_id
  end

  def assign_route(route, resource)
    driver_id = resource[:driver].id
    puts "\t> [TASK]\tAssigning Route #{route.id} to Driver #{driver_id}."
    if @planification[driver_id].nil? || @planification[driver_id].empty?
      @planification[driver_id] = [route]
    else
      @planification[driver_id] << route
    end
    puts "\t> [INFO]\tCurrent schedule for Driver #{driver_id}: #{@planification[driver_id].pluck(:id)}"
  end

  def compatible_route(driver, route)
    current_schedule = @planification[driver.id]
    # check if the driver has no route assignations yet
    return true if current_schedule.nil? || current_schedule.empty?

    current_schedule.none? { |r| route.overlaps?(r) }
  end

  def best_driver(route)
    # a resource is a tuple of (driver, vehicle)
    valid_resources = []
    @drivers.each do |driver|
      next unless compatible_route(driver, route)

      next unless driver.allows_route?(route)

      # pick the drivers vehicle if he has one
      # and if not, choose a vehicle from the list
      vehicle = if driver.vehicle
                  driver.vehicle
                elsif @vehicle_assignations.key?(driver.id)
                  Vehicle.find(@vehicle_assignations[driver.id])
                else
                  best_vehicle(route)
                end
      next if vehicle.nil?
      next unless vehicle.allows_route?(route)

      valid_resources << { driver: driver, vehicle: vehicle }
    end
    choose_best(valid_resources)
  end

  def choose_best(resources)
    # it should consider cities covered by the driver,
    # max stops, vehicle capacity
    resources.max_by { |r| r[:vehicle].capacity }
  end

  def best_vehicle(route)
    # only choose from "not owned" vehicles (the owned ones are already
    # assigned to a driver). Also check if type and capacity fits.
    feasible_vehicles = Vehicle.not_owned.elegible_for_route(route)
    # don't consider vehicles already assigned to a driver
    feasible_vehicles = feasible_vehicles.reject { |v| @vehicle_assignations.value?(v.id) }
    return nil if feasible_vehicles.empty?

    # choose the highest capacity vehicle
    # NOTE: also can compare by the cities covered by the driver
    # or the max stops limit
    feasible_vehicles.max_by(&:capacity)
  end
end

def show_plan
  puts "\n\n[OUTPUT] ======= Assignations ======="
  puts
  headings = ['assignation', 'vehicle_id', 'driver_id', 'route_id', '(starts_at - ends_at)']
  rows = []

  plan_count = 0
  @planification.each do |driver_id, routes|
    vehicle_id = @vehicle_assignations[driver_id]
    routes.each do |route|
      plan_count += 1
      start_hour = route.starts_at.strftime('%H:%M:%S')
      end_hour = route.ends_at.strftime('%H:%M:%S')
      rows << [plan_count, vehicle_id, driver_id, route.id, "(#{start_hour} - #{end_hour})"]
    end
  end
  row_format = '%-15s %-12s %-10s %-10s %-24s'
  puts format(row_format, *headings)
  puts
  rows.each do |row|
    puts format(row_format, *row)
  end
  puts "\n[OUTPUT] Unassigned Routes: #{@unhandled_routes}"
  puts "\n\n[STATS] ====== STATISTICS ======="
  puts "\n\t> Assigned routes: ##{@handled_routes.count} => #{@handled_routes}"
  puts "\t> Unassigned routes: ##{@unhandled_routes.count} => #{@unhandled_routes}"
  puts "\t> Drivers used: ##{@vehicle_assignations.count} => #{@vehicle_assignations}"
  puts "\t> Free Drivers/Vehicles used: ##{@free_assignations.count} => #{@free_assignations}"
  nil
end

def puts_route_info(route)
  puts "
        Route #{route.id}:
        > Load: #{route.load_sum}
        > Type: #{route.load_type}
        > Stops: #{route.stops_amount}
        > Starts at: #{route.starts_at}
        > Starts at: #{route.ends_at}
        > Duration: #{(route.ends_at - route.starts_at) / 60} minutes
      "
end
