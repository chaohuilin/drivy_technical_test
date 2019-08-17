require_relative("../main/main")

main = Main.new("data/input.json")
main.generate_output_data(["price"])
main.export_file_data("data/output.json")
