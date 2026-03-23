class Solrengine::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def run_sub_generators
    generate "solrengine:auth:install"
    generate "solrengine:tokens:install"
    generate "solrengine:transactions:install"
  end

  def create_rpc_initializer
    template "solrengine_rpc.rb", "config/initializers/solrengine_rpc.rb"
  end

  def create_realtime_initializer
    template "solrengine_realtime.rb", "config/initializers/solrengine_realtime.rb"
  end

  def create_solana_monitor
    template "solana_monitor", "bin/solana_monitor"
    chmod "bin/solana_monitor", 0o755
  end

  def create_env_file
    template "env", ".env" unless File.exist?(".env")
  end

  def setup_multi_database
    template "database.yml", "config/database.yml", force: true
  end

  def setup_solid_queue_in_development
    dev_rb = "config/environments/development.rb"
    content = File.read(dev_rb)

    unless content.include?("solid_queue")
      inject_into_file dev_rb, after: "config.active_job.verbose_enqueue_logs = true\n" do
        <<~RUBY

          # SolRengine: Use Solid Queue for background jobs
          config.active_job.queue_adapter = :solid_queue
          config.solid_queue.connects_to = { database: { writing: :queue } }
        RUBY
      end
    end

    unless content.include?("solid_cache_store")
      gsub_file dev_rb,
        "config.cache_store = :memory_store",
        "config.cache_store = :solid_cache_store"
    end
  end

  def setup_solid_cable
    template "cable.yml", "config/cable.yml", force: true
  end

  def setup_cache_yml
    cache_yml = "config/cache.yml"
    if File.exist?(cache_yml)
      content = File.read(cache_yml)
      unless content.include?("database: cache")
        gsub_file cache_yml, "development:\n  <<: *default", "development:\n  database: cache\n  <<: *default"
      end
    end
  end

  def add_tailwind_gem_sources
    css_file = "app/assets/stylesheets/application.tailwind.css"
    return unless File.exist?(css_file)

    content = File.read(css_file)
    return if content.include?("solrengine")

    # Find gem paths for Tailwind to scan
    gem_paths = %w[solrengine-auth].filter_map do |gem_name|
      spec = Gem.loaded_specs[gem_name] || Bundler.load.specs.find { |s| s.name == gem_name }
      spec&.full_gem_path
    end

    return if gem_paths.empty?

    source_lines = gem_paths.map { |p| "@source \"#{p}/app\";" }.join("\n")

    append_to_file css_file, "\n/* SolRengine gem views */\n#{source_lines}\n"
  end

  def install_stimulus_controllers
    # Register shared controllers from @solrengine/wallet-utils
    index_js = "app/javascript/controllers/index.js"
    if File.exist?(index_js)
      content = File.read(index_js)
      unless content.include?("WalletController")
        append_to_file index_js, <<~JS

          import { WalletController } from "@solrengine/wallet-utils/controllers"
          application.register("wallet", WalletController)
        JS
      end
    end

    # Remove local wallet_controller.js if it exists (now in npm package)
    local_wallet = "app/javascript/controllers/wallet_controller.js"
    remove_file local_wallet if File.exist?(local_wallet)
  end

  def fix_stylesheet_link
    layout = "app/views/layouts/application.html.erb"
    if File.exist?(layout)
      content = File.read(layout)
      if content.include?("stylesheet_link_tag :app")
        gsub_file layout,
          "stylesheet_link_tag :app",
          'stylesheet_link_tag "application"'
      end
    end
  end

  def update_procfile
    procfile = "Procfile.dev"
    if File.exist?(procfile)
      append_to_file procfile, "jobs: bin/jobs\n" unless File.read(procfile).include?("jobs:")
      append_to_file procfile, "ws: bin/solana_monitor\n" unless File.read(procfile).include?("ws:")
    end
  end

  def show_post_install
    say "\n  SolRengine installed!", :green
    say ""
    say "  Next steps:"
    say "    1. rails db:prepare"
    say "    2. yarn add @solrengine/wallet-utils @solana/kit @wallet-standard/app @solana/wallet-standard-features @rails/actioncable"
    say "    3. Configure .env with your RPC URLs"
    say "    4. bin/dev"
    say "    5. Visit /auth/login"
    say ""
  end
end
