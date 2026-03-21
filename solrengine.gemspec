require_relative "lib/solrengine/version"

Gem::Specification.new do |spec|
  spec.name = "solrengine"
  spec.version = Solrengine::VERSION
  spec.authors = [ "Jose Ferrer" ]
  spec.email = [ "estoy@moviendo.me" ]

  spec.summary = "The Rails framework for building Solana dapps"
  spec.description = "SolRengine gives Rails developers everything they need to build Solana dapps: wallet authentication (SIWS), RPC client, token portfolio, SOL transfers, and real-time WebSocket updates. One gem, full stack."
  spec.homepage = "https://github.com/solrengine/solrengine"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "solrengine-auth", "~> 0.1"
  spec.add_dependency "solrengine-rpc", "~> 0.1"
  spec.add_dependency "solrengine-tokens", "~> 0.1"
  spec.add_dependency "solrengine-transactions", "~> 0.1"
  spec.add_dependency "solrengine-realtime", "~> 0.1"
  spec.add_dependency "solrengine-programs", "~> 0.1"
end
