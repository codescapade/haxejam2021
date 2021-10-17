import defold.Collectionproxy.CollectionproxyMessages;
import defold.Go.GoMessages;
import defold.Msg;
import defold.types.Message;
import defold.types.Url;
import defold.support.Script;
import lua.Math;
import lua.Os;

typedef LoaderData = {
  var currentCollection: String;

  var nextCollection: String;

  var restarting: Bool;
}

class Loader extends Script<LoaderData> {

  override function init(self: LoaderData) {
    Math.randomseed(Os.time());

    // First random call after random seed always gives the same result.
    Math.random(0, 1);

    Msg.post('.', GoMessages.acquire_input_focus);

    loadCollection(self, '#game');
  }

  override function final_(self: LoaderData) {
    Msg.post('.', GoMessages.release_input_focus);
  }

  override function on_message<TMessage>(self: LoaderData, message_id: Message<TMessage>, message: TMessage,
      sender: Url) {
    switch (message_id) {
      case CollectionproxyMessages.proxy_loaded:
        Msg.post(sender, CollectionproxyMessages.init);
        Msg.post(sender, CollectionproxyMessages.enable);

      case CollectionproxyMessages.proxy_unloaded:
        loadCollection(self, self.nextCollection);

      case Messages.changeCollection:
        self.nextCollection = message.collection;
        unloadCollection(self.currentCollection);
    }
  }

  function loadCollection(self: LoaderData, collection: String) {
    self.currentCollection = collection;
    Msg.post(collection, CollectionproxyMessages.load);
  }

  function unloadCollection(collection: String) {
    Msg.post(collection, CollectionproxyMessages.unload);
  }
}