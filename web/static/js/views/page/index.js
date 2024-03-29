import MainView from '../main';
import * as utils from '../../utils';
import * as recaptcha from '../../recaptcha';
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
    let grecaptcha = bottom.getElementsByClassName("g-recaptcha")[0]
    let verificationRequired = recaptcha.setVerifcationRequirement(grecaptcha)

    button.onclick = function(){
      if (verificationRequired) {
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
      } else {
        submitChatForm()
      }

      return false;
    }
  }

  let form = document.getElementById("search-form")

  var submitTokenForm = function(){
    let input = document.getElementById("search_token")
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

        if (resp != null) {
          if (resp['data'] != null && resp['data']['token'] != null) {
            window.location = "/chats/" + resp['data']['token']
          } else {
            if (input.nextElementSibling != null) {
              input.nextElementSibling.remove()
            }

            let newNode = document.createElement("div")
            newNode.innerHTML = "<i class='fa fa-warning'></i> Invalid Token"
            newNode.style.opacity = 0
            utils.addClass(newNode, "error")
            utils.insertAfter(input, newNode)

            Velocity(newNode, {opacity: 1}, 500)
            sizeControls()
          }
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
  let columnsAry = [].slice.call(columns)
  let overlay = control.getElementsByClassName("control-overlay")[0]

  var sizeControls = function(){
    let index = 0

    columnsAry.forEach(function(column){
      let floatStyle = window.getComputedStyle(column)["float"]
      let colOverlay = overlay.getElementsByClassName("control-background")[index]

      if (floatStyle == "none" ) {
        colOverlay.style.height = column.offsetHeight + "px"
      } else {
        colOverlay.style.height = null
      }

      index += 1;
    });
  }

  let loadControl = () => {
    if (control == null || columns == null || overlay == null) {
      return false
    }

    let buttons = document.getElementsByClassName("control-button")
    let buttonsAry = [].slice.call(buttons)
    buttonsAry.forEach(function(button){
      initializeButton(button)
    });

    utils.addEvent(window, "resize", sizeControls);
    loadRoomSearch();
    sizeControls();
  }

  loadControl();
}

var submitChatForm = function(){
  let form = document.getElementById("chat-form")
  form.submit()
}

window.submitChatForm = submitChatForm
