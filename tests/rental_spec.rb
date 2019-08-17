require_relative("../main/rental")
require_relative("../main/car")
require "json"
RSpec.describe Rental do
  before(:each) do
    @data = {
      "id" => 1,
      "car_id" => 1,
      "start_date" => "2017-12-8",
      "end_date" => "2017-12-10",
      "distance" => 100,
    }
    @cars = [{ "id" => 1, "price_per_day" => 2000, "price_per_km" => 10 }]
  end

  describe "#rental" do
    it "calcal duration with valid dates" do
      rental = Rental.new(@data, @cars)
      duration = rental.calcul_duration("2017-12-8", "2017-12-10")
      expect(duration).to eq(3)
    end

    it "calcal duration with invalid dates" do
      rental = Rental.new(@data, @cars)
      expect { rental.calcul_duration("2017-12", "2017-12-10") }.to raise_error(ArgumentError)
    end

    it "calcal duration should fail if start_date is newer than end_date" do
      rental = Rental.new(@data, @cars)
      expect { rental.calcul_duration("2017-12-11", "2017-12-10") }.to raise_error(ArgumentError)
    end

    it "calcal duration with year change" do
      rental = Rental.new(@data, @cars)
      duration = rental.calcul_duration("2017-12-29", "2018-01-01")
      expect(duration).to eq(4)
    end

    it "calcal duration with february of a not leap year" do
      rental = Rental.new(@data, @cars)
      duration = rental.calcul_duration("2017-02-27", "2017-03-01")
      expect(duration).to eq(3)
    end

    it "calcal duration with february of leap year" do
      rental = Rental.new(@data, @cars)
      duration = rental.calcul_duration("2020-02-27", "2020-03-01")
      expect(duration).to eq(4)
    end

    it "create a rental with correct data" do
      rental = Rental.new(@data, @cars)
      expect(rental.car).to be_an_instance_of(Car)
      expect(rental.car.id).to eq(1)
      expect(rental.rent_duration).to eq(3)
      expect(rental.distance_fee).to eq(1000)
      expect(rental.rent_fee).to eq(6000)
    end

    it "contains wrong car id" do
      @data["car_id"] = 5
      expect { Rental.new(@data, @cars) }.to raise_error(NoMethodError)
    end

    it "generates data by types with correct type" do
      rental = Rental.new(@data, @cars)
      expect_result = {
        :id => 1,
        :price => 7000,
      }
      expect(rental.generate_data_by_types(["price"])).to eq(expect_result)
    end

    it "generates data by types without argument" do
      rental = Rental.new(@data, @cars)
      expect_result = {
        :id => 1,
      }
      expect(rental.generate_data_by_types([])).to eq(expect_result)
    end

    it "generates data by types with uncorrect argument" do
      rental = Rental.new(@data, @cars)
      expect_result = {
        :id => 1,
      }
      expect(rental.generate_data_by_types([])).to eq(expect_result)
    end
  end
end
