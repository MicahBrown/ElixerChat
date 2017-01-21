import MainView    from './main';
import ChatShowView from './chat/show';

// Collection of specific view modules
const views = {
  ChatShowView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}