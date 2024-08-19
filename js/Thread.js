import { NativeModules, NativeEventEmitter } from "react-native";

const { ThreadManager } = NativeModules;
const emitter = new NativeEventEmitter(ThreadManager)

export default class Thread {
  constructor(jsPath) {
    if (!jsPath || !jsPath.endsWith(".js")) {
      throw new Error("Invalid path for thread. Only js files are supported");
    }

    this.id = ThreadManager.startThread(jsPath.replace(".js", "")).then(
      (id) => {
        emitter.addListener(`Thread`, (msg) => {
          if (!msg) return;
          const { message, id: threadId } = JSON.parse(msg);
          if (id === threadId && this.onmessage)
            this.onmessage(JSON.stringify(message));
        });
        return id;
      }
    );
  }

  postMessage(message) {
    this.id.then((id) => ThreadManager.postThreadMessage(id, message));
  }

  terminate() {
    this.id.then(ThreadManager.stopThread);
  }
}
