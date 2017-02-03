import MainView from '../main';

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
  let button = document.getElementById("participant-submit")
  let form   = document.getElementById("participant-form")

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

let submitParticipantForm = () => {
  let form = document.getElementById("participant-form")
  form.submit()
}

window.submitParticipantForm = submitParticipantForm
