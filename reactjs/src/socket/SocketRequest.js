// import Ezy from '../lib/ezyfox-server-es6-client'
import Ezy from 'ezyfox-es6-client';
import {Command} from "./SocketConstants";

class SocketRequestClass {

    requestSuggestionContacts() {
        this.getApp().send(Command.SUGGEST_CONTACTS);
    }

    requestUpdatePassword(oldPassword, newPassword) {
        this.getApp().send(
            Command.UPDATE_PASSWORD,
            {"oldPassword": oldPassword, "newPassword": newPassword}
        );
    }

    searchContacts(keyword, skip, limit) {
        this.getApp().send(
            Command.SEARCH_CONTACTS,
            {keyword: keyword, skip: skip, limit: limit}
        );
    }

    searchContactsUsers(keyword, skip, limit) {
        this.getApp().send(
            Command.SEARCH_CONTACTS_USER,
            {keyword: keyword, skip: skip, limit: limit}
        );
    }

    requestAddContacts(target) {
        this.getApp().send(Command.ADD_NEW_CONTACTS, {target: target});
    }

    requestGetContacts(skip, limit) {
        this.getApp().send(Command.GET_CONTACTS, {skip: skip, limit: limit});
    }

    sendMessageRequest(channelId, message) {
        if (channelId === 0)
            this.sendSystemMessageRequest(message);
        else
            this.sendUserMessageRequest(channelId, message);
    }

    sendSystemMessageRequest(message) {
        this.getApp().send(Command.SEND_RECEIVE_SYSTEM_MESSAGE, {message: message});
    }

    sendUserMessageRequest(target, message) {
        this.getApp().send(
            Command.SEND_RECEIVE_USER_MESSAGE,
            {message: message, channelId: target}
        );
    }

    getClient() {
        const clients = Ezy.Clients.getInstance();
        const client = clients.getDefaultClient();
        return client;
    }

    getApp() {
        const zone = this.getClient().zone;
        const appManager = zone.appManager;
        const app = appManager.getApp();
        return app;
    }

}

const SocketRequest = new SocketRequestClass();

export default SocketRequest;
