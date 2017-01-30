import MainView from '../main';
import {findAncestor} from '../../utils';

export default class View extends MainView {
  mount() {
    super.mount();
    loadControl();
  }

  unmount() {
    super.unmount();
  }
}

let initializeButton = function(button){
  let top    = findAncestor(button, "control-display")
  let bottom = top.nextElementSibling
  let column = findAncestor(top, "control-column")

  button.onclick = function(){
    let displayHeight = top.offsetHeight
    column.style.minHeight = displayHeight + "px"
    Velocity(top, {opacity: 0}, 500, function(){
      top.style.display = "none"
      bottom.style.opacity = 0
      bottom.style.display = "block"
      Velocity(bottom, {opacity: 1}, 500, function(){
        column.style.minHeight = null
      })
    })
    return false;
  }
}

var loadControl = function(){
  let buttons = document.getElementsByClassName("control-button")
  for (var button of buttons) {
    initializeButton(button)
  }
}

var submitForm = function(){
  let form = document.getElementById("chat-form")
  form.submit()
}

window.submitForm = submitForm