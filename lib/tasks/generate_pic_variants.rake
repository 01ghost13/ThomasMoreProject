namespace :picture do
  desc "fills test from directory vendor/assets/images"

  task generate_variants: :environment do
    Picture.all.each do |pic|
      pic.small_variant
      pic.middle_variant
    end
  end
end
