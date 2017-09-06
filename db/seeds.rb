# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Rank.find_or_create_by!(name: "Tenderfoot")
Rank.find_or_create_by!(name: "2nd Class")
Rank.find_or_create_by!(name: "1st Class")
Rank.find_or_create_by!(name: "Star")
Rank.find_or_create_by!(name: "Life")
Rank.find_or_create_by!(name: "Eagle")

MeritBadge.find_or_create_by!(name: "First Aid")
MeritBadge.find_or_create_by!(name: "Lifesaving")
MeritBadge.find_or_create_by!(name: "Canoeing")
MeritBadge.find_or_create_by!(name: "Snow Sports")
MeritBadge.find_or_create_by!(name: "Watercraft")
MeritBadge.find_or_create_by!(name: "Leatherwork")
MeritBadge.find_or_create_by!(name: "Bicycling")
MeritBadge.find_or_create_by!(name: "Personal Fitness")

