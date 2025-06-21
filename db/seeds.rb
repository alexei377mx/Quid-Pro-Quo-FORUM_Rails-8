# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_creds = Rails.application.credentials.admin

unless User.exists?(username: admin_creds[:username])
  user = User.new(
    username: admin_creds[:username],
    name: "Administrador",
    email: admin_creds[:email],
    password: admin_creds[:password],
    password_confirmation: admin_creds[:password],
    role: "admin"
  )
  user.save!(validate: false)
end
