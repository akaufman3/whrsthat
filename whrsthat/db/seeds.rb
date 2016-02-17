# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(phone: '6468078717', fname: 'Eric', lname_initial: 'B', email: 'antwisted@gmail.com', prof_img_url: '/mugato_temp_logo.png', password: 'text')
User.create(phone: '4154975981', fname: 'Amelia', lname_initial: 'K', email: 'amelia.kaufman@gmail.com', prof_img_url: nil, password: '1234')	