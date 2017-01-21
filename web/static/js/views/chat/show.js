import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    loadMessager();
  }

  unmount() {
    super.unmount();

    // Specific logic here
    // console.log('PageNewView unmounted');
  }
}


var loadMessager = function(){

  var hasClass = function(el, className) {
    return (' ' + el.className + ' ').indexOf(' ' + className + ' ') > -1;
  }

  var addClass = function(el, className) {
    if (el.classList)
      el.classList.add(className)
    else if (!hasClass(el, className)) el.className += " " + className
  }

  var removeClass = function(el, className) {
    if (el.classList)
      el.classList.remove(className)
    else if (hasClass(el, className)) {
      var reg = new RegExp('(\\s|^)' + className + '(\\s|$)')
      el.className=el.className.replace(reg, ' ')
    }
  }

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

  var messages = document.getElementsByClassName('message');
  for (var i = 0; i < messages.length; i++) {
    processMessage(messages[i]);
  }

}
