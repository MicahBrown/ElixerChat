import MainView    from './main';
import ChatShowView from './chat/show';
import ChatExpiredView from './chat/expired';
import PageIndexView from './page/index';
import ParticipantNewView from './participant/new';

// Collection of specific view modules
const views = {
  ChatShowView,
  ChatExpiredView,
  PageIndexView,
  ParticipantNewView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}