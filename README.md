# BrewPlot
Make sure you already installed Erlang, Elixir, Postgres and Node.

To start your Phoenix server:

  * Create .env.dev and .env.test files 
  * add Database URL for both env's respectively eg:
     export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/brew_plot_dev?ssl=false&pool_size=10" for dev
  * Run `mix setup` to install and setup dependencies
  * Run `cd assets`  `npm i`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Try it out
* Register your account by a email_id and password
* Click new
* type a name 
* Chose a data set name from https://github.com/plotly/datasets/tree/master eg: 2014_apple_stock
* Type a field name as expression eg: AAPL_y
* Save - will render a histogram
Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
