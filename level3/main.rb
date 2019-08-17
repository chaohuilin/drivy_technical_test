require_relative("../main/main")

main = Main.new("data/input.json")
main.generate_output_data(["price_with_discount", "commission"])
main.export_file_data("data/output.json")
