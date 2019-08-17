require_relative("../main/car")

RSpec.describe Car do
  describe "#car" do
    it "create a car with correct data" do
      car = Car.new({ "id" => 1, "price_per_day" => 2000, "price_per_km" => 10 })
      expect(car.id).to eq(1)
      expect(car.price_per_day).to eq(2000)
      expect(car.price_per_km).to eq(10)
    end

    it "create a car with no argument" do
      expect { Car.new() }.to raise_error(ArgumentError)
    end

    it "create a car with empty data" do
      car = Car.new({})
      expect(car.id).to eq(nil)
      expect(car.price_per_day).to eq(nil)
      expect(car.price_per_km).to eq(nil)
    end
  end
end
