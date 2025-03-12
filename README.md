# PhantomChat

Application Setup
  * Run the migrations using `mix ecto.migrate`
  * Add the connections in the dev.exs for the postgres DB

  ```
  username: {user_name},
  password: {password},
  hostname: "localhost",
  database: "phantom_chat_dev",
  ```

* Add the connections in the test.exs for the postgres DB

  ```
  username: {user_name},
  password: {password},
  hostname: "localhost",
  database: "phantom_chat_test",
  ```


To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * To install dependencies `mix deps.get`
  

To run the test cases:  `mix test` 

