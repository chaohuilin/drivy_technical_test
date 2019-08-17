
require "date"
require_relative("./car")
require_relative("./constant")

class Rental
  attr_reader :id, :car, :distance, :rent_duration, :distance_fee, :rent_fee, :commission
  attr_writer :commission

  def initialize(data, cars)
    @id = data["id"]
    @car = get_selected_car(data["car_id"], cars)
    @distance = data["distance"]
    @rent_duration = calcul_duration(data["start_date"], data["end_date"])
    @distance_fee = calcul_distance_fee()
    @discount_fee = calcul_discount_fee(@rent_duration)
    @rent_fee = calcul_rent_fee()
    @commission = calcul_commission(@distance_fee + @rent_fee - @discount_fee,
                                    @rent_duration)
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
    ### TO DO : improve with a better algorithm ###
    ten_percent = days > 1 ?
      ((days > INITIAL_DISCOUNT[:days] ?
      INITIAL_DISCOUNT[:days] :
      days - 1) * INITIAL_DISCOUNT[:discount]) :
      0
    thirty_percent = days > INITIAL_DISCOUNT[:days] ?
      ((days >= MEDIUM_DISCOUNT[:days] ?
      MEDIUM_DISCOUNT[:days] - INITIAL_DISCOUNT[:days] - 1 :
      days - INITIAL_DISCOUNT[:days] - 1) * MEDIUM_DISCOUNT[:discount]) :
      0
    fitfy_percent = days > ADVANCE_DISCOUNT[:days] ?
      (days - ADVANCE_DISCOUNT[:days]) *
      ADVANCE_DISCOUNT[:discount] :
      0
    return (@car.price_per_day *
            (ten_percent + thirty_percent + fitfy_percent)).round
  end

  def calcul_commission(total_price, days)
    commission = (total_price * COMMISSION_RATE).round
    insurance_fee = (commission * INSURANCE_RATE).round
    assistance_fee = days * ASSISTANCE_FEE
    drivy_fee = commission - insurance_fee - assistance_fee
    return {
             :insurance_fee => insurance_fee,
             :assistance_fee => assistance_fee,
             :drivy_fee => drivy_fee,
           }
  end

  def generate_data_by_types(types)
    output = {
      :id => @id,
    }
    types.map { |type|
      final_price = @rent_fee + @distance_fee - @discount_fee
      case type
      when "price"
        output[:price] = @rent_fee + @distance_fee
      when "price_with_discount"
        output[:price] = final_price
      when "commission"
        output[:commission] = @commission
      when "actions"
        output[:actions] = generate_actions(final_price)
      end
    }
    return output
  end

  def generate_actions(final_price)
    [{
      :who => "driver",
      :type => "debit",
      :amount => final_price,
    },
     {
      :who => "owner",
      :type => "credit",
      :amount => (final_price * (1 - COMMISSION_RATE)).round,
    },
     {
      :who => "insurance",
      :type => "credit",
      :amount => @commission[:insurance_fee],
    },
     {
      :who => "assistance",
      :type => "credit",
      :amount => @commission[:assistance_fee],
    },
     {
      :who => "drivy",
      :type => "credit",
      :amount => @commission[:drivy_fee],
    }]
  end
end
