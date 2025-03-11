// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/phantom_chat_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
// todo remove this usertoken, as there is no token involved
let socket = new Socket("/socket", {params: {token1: "testing"}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/phantom_chat_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/phantom_chat_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/phantom_chat_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
// socket.connect()




// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `room` and the
// subtopic is its id - in this case lobby:

let topic_chat_room_name = document.querySelector("#chat_room_name_unique_value").innerHTML.trim()
let user_id = document.querySelector("#user_id_unique_value").innerHTML.trim()

socket.connect({topic: topic_chat_room_name, user_id: user_id})


// todo temp code below
// let socket_connect_vals = socket.check_user_id_exists()
// console.log("check the socket_connect_vals " + JSON.stringify(socket) );
// console.log("check the socket_connect_vals " + JSON.stringify(socket) );


// todo pass the user_id in the params in place of this {temp_val: "123"}
// use {user_id: user_id}
// fetch the user_id from the plugg conn, 
// pass the user_id from the controller to this channel
let channel = socket.channel(topic_chat_room_name)
// let channel = socket.channel("room:lobby", {temp_val: "123"})
console.log("check the topic_chat_room_name " + topic_chat_room_name);




let chatMessage = document.querySelector("#chat-input") 
let displayMessage = document.querySelector("#messages")
let timerDurationLeft = document.querySelector("#timeleft")

chatMessage.addEventListener("keypress", event => {
  if(event.key == 'Enter'){
    channel.push("new_message", {message: chatMessage.value})
    chatMessage.value = ""
  }
})

// todo no use of this one or use genserver to store the user refresh state
window.addEventListener("beforeunload", (event) => {
  // Notify the channel that the user is disconnecting
  channel.push("user_disconnected", { user_id: user_id });

  // Optionally, prevent default behavior (e.g., showing a confirmation popup)
  event.preventDefault();
  // event.returnValue = ""; // This is required for some browsers to show a warning
});

channel.on("new_message", (payload) => {
  let messageItem = document.createElement("div");
  messageItem.classList.add("message-item", "border", "p-2", "mb-2");

  let content = document.createElement("p");
  // content.innerText = `${payload.user_name} \v ${formatTime(payload.created_at)} \n ${payload.message}`;
  content.innerText = `${payload.user_name} \v ${payload.created_at} \n ${payload.message}`;

  let countdown = document.createElement("span");
  countdown.classList.add("countdown");
  countdown.dataset.timestamp = payload.created_at;
  countdown.dataset.expiry = 300000; // 5 minutes in milliseconds

  messageItem.appendChild(content);
  messageItem.appendChild(countdown);
  displayMessage.appendChild(messageItem);

  startCountdown(countdown, messageItem);
});

// 🕒 Function to Update Countdown Timers
function startCountdown(countdownElement, messageItem) {
  let interval = setInterval(() => {
    
    // let now = Date.now();
    let now = Date.parse(new Date().toISOString())
    // let timestamp = parseInt(countdownElement.dataset.timestamp);
    let timestamp_val = new Date(countdownElement.dataset.timestamp);
    let timestamp= timestamp_val.getTime();
    let expiry = parseInt(countdownElement.dataset.expiry);
    console.log("called startCountdown timestamp_val " + timestamp_val);
    console.log("called startCountdown timestamp " + timestamp);
    console.log("called startCountdown now " + now);
    
    // todo fix the timmer difference issue
    let remaining = expiry - (now - timestamp - 19801777);
    console.log("called startCountdown remaining " + remaining);

    if (remaining > 0) {
      let minutes = Math.floor((remaining / 1000) / 60);
      let seconds = Math.floor((remaining / 1000) % 60);
      countdownElement.innerText = `Expires in: ${minutes}m ${seconds}s`;
    } else {
      clearInterval(interval);
      countdownElement.innerText = "Expired";
      messageItem.classList.add("opacity-50");
      setTimeout(() => messageItem.remove(), 5000); // Remove 5 seconds after expiry
    }
  }, 1000);
}

// 🕒 Format Time Function
function formatTime(timestamp) {
  console.log("check the timestamp vals " + timestamp);
  
  let date = new Date(timestamp);
  console.log("check the date vals " + date.toDateString());
  console.log("check the getDate vals " + date.getDate());
  // return date.toLocaleTimeString();
  return date;
}


// channel.on("new_message", payload => {
//   let messageItem = document.createElement("p")
//   // messageItem.innerText = `[${Date()}] ${payload.message}`
//   messageItem.innerText = `${payload.user_name} \v ${payload.created_at} \n ${payload.message} 
//   \n`
//   // todo handle the message disappear
//   // adding the fade effects
// //   setTimeout(() => {
// //     messageItem.remove()
// //  }, 10000);


// //   var disappearTime = 10;

// //  var x = setInterval(function() {
// //   disappearTime = disappearTime - 1;

// //   setTimeout(() =>{
// //     timer_value.remove();
// //   }, 1000)
 
// //   console.log("check the disappearTime " + disappearTime);
  

// //   let timer_value = document.createElement("p")
// //   timer_value.innerText = `Time left ${disappearTime}`

// //   // If the count down is over, write some text 
// //   if (disappearTime <= 0) {
// //     clearInterval(x);
// //     document.getElementById("timeleft").innerHTML = "";
// //   }
// //  displayMessage.appendChild(timer_value)
 
// // }, 1000);

// displayMessage.appendChild(messageItem)
// })

// channel.on("old_messages", payload => {
//   displayMessage.textContent= ""

//   console.log("called old messages");
  
//   let messageItem;
//   payload["messages"].map((x) => {
//     messageItem = document.createElement("p")

//     // messageItem.innerText = ` ${x.created_at} ${x.message}`
//      messageItem.innerText = `${x.user_name} \v ${x.created_at} \n ${x.message} 
//   \n`
//     displayMessage.appendChild(messageItem)
//   })
// })


// channel.on("old_messages", payload_messages => {
//   displayMessage.textContent= ""  
//   // let messageItem;
//   let messageItem = document.createElement("div");
//   payload_messages["messages"].map((payload) => {
//     // messageItem = document.createElement("p")
//     messageItem.classList.add("message-item", "border", "p-2", "mb-2");

//     let content = document.createElement("p");
//     content.innerText = `${payload.user_name} \v ${formatTime(payload.created_at)} \n ${payload.message}`;
  
//     let countdown = document.createElement("span");
//     countdown.classList.add("countdown");
//     countdown.dataset.timestamp = payload.created_at;
//     countdown.dataset.expiry = 300000; // 5 minutes in milliseconds
  
//     messageItem.appendChild(content);
//     messageItem.appendChild(countdown);
//     displayMessage.appendChild(messageItem);
  
//     startCountdown(countdown, messageItem);

//     // messageItem.innerText = ` ${x.created_at} ${x.message}`
//   //    messageItem.innerText = `${payload.user_name} \v ${x.created_at} \n ${x.message} 
//   // \n`
//     displayMessage.appendChild(messageItem)
//   })
// })

channel.on("old_messages", (payload_messages) => {
  displayMessage.textContent = ""; // Clear previous messages

  payload_messages["messages"].forEach((payload) => {
    let messageItem = document.createElement("div");
    messageItem.classList.add("message-item", "border", "p-2", "mb-2");

    let content = document.createElement("p");
    // content.innerText = `${payload.user_name} \v ${formatTime(payload.created_at)} \n ${payload.message}`;
    content.innerText = `${payload.user_name} \v ${payload.created_at} \n ${payload.message}`;

    let countdown = document.createElement("span");
    countdown.classList.add("countdown");
    countdown.dataset.timestamp = payload.created_at;
    // todo use the chatroom timer instead of hardcoding
    countdown.dataset.expiry = 300000; // 5 minutes in milliseconds

    messageItem.appendChild(content);
    messageItem.appendChild(countdown);
    displayMessage.appendChild(messageItem);

    startCountdown(countdown, messageItem); // Start countdown timer
  });
});



channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
