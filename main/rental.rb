
require "date"
require_relative("./car")

class Rental
  attr_reader :id, :car, :distance, :rent_duration, :distance_fee, :rent_fee

  def initialize(data, cars)
    @id = data["id"]
    @car = get_selected_car(data["car_id"], cars)
    @distance = data["distance"]
    @rent_duration = calcul_duration(data["start_date"], data["end_date"])
    @distance_fee = calcul_distance_fee()
    @discount_fee = calcul_discount_fee(@rent_duration)
    @rent_fee = calcul_rent_fee()
  end

  def get_selected_car(car_id, cars)
    begin
      return Car.new(cars.find { |item| item["id"] === car_id })
    rescue NoMethodError => e
      raise e, "Canno't find the car with id #{car_id}"
    end
  end

  def calcul_duration(start_date, end_date)
    begin
      duration = (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
      if (duration < 1)
        raise ArgumentError, "end date must be newer than star_date"
      end
      return duration
    rescue ArgumentError => e
      raise e, "rental #{@id} contains invalid dates"
    end
  end

  def calcul_distance_fee()
    return @car.price_per_km * @distance
  end

  def calcul_rent_fee()
    return @car.price_per_day * @rent_duration
  end

  def calcul_discount_fee(days)
    ### TO DO : improve with a better algorith ###
    ten_percent = days > 1 ? ((days >= 3 ? 3 : days - 1) * 0.1) : 0
    thirty_percent = days > 4 ? ((days >= 10 ? 6 : days - 4) * 0.3) : 0
    fitfy_percent = days > 10 ? (days - 10) * 0.5 : 0
    return (@car.price_per_day *
            (ten_percent + thirty_percent + fitfy_percent)).round
  end

  def generate_data_by_types(types)
    output = {
      :id => @id,
    }
    types.map { |type|
      case type
      when "price"
        output[:price] = @rent_fee + @distance_fee
      when "price_with_discount"
        output[:price] = @rent_fee + @distance_fee - @discount_fee
      end
    }
    return output
  end
end
