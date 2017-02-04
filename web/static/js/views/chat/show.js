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


// var sticky = {
//   sticky_after: 150,
//   init: function() {
//     this.scroll();
//     this.events();
//   },

//   scroll: function() {
//     this.header = document.getElementsByClassName("chat-menu")[0];

//     if(window.scrollY > this.header.offsetHeight) {
//       addClass(this.header, "clone");
//     } else {
//       removeClass(this.header, "clone");
//     }

//     if(window.scrollY > this.sticky_after) {
//       addClass(document.body, "down");
//     }
//     else {
//       removeClass(document.body, "down");
//     }
//   },

//   events: function() {
//     window.addEventListener("scroll", this.scroll.bind(this));
//   }
// };

// document.addEventListener("DOMContentLoaded", sticky.init.bind(sticky));

var convertTimeToLocal = function(el, time){
  var m     = moment.utc(time),
      local = m.local();
  el.innerHTML = local.format("h:mm A");
  el.title     = local.format("MMMM Do YYYY, h:mm A");
}

var processMessage = function(message){
  if (utils.hasClass(message, 'processed')) {
    return false;
  }

  utils.addClass(message, 'processed');

  var sibling     = message.previousElementSibling,
      time        = message.getElementsByTagName('time')[0],
      messageUser = message.dataset.user,
      messageTime = message.dataset.time;

  if (sibling == null) {
    utils.addClass(message, 'first');
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
  for (var message of messages) {
    processMessage(message)
  }
}

var loadChannel = function(){
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
    var count = Object.keys(presences).length
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

  let formatMessageBody = (body) => {
    let safe_body  = utils.escapeHtml(body)
    let paragraphs = safe_body.split("\n\n")
    let returned   = ""

    paragraphs.forEach(function(paragraph){
      returned += "<p>" + paragraph.trim() + "</p>"
    })

    returned = returned.replace(/\n/g, "<br>")

    return returned
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
        <div class="message-body">${formatMessageBody(message.body)}</div>
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

var loadHeaderLinks = function(){
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
  function getTimeRemaining(endtime) {
    var t = Date.parse(endtime) - Date.parse(new Date());
    var seconds = Math.floor((t / 1000) % 60);
    var minutes = Math.floor((t / 1000 / 60) % 60);
    var hours = Math.floor((t / (1000 * 60 * 60)) % 24);
    var days = Math.floor(t / (1000 * 60 * 60 * 24));
    return {
      'total': t,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds
    };
  }

  function initializeClock(id, endtime) {
    let clock = document.getElementById(id);
    let hoursSpan = clock.querySelector('.hours');
    let minutesSpan = clock.querySelector('.minutes');
    let secondsSpan = clock.querySelector('.seconds');

    function updateClock() {
      let t = getTimeRemaining(endtime);

      hoursSpan.innerHTML = ('0' + t.hours).slice(-2);
      minutesSpan.innerHTML = ('0' + t.minutes).slice(-2);
      secondsSpan.innerHTML = ('0' + t.seconds).slice(-2);

      if (t.total <= 0) {
        clearInterval(timeinterval);
      }
    }

    updateClock();
    let timeinterval = setInterval(updateClock, 1000);
  }

  let deadline = clock.dataset.deadline
  let m = moment.utc(deadline)

  initializeClock('clock', m.toDate());
}
