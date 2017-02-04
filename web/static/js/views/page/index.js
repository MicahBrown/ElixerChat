import MainView from '../main';
import * as utils from '../../utils';
import * as request from '../../ajax';

export default class View extends MainView {
  mount() {
    super.mount();
    loadIndex();
  }

  unmount() {
    super.unmount();
  }
}

let loadIndex = function(){
  let initializeButton = function(button){
    let top    = utils.findAncestor(button, "control-display")
    let bottom = top.nextElementSibling
    let column = utils.findAncestor(top, "control-column")

    button.onclick = function(){
      let displayHeight = top.offsetHeight
      column.style.minHeight = displayHeight + "px"
      Velocity(top, {opacity: 0}, 500, function(){
        top.style.display = "none"
        bottom.style.opacity = 0
        bottom.style.display = "block"
        Velocity(bottom, {opacity: 1}, 500, function(){
          column.style.minHeight = null

          sizeControls()
        })
      })

      return false;
    }
  }

  let form = document.getElementById("search-form")

  var submitTokenForm = function(){
    let input = document.getElementById("search_name")
    let value = input.value.trim()
    let column = utils.findAncestor(input, "control-column")

    if (value != "" && !utils.hasClass(column, "submitting")) {
      utils.addClass(column, "submitting")

      request['ajax'].get("/search", {q: value}, function(response){
        let resp = null

        try {
          resp = JSON.parse(response)
        } catch(err) {
          alert('An error occurred.')
        }

        if (resp != null && resp['data'] != null && resp['data']['name'] != null) {
          window.location = "/chats/" + resp['data']['name']
        }

        utils.removeClass(column, "submitting")
      })
    }

    return false;
  }

  var loadRoomSearch = function(){
    if (form != null)
      form.onsubmit = submitTokenForm
  }

  let control = document.getElementsByClassName("control")[0]
  let columns = control.getElementsByClassName("control-column")
  let overlay = control.getElementsByClassName("control-overlay")[0]

  var sizeControls = function(){
    let index = 0

    for (var column of columns) {
      let floatStyle = window.getComputedStyle(column)["float"]
      let colOverlay = overlay.getElementsByClassName("control-background")[index]

      if (floatStyle == "none" ) {
        colOverlay.style.height = column.offsetHeight + "px"
      } else {
        colOverlay.style.height = null
      }

      index += 1
    }
  }

  var loadControl = function(){
    if (control == null || columns == null || overlay == null) {
      return false
    }

    let buttons = document.getElementsByClassName("control-button")
    for (var button of buttons) {
      initializeButton(button)
    }

    utils.addEvent(window, "resize", sizeControls)
    loadRoomSearch()
    sizeControls()
  }

  loadControl()
}

var submitChatForm = function(){
  let form = document.getElementById("chat-form")
  form.submit()
}

window.submitChatForm = submitChatForm
