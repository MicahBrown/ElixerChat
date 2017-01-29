import MainView from '../main';
import {Presence, Socket} from "phoenix";
import {findAncestor, hasClass, addClass, removeClass, addEvent} from "../../utils";

export default class View extends MainView {
  mount() {
    super.mount();
    loadMessages();
    loadChannel();
    loadHeaderLinks();
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
  if (hasClass(message, 'processed')) {
    return false;
  }

  addClass(message, 'processed');

  var sibling     = message.previousElementSibling,
      time        = message.getElementsByTagName('time')[0],
      messageUser = message.dataset.user,
      messageTime = message.dataset.time;

  if (sibling == null) {
    addClass(message, 'first');
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


  let messageForm = document.getElementById("message-form")
  let messageInput = document.getElementById("message-body")

  let submitForm = (e) => {
    if (messageInput.value.trim != "") {
      room.push("message:new", messageInput.value)
      messageInput.value = ""
    }

    return false;
  }

  messageInput.onkeydown = (e) => {
    if (e.keyCode == 13 && (e.ctrlKey || e.metaKey)) {
      messageInput.value = messageInput.value + "\n"
      return false;
    }
  }

  messageForm.onsubmit = submitForm
  messageInput.onkeypress = (e) => {
    if (e.keyCode == 13 && !e.ctrlKey) {
      submitForm(e);
      return false;
    }
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
        <p class="message-body">${message.body}</p>
      </div>
    `
    addClass(messageElement, 'message')

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

  addEvent(window, "resize", sizeToFit)
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
    addClass(modalWrap, "modal-wrapper")
    modal.remove()
    document.body.appendChild(modalWrap)

    modal = modalWrap.getElementsByClassName("modal")[0]
    showModal(modalWrap)

    let modalClose = modalWrap.getElementsByClassName("modal-close")[0]
    addEvent(modalClose, 'click', (e) => {
      toggleModal(modalName)
    })
    addClass(modal, "is-built")

    return modal;
  }

  let showModal = (modalWrap) => {
    let visibleModal = document.getElementsByClassName('modal-wrapper is-visible')[0]

    if (visibleModal != undefined)
      hideModal(visibleModal);

    addClass(modalWrap, 'is-visible');
    return modalWrap;
  }

  let hideModal = (modalWrap) => {
    removeClass(modalWrap, 'is-visible');
    return modalWrap;
  }

  let toggleModal = (modalName) => {
    let modal = document.getElementById(modalName);

    if (modal == null)
      return false;

    if (hasClass(modal, 'is-built')) {
      let modalWrap = findAncestor(modal, 'modal-wrapper');

      if (hasClass(modalWrap, 'is-visible')) {
        hideModal(modalWrap);
      } else {
        showModal(modalWrap);
      }
    } else {
      buildModal(modalName);
    }

    return modal;
  }

  addEvent(shareLink, 'click', (e) => {
    let modal = toggleModal('share-modal');

    let copyBtn = modal.getElementsByTagName("button")[0]
    new Clipboard(copyBtn);
  })

  addEvent(usersLink, 'click', (e) => {
    toggleModal('chat-users-modal');
  })
}
