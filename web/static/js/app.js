import "babel-polyfill"

// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import MainView from './views/main';
import loadView from './views/loader';

// Create remove function if not exist
if (!('remove' in Element.prototype)) {
  Element.prototype.remove = function() {
    if (this.parentNode) {
      this.parentNode.removeChild(this);
    }
  };
}

var handleDOMContentLoaded = function() {
  // Get the current view name
  const viewName = document.getElementsByTagName('body')[0].dataset.jsViewName;

  // Load view class and mount it
  const ViewClass = loadView(viewName);
  const view = new ViewClass();
  view.mount();

  window.currentView = view;
}

var handleDocumentUnload = function() {
  window.currentView.unmount();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
window.addEventListener('unload', handleDocumentUnload, false);
