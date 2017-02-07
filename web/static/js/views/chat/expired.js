import MainView from '../main';
import * as utils from "../../utils";

export default class View extends MainView {
  mount() {
    super.mount();
    loadForm();
  }

  unmount() {
    super.unmount();

    // Specific logic here
    // console.log('PageNewView unmounted');
  }
}

let loadForm = () => {
  let button = document.getElementById("chat-submit")
  let form   = document.getElementById("chat-form-toggle")

  button.onclick = () => {
    Velocity(button, {opacity: 0}, 500, function(){
      button.style.display = "none"
      form.style.opacity = 0
      form.style.display = "block"

      Velocity(form, {opacity: 1}, 500)
    })
    return false;
  }
}