import { Socket } from "phoenix";

const Realtime = {
  mounted() {
    const wsEndpoint =
      this.el.dataset.url.replace("http", "ws") + "/realtime/v1";
    this.socket = new Socket(wsEndpoint, {
      params: { apikey: this.el.dataset.apiKey },
    });
    this.socket.connect();
    this.channel = this.socket.channel(this.el.dataset.topic);
    const event = this.el.dataset.event;
    this.channel.on(event, (payload) => this.pushEvent(event, payload));
    this.channel.join();
  },
  destroyed() {
    this.socket.disconnect();
  },
};

export default Realtime;
