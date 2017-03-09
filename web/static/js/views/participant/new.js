import MainView from '../main';
import * as utils from "../../utils";
import * as recaptcha from "../../recaptcha";

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
  let userField  = document.getElementById("user-name")
  let grecaptcha = form.getElementsByClassName("g-recaptcha")[0]
  let verificationRequired = recaptcha.setVerifcationRequirement(grecaptcha)

  new Clipboard(urlBtn);

  formSubmit.onclick = () => {
    var section = utils.findAncestor(formSubmit, "participant-section")
    var sibling = section.nextElementSibling

    if (verificationRequired) {
      Velocity(formSubmit, {opacity: 0}, 500, function(){
        section.style.display = "none"
        sibling.style.opacity = 0
        sibling.style.display = "block"

        Velocity(sibling, {opacity: 1}, 500)
      })
    } else {
      submitParticipantForm();
    }

    return false;
  }

  form.onsubmit = () => {
    let value = userField.value.trim();
    userField.value = value;
  }
}

let submitParticipantForm = () => {
  let form = document.getElementById("participant-form")
  form.submit()
}

window.submitParticipantForm = submitParticipantForm
