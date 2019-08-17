
require "json"
require_relative("./rental")

class Main
  attr_reader :rentals, :cars, :output

  def initialize(file_name)
    @rentals = []
    @cars = []
    @output = { :rentals => [] }
    get_file_data(file_name)
  end

  def get_file_data(file_name)
    begin
      file = File.read(file_name)
      data = JSON.parse(file)
      @rentals = data["rentals"]
      @cars = data["cars"]
      @options = data["options"] || []
    rescue Errno::ENOENT => e
      raise e, "the file is invalid"
    end
  end

  def generate_output_data(types)
    begin
      @rentals.map { |item|
        rental = Rental.new(item, @cars, @options)
        @output[:rentals] << rental.generate_data_by_types(types)
      }
    rescue NoMethodError, ArgumentError => e
      raise e, "cannot generate data based on the input"
    end
  end

  def export_file_data(path)
    begin
      File.open(path, "w") do |f|
        f.write(@output.to_json)
      end
    rescue Errno::ENOENT => e
      raise e, "Canno't generate the correct output file"
    end
  end
end
