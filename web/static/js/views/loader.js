import MainView    from './main';
import ChatShowView from './chat/show';
import PageIndexView from './page/index';

// Collection of specific view modules
const views = {
  ChatShowView,
  PageIndexView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}