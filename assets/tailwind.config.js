const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  purge: [
    "../lib/**/*.ex",
    "../lib/**/*.leex",
    "../lib/**/*.eex",
    "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
    colors: {
      transparent: "transparent",
      current: "currentColor",
      black: colors.black,
      white: colors.white,
      gray: colors.trueGray,
      green: colors.green,
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
