import MainView    from './main';
import ChatShowView from './chat/show';
import PageIndexView from './page/index';
import ParticipantNewView from './participant/new';

// Collection of specific view modules
const views = {
  ChatShowView,
  PageIndexView,
  ParticipantNewView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}