import MainView from '../main';
import * as utils from "../../utils";

export default class View extends MainView {
  mount() {
    super.mount();
    loadParticipantForm();
  }

  unmount() {
    super.unmount();
  }
}

let loadParticipantForm = () => {
  let formSubmit = document.getElementById("participant-submit")
  let form       = document.getElementById("participant-form")
  let urlBtn     = document.getElementById("url-button")

  new Clipboard(urlBtn);

  formSubmit.onclick = () => {
    Velocity(formSubmit, {opacity: 0}, 500, function(){
      var section = utils.findAncestor(formSubmit, "participant-section")
      var sibling = section.nextElementSibling

      section.style.display = "none"
      sibling.style.opacity = 0
      sibling.style.display = "block"

      Velocity(sibling, {opacity: 1}, 500)
    })
    return false;
  }
}

let submitParticipantForm = () => {
  let form = document.getElementById("participant-form")
  form.submit()
}

window.submitParticipantForm = submitParticipantForm
