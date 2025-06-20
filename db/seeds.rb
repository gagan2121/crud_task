require 'open-uri'
require 'faker'

puts "Deleting old data..."
Detail.delete_all
Section.delete_all
Product.delete_all

puts "Creating demo products..."

ACCESSORY_IMAGES = [
  'https://www.connectwell.com/ImageGen.ashx?image=/media/48231166/cts95_120n-without-aux.gif&width=100&compression=95&BgColor=C0C0C0',
  'https://www.connectwell.com/ImageGen.ashx?image=/media/48231169/cdttuft.gif&width=100&compression=95&BgColor=C0C0C0',
  'https://www.connectwell.com/ImageGen.ashx?image=/media/48231169/cdttuft.gif&width=100&compression=95&BgColor=C0C0C0',
  'https://www.connectwell.com/ImageGen.ashx?image=/media/48231220/cf4sp.gif&width=90&compression=95&Transparent=true&BgColor=C0C0C0&constrain=true&altimage=/media/No-Image-icon.png',
  'https://www.connectwell.com/ImageGen.ashx?image=/media/48231186/odl25a.gif&width=90&compression=95&Transparent=true&BgColor=C0C0C0&constrain=true&altimage=/media/No-Image-icon.png'
]

# Base data with variations
def generate_technical_data(i)
  {
    "Rated Voltage" => "#{rand(500..1500)} V",
    "Rated Current" => "#{rand(10..30)} A",
    "Tightening Torque" => "#{rand(0.2..0.8).round(1)} Nm",
    "Housing Material" => ["Polyamide", "Polycarbonate", "Thermoplastic"].sample,
    "Standard Colour" => ["Grey", "Black", "White", "Blue"].sample,
    "Product Function" => ["Feed Through", "Grounding", "Disconnect", "Fuse"].sample,
    "Wire Entry Orientation" => ["Side Entry", "Top Entry", "Bottom Entry"].sample,
    "Mounting Possibility" => ["DIN 32 Rail", "DIN 35 Rail", "Panel Mount", "PCB Mount"].sample,
    "Screw Size" => "M#{rand(2..5)}.#{rand(0..9)}",
    "Operated by" => ["Screwdriver", "Spring", "Lever"].sample,
    "Rated Surge Voltage" => "#{rand(4..12)} KV",
    "Pollution Degree" => rand(1..4).to_s
  }
end

def generate_ordering_info(i)
  size = rand(1.0..6.0).round(1)
  color = ["Grey", "Black", "White", "Blue", "Red", "Green"].sample
  type = ["Feed Through", "Grounding", "Disconnect", "Fuse"].sample

  {
    "CAT. NO." => "CTS#{size}#{('A'..'Z').to_a.sample(2).join}",
    "DESCRIPTION" => "#{size} sq.mm #{type} Terminal Block in #{color} colour",
    "STD. PACK" => "#{rand(50..200)}"
  }
end

def generate_connection_data(i)
  min_stranded = rand(0.2..1.0).round(1)
  max_stranded = (min_stranded + rand(1.0..5.0)).round(1)

  min_awg = rand(16..24)
  max_awg = min_awg - rand(4..10)

  {
    "Conductor Cross Section Stranded min." => "#{min_stranded} mm²",
    "Conductor Cross Section Stranded max." => "#{max_stranded} mm²",
    "Conductor Cross Section AWG/Kcmil min" => "#{min_awg} AWG",
    "Conductor Cross Section AWG/Kcmil max" => "#{max_awg} AWG",
    "Conductor Cross Section with Ferrule/Lug min" => "#{rand(0.2..1.0).round(1)} mm²",
    "Conductor Cross Section with Ferrule/Lug max" => "#{rand(1.5..6.0).round(1)} mm²"
  }
end

50.times do |i|
  product = Product.create!(
    name: "CTS#{rand(1.0..6.0).round(1)}#{('A'..'Z').to_a.sample(2).join} Demo #{i + 1}"
  )

  # Attach a random accessory image
  image_url = ACCESSORY_IMAGES.sample
  file = URI.open(image_url)
  product.image.attach(io: file, filename: "product_#{i + 1}.jpg")

  # Create sections with unique data for each product
  technical_data = generate_technical_data(i)
  ordering_info = generate_ordering_info(i)
  connection_data = generate_connection_data(i)

  # Create TECHNICAL DATA section
  technical_section = product.sections.create!(title: "TECHNICAL DATA")
  technical_data.each do |title, value|
    technical_section.details.create!(title: title, value: value)
  end

  # Create ORDERING INFORMATION section
  ordering_section = product.sections.create!(title: "ORDERING INFORMATION")
  ordering_info.each do |title, value|
    ordering_section.details.create!(title: title, value: value)
  end

  # Create CONNECTION DATA section
  connection_section = product.sections.create!(title: "CONNECTION DATA")
  connection_data.each do |title, value|
    connection_section.details.create!(title: title, value: value)
  end
end

puts "✅ Seeded 50 unique products with different sections and details."
