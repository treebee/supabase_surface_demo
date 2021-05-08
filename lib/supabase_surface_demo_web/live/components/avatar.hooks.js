const SupabaseAvatar = {
  mounted() {
    this.setAvatar();
    this.handleEvent("change-avatar", () => {
      console.log("handle event");
      this.setAvatar();
    });
  },
  setAvatar() {
    fetch(this.el.dataset.imageUrl, {
      headers: { Authorization: `Bearer ${this.el.dataset.accessToken}` },
    })
      .then((response) => {
        if (!response.ok) {
          console.error("request not ok");
          throw new Error("Couldn't fetch avatar");
        }
        console.log("request ok");
        return response.blob();
      })
      .then((blob) => (this.el.children[0].src = URL.createObjectURL(blob)));
  },
};

const SupabaseUpload = {
  mounted() {
    window.uploadHook = this;
    console.log(window.uploadHook);
  },
  uploadAvatar(event) {
    console.log("upload avatar");
    const file = event.target.files[0];
    const fileExt = file.name.split(".").pop();
    const fileName = `${Math.random()}.${fileExt}`;

    let formData = new FormData();
    formData.append("", file, fileName);

    fetch(this.el.dataset.uploadUrl + fileName, {
      method: "POST",
      body: formData,
      headers: {
        Authorization: `Bearer ${this.el.dataset.accessToken}`,
      },
    })
      .then((response) => response.json())
      .then((data) => {
        this.pushEventTo(this.el.dataset.phxComponent, "avatar-upload", data);
      })
      .catch((error) => console.error(error));
  },
};
export { SupabaseAvatar, SupabaseUpload };
