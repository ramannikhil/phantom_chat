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

To Update the ChatRoom message duration configuration for any `chatroom_id` and use `msg_duration_in_minutes` to set the values, run the below command in the IEX console
  * Should have configure this in the UI, but can also use `iex console`
  ```
    alias PhantomChat.Schema.ChatRoom
    alias PhantomChat.Repo
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    PhanRepo.get(ChatRoom, chatroom_id) |> Ecto.Changeset.change(updated_at: now, msg_duration_in_minutes: 15) |> Repo.update()
  ```