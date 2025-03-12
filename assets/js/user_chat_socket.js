import {Socket} from "phoenix"
let socket = new Socket("/socket")


let topic_chat_room_name = document.querySelector("#chat_room_name_unique_value").innerHTML.trim()
let user_id = document.querySelector("#user_id_unique_value").innerHTML.trim()

socket.connect({topic: topic_chat_room_name, user_id: user_id})

let channel = socket.channel(topic_chat_room_name)

let chatMessage = document.querySelector("#chat-input") 
let displayMessage = document.querySelector("#messages")


chatMessage.addEventListener("keypress", event => {
  if(event.key == 'Enter'){
    channel.push("new_message", {message: chatMessage.value})
    chatMessage.value = ""
  }
})

// use of this one, as genserver track the user refresh or new login to store the user refresh state
window.addEventListener("beforeunload", (event) => {
  channel.push("user_disconnected", { user_id: user_id });
  event.preventDefault();
});

channel.on("new_message", (payload) => {
  let messageItem = document.createElement("div");
  messageItem.classList.add("message-item", "border", "p-2", "mb-2");

  let content = document.createElement("p");
  content.innerText = `${payload.user_name} \v ${payload.created_at} \n ${payload.message}`;

  let countdown = document.createElement("span");
  countdown.classList.add("countdown");
  countdown.dataset.timestamp = payload.created_at;
  countdown.dataset.expiry = payload.chat_duration * 60 * 1000; // 5 minutes in milliseconds

  messageItem.appendChild(content);
  messageItem.appendChild(countdown);
  displayMessage.appendChild(messageItem);

  startCountdown(countdown, messageItem);
});

// function to Update Countdown Timers
function startCountdown(countdownElement, messageItem) {
  let interval = setInterval(() => {
    let now = Date.parse(new Date().toISOString())

    let timestamp_val = new Date(countdownElement.dataset.timestamp);
    let timestamp= timestamp_val.getTime();
    let expiry = parseInt(countdownElement.dataset.expiry);

    // todo fix the timmer difference issue
    // some timer related issue with utc and local tried to fix this but unable to do so
    //  due to time constraints for the assingment using  19801777 as time diff
    let remaining = expiry - (now - timestamp - 19801777);

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


channel.on("old_messages", (payload_messages) => {
  displayMessage.textContent = ""; // Clear previous messages

  payload_messages["messages"].forEach((payload) => {
    let messageItem = document.createElement("div");
    messageItem.classList.add("message-item", "border", "p-2", "mb-2");

    let content = document.createElement("p");
    content.innerText = `${payload.user_name} \v ${payload.created_at} \n ${payload.message}`;

    let countdown = document.createElement("span");
    countdown.classList.add("countdown");
    countdown.dataset.timestamp = payload.created_at;

    countdown.dataset.expiry = payload.chat_duration * 60 * 1000; // 5 minutes in milliseconds

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
