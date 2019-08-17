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
    @rental = Rental.new(@data, @cars)
  end

  describe "#rental" do
    it "calcal duration with valid dates" do
      duration = @rental.calcul_duration("2017-12-8", "2017-12-10")
      expect(duration).to eq(3)
    end

    it "calcal duration with invalid dates" do
      expect { @rental.calcul_duration("2017-12", "2017-12-10") }.to raise_error(ArgumentError)
    end

    it "calcal duration should fail if start_date is newer than end_date" do
      expect { @rental.calcul_duration("2017-12-11", "2017-12-10") }.to raise_error(ArgumentError)
    end

    it "calcal duration with year change" do
      duration = @rental.calcul_duration("2017-12-29", "2018-01-01")
      expect(duration).to eq(4)
    end

    it "calcal duration with february of a not leap year" do
      duration = @rental.calcul_duration("2017-02-27", "2017-03-01")
      expect(duration).to eq(3)
    end

    it "calcal duration with february of leap year" do
      duration = @rental.calcul_duration("2020-02-27", "2020-03-01")
      expect(duration).to eq(4)
    end

    it "create a rental with correct data" do
      expect(@rental.car).to be_an_instance_of(Car)
      expect(@rental.car.id).to eq(1)
      expect(@rental.rent_duration).to eq(3)
      expect(@rental.distance_fee).to eq(1000)
      expect(@rental.rent_fee).to eq(6000)
    end

    it "contains wrong car id" do
      @data["car_id"] = 5
      expect { Rental.new(@data, @cars) }.to raise_error(NoMethodError)
    end

    it "generates data by types with correct type" do
      expect_result = {
        :id => 1,
        :price => 7000,
      }
      expect(@rental.generate_data_by_types(["price"])).to eq(expect_result)
    end

    it "generates data by types without argument" do
      expect_result = {
        :id => 1,
      }
      expect(@rental.generate_data_by_types([])).to eq(expect_result)
    end

    it "generates data by types with uncorrect argument" do
      expect_result = {
        :id => 1,
      }
      expect(@rental.generate_data_by_types([])).to eq(expect_result)
    end

    it "calculates discount with only one day" do
      expect(@rental.calcul_discount_fee(1)).to eq(0)
    end

    it "calculates discount for less than 5 days booking" do
      expect(@rental.calcul_discount_fee(4)).to eq(600)
    end

    it "calculates discount for less than 10 days booking" do
      expect(@rental.calcul_discount_fee(8)).to eq(3000)
    end

    it "calculates discount for more than 10 days booking" do
      expect(@rental.calcul_discount_fee(12)).to eq(6200)
    end

    it "calculates commission" do
      expect_result = {
        :insurance_fee => 1500,
        :assistance_fee => 200,
        :drivy_fee => 1300,
      }
      expect(@rental.calcul_commission(10000, 2)).to eq(expect_result)
    end
  end
end
