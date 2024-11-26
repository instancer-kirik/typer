// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const baseConfig = require("../../../assets/tailwind.config.js")
const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  presets: [baseConfig],
  content: [
    "./js/**/*.js",
    "../lib/*_web/**/*.*ex",
    "../lib/*_web/**/*.heex",
    "../lib/*_web/**/*.eex",
    "../lib/*_web/**/*.leex",
    "./css/**/*.css"
  ],
  theme: {
    extend: {}
  },
  plugins: []
}
