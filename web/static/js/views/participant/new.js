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

}
