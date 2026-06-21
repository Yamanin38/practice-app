# config/initializers/solid_queue.rb
SolidQueue.connects_to = { database: { writing: :queue } }