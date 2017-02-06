import MainView from '../main';
import {Presence, Socket} from "phoenix";
import * as utils from "../../utils";

export default class View extends MainView {
  mount() {
    super.mount();
    loadMessages();
    loadChannel();
    loadHeaderLinks();
    loadClock();
  }

  unmount() {
    super.unmount();

    // Specific logic here
    // console.log('PageNewView unmounted');
  }
}

let convertTimeToLocal = function(el, time){
  let m     = moment.utc(time),
      local = m.local();
  el.innerHTML = local.format("h:mm A");
  el.title     = local.format("MMMM Do YYYY, h:mm A");
}

let md = new Remarkable('commonmark', {
  html: false,
  breaks: true,
  linkify: true,
  linkTarget: '_blank'
});
md.block.ruler.disable([ 'fences', 'table', 'footnote', 'heading', 'lheading', 'hr', 'list', 'blockquote' ]);
md.core.ruler.enable(['linkify']);

let initMessageTime = function(time, messageTime) {
  let parent = time.parentNode

  convertTimeToLocal(time, messageTime)

  time.onmouseover = function(){
    utils.addClass(parent, "show-ruler")
  }
  time.onmouseout = function(){
    utils.removeClass(parent, "show-ruler")
  }
  time.onclick = function(){
    utils.toggleClass(parent, "show-ruler")
  }
}
let processMessage = function(message){
  if (utils.hasClass(message, 'processed')) {
    return false;
  }

  utils.addClass(message, 'processed');

  let sibling     = message.previousElementSibling,
      siblingUser = sibling.dataset.user,
      siblingTime = sibling.dataset.time,
      time        = message.getElementsByTagName('time')[0],
      messageUser = message.dataset.user,
      messageTime = message.dataset.time;

  if (siblingTime == messageTime) {
    time.remove();
  } else {
    initMessageTime(time, messageTime);
  }

  if (siblingUser == messageUser) {
    let user = message.getElementsByClassName('message-author')[0]
    user.remove();
  }

  if (messageUser == "BOT") {
    let user = message.getElementsByClassName('message-author')[0]
    if (user != undefined)
      user.remove()

    utils.addClass(message, 'bot')
  } else {
    let body = message.getElementsByClassName('message-body')[0]

    body.innerHTML = md.render(body.innerHTML)
  }

  return message
}

let loadMessages = () => {
  let messages = document.getElementsByClassName('message');
  [...messages].forEach(function(message){
    processMessage(message)
  })
}

let loadChannel = () => {
  let chat      = document.getElementById("chat")
  let chatKey   = chat.dataset.chatAuthKey
  let chatToken = chat.dataset.chatToken
  let userKey   = chat.dataset.userAuthKey
  let socket    = new Socket("/socket", {params: {auth_key: userKey}})
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

  let userCount = document.getElementsByClassName("chat-users-count")[0]
  let render = (presences) => {
    let userList = document.getElementsByClassName("chat-users-list")[0]
    let count = Object.keys(presences).length
    userCount.innerHTML = "<i class='fa fa-group'></i><span class='user-count'> " + count + " " + (count == 1 ? "User" : "Users") + "</span> Online"
    userList.innerHTML = Presence.list(presences, listBy)
      .map(presence => `
        <li>${presence.user}</li>
      `)
      .join("")

    userList
  }

  // Channels
  let room = socket.channel("room:" + chatToken, {auth_key: chatKey})
  room.on("presence_state", state => {
    presences = Presence.syncState(presences, state)
    render(presences)
  })

  room.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff)
    render(presences)
  })

  room.join()


  let messageForm = document.getElementById("message-form")
  let messageInput = document.getElementById("message-body")

  let submitMessageForm = (e) => {
    let value = messageInput.value.trim()
    if (value != "") {
      room.push("message:new", value)
      messageInput.value = ""
      messageInput.focus()
    }

    return false;
  }

  messageInput.onkeydown = (e) => {
    if (e.keyCode == 13 && (e.ctrlKey || e.metaKey)) {
      messageInput.value = messageInput.value + "\n"
      return false;
    }
  }

  messageForm.onsubmit = submitMessageForm
  messageInput.onkeypress = (e) => {
    if (e.keyCode == 13 && !e.ctrlKey) {
      submitMessageForm(e);
      return false;
    }
  }

  let formatMessageBody = (message) => {
    let body = message.body
    if (message.user != "BOT")
      body = utils.escapeHtml(body)

    return body
  }

  let renderMessage = (message) => {
    let messageElement = document.createElement("li")
    messageElement.dataset.user = message.user
    messageElement.dataset.time = message.timestamp
    messageElement.innerHTML = `
      <div class="message-details">
        <div class="message-author">
          <span style="color: ${message.color}"><i class="fa fa-user-circle"></i> ${message.user}</span>
        </div>
        <div class="message-gutter">
          <time></time>
        </div>
      </div>
      <div class="message-content">
        <div class="message-body">${formatMessageBody(message)}</div>
      </div>
    `
    utils.addClass(messageElement, 'message')

    chat.appendChild(messageElement)
    processMessage(messageElement)
    window.scrollTo(0, document.body.scrollHeight)
  }

  let actions = document.getElementsByClassName("actions")[0]
  let menu = document.getElementsByClassName("chat-menu")[0]
  let sizeToFit = (e) => {
    let windowHeight = window.innerHeight
                  || document.documentElement.clientHeight
                  || document.body.clientHeight;

    chat.style.paddingBottom = (actions.offsetHeight + 10) + "px"
    chat.style.minHeight = (windowHeight - menu.offsetHeight) + "px"
  }

  utils.addEvent(window, "resize", sizeToFit)
  sizeToFit();

  room.on("message:new", message => renderMessage(message))
}

