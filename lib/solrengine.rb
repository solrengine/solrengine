require_relative "solrengine/version"

require "solrengine/rpc"
require "solrengine/auth"
require "solrengine/tokens"
require "solrengine/transactions"
require "solrengine/realtime"
require "solrengine/programs"

module Solrengine
  class Error < StandardError; end
end
