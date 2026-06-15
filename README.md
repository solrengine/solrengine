# SolRengine

The Rails framework for building Solana dapps.

Wallet authentication, token portfolio, SOL transfers, real-time WebSocket updates, and custom program interaction — using the Rails 8 default stack.

## Quick Start

### 1. Create a Rails app

```bash
rails new my_solana_app --css=tailwind --javascript=esbuild
cd my_solana_app
```

### 2. Add SolRengine to your Gemfile

```ruby
gem "solrengine"
gem "dotenv-rails", group: [:development, :test]
```

### 3. Install

```bash
bundle install
rails generate solrengine:install
rails db:prepare
yarn add @solrengine/wallet-utils @solana/kit @wallet-standard/app @solana/wallet-standard-features @rails/actioncable
```

### 4. Start

```bash
bin/dev
```

Visit `localhost:3000/auth/login` — connect your wallet and sign in.

## What the Generator Does

- Creates `User` model with wallet auth (SIWS)
- Creates `Token` model with Jupiter metadata
- Creates `Transfer` model with confirmation tracking
- Sets up multi-database SQLite (primary, cache, queue, cable)
- Configures Solid Queue, Solid Cache, and Solid Cable for development
- Registers wallet controller from [@solrengine/wallet-utils](https://github.com/solrengine/wallet-utils)
- Adds Tailwind sources for gem views
- Creates `.env` template, `bin/solana_monitor`, and Procfile entries
- Mounts auth engine at `/auth` (login, nonce, verify, logout)

## What You Get

| Gem | What |
|-----|------|
| [**solrengine-auth**](https://github.com/solrengine/auth) | SIWS wallet authentication (any Wallet Standard wallet) |
| [**solrengine-rpc**](https://github.com/solrengine/rpc) | Solana JSON-RPC client with SSL fix and multi-network config |
| [**solrengine-tokens**](https://github.com/solrengine/tokens) | Token metadata from Jupiter, USD prices, wallet portfolio |
| [**solrengine-transactions**](https://github.com/solrengine/transactions) | SOL transfers with @solana/kit, confirmation tracking |
| [**solrengine-realtime**](https://github.com/solrengine/realtime) | WebSocket account monitoring, Turbo Streams push updates |
| [**solrengine-programs**](https://github.com/solrengine/programs) | Anchor IDL parsing, Borsh serialization, program account models, instruction builders |
| [**solana-sdp**](https://github.com/solrengine/solana-sdp) | Custodial path — plain-Ruby client for the Solana Developer Platform wallets + payments API |
| [**solrengine-sdp**](https://github.com/solrengine/solrengine-sdp) | Custodial path — Rails engine: Wallet-per-User provisioning, tracked transfers, live balances |

Each gem can be used independently or together via the `solrengine` meta-gem.

### Two custody models

The first six gems cover the **connect-your-wallet** path: your users bring their own wallets and keep their own keys. The two SDP gems cover the **Wallet-per-User** path: users sign up with an email and your app provisions a custody wallet for each of them through the [Solana Developer Platform](https://github.com/solana-foundation/solana-developer-platform) (SDP). Both are first-class, and they mix in one app.

The SDP gems are not installed by this meta-gem — the custodial path is opt-in (`gem "solrengine-sdp"`), and it has real prerequisites: a running SDP instance, a managed custody provider (e.g. Privy), and Kora as SDP's fee-payment provider. SDP is pre-mainnet and devnet-oriented. See [solrengine.org/docs/sdp](https://solrengine.org/docs/sdp).

## Custom Program Interaction

Interact with any Anchor program by generating from its IDL:

```bash
rails generate solrengine:program PiggyBank path/to/piggy_bank.json
```

This scaffolds account models, instruction builders, and a Stimulus controller. See [solrengine-programs](https://github.com/solrengine/programs) for details.

## Configuration

The generator creates initializers automatically. Customize as needed:

```ruby
# config/initializers/solrengine_auth.rb
Solrengine::Auth.configure do |config|
  config.domain = ENV.fetch("APP_DOMAIN", "localhost")
  config.nonce_ttl = 5.minutes
  config.after_sign_in_path = "/dashboard"
  config.after_sign_out_path = "/"
end

# config/initializers/solrengine_rpc.rb
Solrengine::Rpc.configure do |config|
  config.network = ENV.fetch("SOLANA_NETWORK", "mainnet")
end
```

## Environment Variables

The generator creates a `.env` file. Configure with your RPC URLs:

```
SOLANA_NETWORK=devnet
SOLANA_RPC_URL=https://mainnet.helius-rpc.com/?api-key=xxx
SOLANA_WS_URL=wss://mainnet.helius-rpc.com/?api-key=xxx
SOLANA_RPC_DEVNET_URL=https://devnet.helius-rpc.com/?api-key=xxx
SOLANA_WS_DEVNET_URL=wss://devnet.helius-rpc.com/?api-key=xxx
APP_DOMAIN=myapp.com
```

Free RPC keys available at [helius.dev](https://helius.dev).

## Building After Auth

After sign-in, the app redirects to `/dashboard` (configurable). Create your own:

```ruby
# config/routes.rb
root "dashboard#show"

# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate!

  def show
    @wallet = current_user.wallet_address
    @portfolio = Solrengine::Tokens::Portfolio.new(@wallet)
    @tokens = @portfolio.tokens
    @transactions = @portfolio.recent_transactions
  end
end
```

`current_user`, `logged_in?`, and `authenticate!` are added to your ApplicationController by the generator.

## Processes

`bin/dev` starts 5 processes via Procfile.dev:

| Process | What |
|---------|------|
| web | Rails server (Puma) |
| js | esbuild watch |
| css | Tailwind watch |
| jobs | Solid Queue worker |
| ws | Solana WebSocket monitor |

## Showcase

- [**WalletTrain**](https://github.com/solrengine/wallet-train) — Solana wallet with token portfolio, SOL transfers, and real-time updates.
- [**PiggyBank**](https://github.com/solrengine/piggybank) — Time-locked SOL savings using a custom Anchor program via `solrengine-programs`.

## License

MIT. A [moviendo.me](https://moviendo.me) project.