let loadHeaderLinks = function(){
  let shareLink  = document.getElementsByClassName("chat-share-link")[0]
  let usersLink  = document.getElementsByClassName("chat-users-count")[0]
  let buildModal = (modalName) => {
    let modal    = document.getElementById(modalName)
    let modalWrap = document.createElement('div')

    modalWrap.innerHTML = "<div class='container'><a class='modal-close'><i class='fa fa-close fa-2x'></i></a>" + modal.outerHTML + "</div>"
    utils.addClass(modalWrap, "modal-wrapper")
    modal.remove()
    document.body.appendChild(modalWrap)

    modal = modalWrap.getElementsByClassName("modal")[0]
    showModal(modalWrap)

    let modalClose = modalWrap.getElementsByClassName("modal-close")[0]
    utils.addEvent(modalClose, 'click', (e) => {
      toggleModal(modalName)
    })
    utils.addClass(modal, "is-built")

    return modal;
  }

  let showModal = (modalWrap) => {
    let visibleModal = document.getElementsByClassName('modal-wrapper is-visible')[0]

    if (visibleModal != undefined)
      hideModal(visibleModal);

    utils.addClass(modalWrap, 'is-visible');
    return modalWrap;
  }

  let hideModal = (modalWrap) => {
    utils.removeClass(modalWrap, 'is-visible');
    return modalWrap;
  }

  let toggleModal = (modalName) => {
    let modal = document.getElementById(modalName);

    if (modal == null)
      return false;

    if (utils.hasClass(modal, 'is-built')) {
      let modalWrap = utils.findAncestor(modal, 'modal-wrapper');

      if (utils.hasClass(modalWrap, 'is-visible')) {
        hideModal(modalWrap);
      } else {
        showModal(modalWrap);
      }
    } else {
      buildModal(modalName);
    }

    return modal;
  }

  utils.addEvent(shareLink, 'click', (e) => {
    let modal   = toggleModal('share-modal')
    let urlBtn = document.getElementById("url-button")
    let tokenBtn = document.getElementById("token-button")

    new Clipboard(urlBtn);
    new Clipboard(tokenBtn);
  })

  utils.addEvent(usersLink, 'click', (e) => {
    toggleModal('chat-users-modal');
  })
}

let loadClock = () => {
  let clock = document.getElementById('clock'),
      clockInterval;

  function getTimeRemaining(endtime) {
    let t = Date.parse(endtime) - Date.parse(new Date());
    let seconds = Math.floor((t / 1000) % 60);
    let minutes = Math.floor((t / 1000 / 60) % 60);
    let hours = Math.floor((t / (1000 * 60 * 60)) % 24);
    // let days = Math.floor(t / (1000 * 60 * 60 * 24));
    return {
      // 'total': t,
      // 'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds
    };
  }

  function initializeClock(clock, endtime) {
    let hoursSpan = clock.querySelector('.hours');
    let minutesSpan = clock.querySelector('.minutes');
    let secondsSpan = clock.querySelector('.seconds');

    function updateClock() {
      let t = getTimeRemaining(endtime);

      hoursSpan.innerHTML   = ('0' + t.hours).slice(-2);
      minutesSpan.innerHTML = ('0' + t.minutes).slice(-2);
      secondsSpan.innerHTML = ('0' + t.seconds).slice(-2);

      if (t.total <= 0) {
        clearInterval(clockInterval);
      }
    }

    updateClock();
    clockInterval = setInterval(updateClock, 1000);
  }

  let deadline = clock.dataset.deadline
  let m = moment.utc(deadline)

  initializeClock(clock, m.toDate())
}
