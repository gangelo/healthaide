/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/assets/tailwind/**/*.css",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.erb",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
