require 'rspec/core/rake_task'
require 'pg'
RSpec::Core::RakeTask.new(:spec)

task default: [:create_db, :spec]

task :create_db do
  db = PG::connect(dbname: 'postgres')
  file = File.open('schema.sql')
  content = file.read
  db.exec(content)
  file = File.open('populate.sql')
  content = file.read
  db.exec(content)
end
