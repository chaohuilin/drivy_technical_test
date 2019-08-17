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
    @options = [
      { "id" => 1, "rental_id" => 1, "type" => "gps" },
      { "id" => 2, "rental_id" => 1, "type" => "baby_seat" },
      { "id" => 3, "rental_id" => 2, "type" => "additional_insurance" },
    ]
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

    it "format the result by action" do
      final_price = 10000
      commission = @rental.calcul_commission(final_price * COMMISSION_RATE, 2)
      expect_result = [{
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
        :amount => commission[:insurance_fee],
      },
                       {
        :who => "assistance",
        :type => "credit",
        :amount => commission[:assistance_fee],
      },
                       {
        :who => "drivy",
        :type => "credit",
        :amount => commission[:drivy_fee],
      }]
      @rental.commission = commission
      expect(@rental.generate_actions(final_price)).to eq(expect_result)
    end

    it "create rental with empty options shouldn't fail" do
      expect { Rental.new(@data, @cars, []) }.not_to raise_error()
    end

    it "should calculate the correct options fee" do
      expect_result = {
        "baby_seat" => 600,
        "gps" => 1500,
      }
      rental = Rental.new(@data, @cars, @options)
      expect(rental.options_fee).to eq(expect_result)
    end

    it "should calculate the correct options fee" do
      expect_result = {
        "additional_insurance" => 3000,
      }
      @options = [{ "id" => 3,
                    "rental_id" => 1,
                    "type" => "additional_insurance" }]
      rental = Rental.new(@data, @cars, @options)
      expect(rental.options_fee).to eq(expect_result)
    end

    it "format the result by action with options" do
      final_price = 10000
      commission = @rental.calcul_commission(final_price * COMMISSION_RATE, 2)
      expect_result = [{
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
        :amount => commission[:insurance_fee],
      },
                       {
        :who => "assistance",
        :type => "credit",
        :amount => commission[:assistance_fee],
      },
                       {
        :who => "drivy",
        :type => "credit",
        :amount => commission[:drivy_fee],
      }]
      @rental.commission = commission
      expect(@rental.generate_actions(final_price)).to eq(expect_result)
    end

    it "options fee should be correctly apply in the output" do
      final_price = 10000
      @options = [{ "id" => 1,
                    "rental_id" => 1,
                    "type" => "gps" },
                  { "id" => 2,
                    "rental_id" => 1,
                    "type" => "baby_seat" },
                  { "id" => 3,
                    "rental_id" => 1,
                    "type" => "additional_insurance" }]
      rental = Rental.new(@data, @cars, @options)
      expect_result = [{
        :who => "driver",
        :type => "debit",
        :amount => final_price + 5100,
      },
                       {
        :who => "owner",
        :type => "credit",
        :amount => (final_price * (1 - COMMISSION_RATE)).round + 2100,
      },
                       {
        :who => "insurance",
        :type => "credit",
        :amount => rental.commission[:insurance_fee],
      },
                       {
        :who => "assistance",
        :type => "credit",
        :amount => rental.commission[:assistance_fee],
      },
                       {
        :who => "drivy",
        :type => "credit",
        :amount => rental.commission[:drivy_fee] + 3000,
      }]
      expect(rental.generate_actions(final_price)).to eq(expect_result)
    end
  end
end
