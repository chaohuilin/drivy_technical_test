require_relative("../main/main")

main = Main.new(File.expand_path("../data/input.json", __FILE__))
main.generate_output_data(["price_with_discount"])
main.export_file_data(File.expand_path("../data/output.json", __FILE__))
