# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(
  tests.css
  exiting_page_script.js
  tests.js
  clients.js
  questions.js
  test_availabilities.js
  summary_results.js
  charts_events.js
  picture_index.js
)

Rails.application.config.assets.precompile += %w[
  webgazer/webgazer.js
  heatmap.js/heatmap.min.js
  infinite-scroll/infinite-scroll.pkgd.min.js
]
