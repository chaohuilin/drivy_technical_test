require_relative("../main/main")

RSpec.describe Main do
  describe "#main" do
    it "creates with uncorrect file path" do
      expect { Main.new("data/abc") }.to raise_error(Errno::ENOENT)
    end

    it "file contains an invalid json" do
      expect {
        Main.new(File.expand_path("../datasets/invalid.json", __FILE__))
      }.to raise_error(JSON::ParserError)
    end

    it "file contains valid data" do
      expect_rentals = [{
        "id" => 1,
        "car_id" => 1,
        "start_date" => "2017-12-8",
        "end_date" => "2017-12-10",
        "distance" => 100,
      }]
      expect_cars = [{
        "id" => 1, "price_per_day" => 2000, "price_per_km" => 10,
      }]
      main = Main.new(File.expand_path("../datasets/input.json", __FILE__))
      expect(main.rentals).to eq(expect_rentals)
      expect(main.cars).to eq(expect_cars)
    end

    it "correctly generate the output by type" do
      expect_output = { :rentals => [
        {
          :id => 1,
          :price => 7000,
        },
      ] }
      main = Main.new(File.expand_path("../datasets/input.json", __FILE__))
      puts main.rentals
      main.generate_output_data(["price"])
      expect(main.output).to eq(expect_output)
    end

    it "correctly generate the output by type" do
    end
  end
end
