import MainView from '../main';
import {Presence, Socket} from "phoenix"

export default class View extends MainView {
  mount() {
    super.mount();
    loadMessages();
    loadChannel();
  }

  unmount() {
    super.unmount();

    // Specific logic here
    // console.log('PageNewView unmounted');
  }
}

var sortList = function(ul) {
  var new_ul = ul.cloneNode(false);
  var lis = [];
  for(var i = ul.childNodes.length; i--;){
    if(ul.childNodes[i].nodeName === 'LI')
      lis.push(ul.childNodes[i]);
  }
  lis.sort(function(a, b){
    return a.children[0].textContent.localeCompare(b.children[0].textContent);
    // return parseInt(b.childNodes[0].data , 10) - parseInt(a.childNodes[0].data , 10);
  });
  for(var i = 0; i < lis.length; i++)
    new_ul.appendChild(lis[i]);

  if (ul.parentNode != null)
    ul.parentNode.replaceChild(new_ul, ul);
}

var hasClass = function(el, className) {
  return (' ' + el.className + ' ').indexOf(' ' + className + ' ') > -1;
}

var addClass = function(el, className) {
  if (el.classList)
    el.classList.add(className)
  else if (!hasClass(el, className)) el.className += " " + className
}

var removeClass = function(el, className) {
  if (el.classList)
    el.classList.remove(className)
  else if (hasClass(el, className)) {
    var reg = new RegExp('(\\s|^)' + className + '(\\s|$)')
    el.className=el.className.replace(reg, ' ')
  }
}

var convertTimeToLocal = function(el, time){
  var m     = moment.utc(time),
      local = m.local();
  el.innerHTML = local.format("h:mm A");
  el.title     = local.format("MMMM Do YYYY, h:mm A");
}

var processMessage = function(message){
  if (hasClass(message, 'processed')) {
    return false;
  }

  addClass(message, 'processed');

  var sibling     = message.previousElementSibling,
      time        = message.getElementsByTagName('time')[0],
      messageUser = message.dataset.user,
      messageTime = message.dataset.time;

  if (sibling == null) {
    convertTimeToLocal(time, messageTime);
  } else {
    var siblingUser = sibling.dataset.user,
        siblingTime = sibling.dataset.time;

    if (siblingTime == messageTime) {
      time.remove();
    } else {
      convertTimeToLocal(time, messageTime);
    }

    if (siblingUser == messageUser) {
      var user = message.getElementsByClassName('message-author')[0]
      user.remove();
    }

  }

  return message;
}

var loadMessages = function(){
  var messages = document.getElementsByClassName('message');
  for (var i = 0; i < messages.length; i++) {
    processMessage(messages[i]);
  }

}

var loadChannel = function(){
  let chat      = document.getElementsByClassName("chat")[0]
  let chatToken = chat.dataset.chatToken
  let chatName  = chat.dataset.chatName
  let userToken = chat.dataset.userToken
  let socket    = new Socket("/socket", {params: {token: userToken}})
  socket.connect()

  let presences = {}

  let formatTimestamp = (timestamp) => {
    let date = new Date(timestamp)
    return date.toLocaleTimeString()
  }
  let listBy = (user, {metas: metas}) => {
    return {
      user: user,
      onlineAt: formatTimestamp(metas[0].online_at)
    }
  }

  let userList = document.getElementById("chat-users-list")
  let render = (presences) => {
    userList.innerHTML = Presence.list(presences, listBy)
      .map(presence => `
        <li>
          <small>${presence.user}</small>
        </li>
      `)
      .join("")

    userList
  }

  // Channels
  let room = socket.channel("room:" + chatName, {token: chatToken})
  room.on("presence_state", state => {
    presences = Presence.syncState(presences, state)
    render(presences)
  })

  room.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff)
    render(presences)
  })

  room.join()

  let messageInput = document.getElementById("message_body")
  messageInput.addEventListener("keypress", (e) => {
    if (e.keyCode == 13 && messageInput.value != "") {
      room.push("message:new", messageInput.value)
      messageInput.value = ""
      return false;
    }
  })

  let renderMessage = (message) => {
    let messageElement = document.createElement("li")
    messageElement.dataset.user = message.user
    messageElement.dataset.time = message.timestamp
    messageElement.innerHTML = `
      <div class="message-details">
        <div class="message-author">
          <span style="color: ${message.color}">${message.user}</span>
        </div>
        <div class="message-gutter">
          <time></time>
        </div>
      </div>
      <div class="message-content">
        <p class="message-body">${message.body}</p>
      </div>
    `
    addClass(messageElement, 'message')

    chat.appendChild(messageElement)
    processMessage(messageElement)
    window.scrollTo(0, document.body.scrollHeight)
  }

  room.on("message:new", message => renderMessage(message))
}
