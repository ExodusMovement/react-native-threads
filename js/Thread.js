import { NativeModules, DeviceEventEmitter } from "react-native";

const { ThreadManager } = NativeModules;

export default class Thread {
  constructor(jsPath) {
    if (!jsPath || !jsPath.endsWith(".js")) {
      throw new Error("Invalid path for thread. Only js files are supported");
    }

    this.id = ThreadManager.startThread(jsPath.replace(".js", ""))
      .then((id) => {
        DeviceEventEmitter.addListener(`Thread`, (msg) => {
          if (!msg) return;
          const { message, id: threadId } = JSON.parse(msg);
          if (id === threadId && this.onmessage)
            this.onmessage(JSON.stringify(message));
        });
        return id;
      })
      .catch((err) => {
        throw new Error(err);
      });
  }

  postMessage(message) {
    this.id.then((id) => ThreadManager.postThreadMessage(id, message));
  }

  terminate() {
    this.id.then(ThreadManager.stopThread);
  }
}
