paths = %w[config/initializers/*.rb app/**/*.rb lib/**/*.rb].map(&:freeze).freeze
paths.each do |path|
 Dir[File.join(Maiz.root, path)].each do |file|
   next if file.include?('initializers/autoloader') # skip me
   require file
 end
end
