// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
//import "htmx.org";
let Hooks = {};
Hooks.AutoFocus = {
  mounted() {
    this.el.focus();
  },
  updated() {
    this.el.focus();
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()

// Initialize the JS managed area after the document is fully loaded
document.addEventListener('DOMContentLoaded', () => {
  let elapsedTime = 0; // Initialize elapsedTime to capture the duration
  let startTime;
  let timerInterval;
  let animationFrameId;
  let timerStarted = false;
  const userInputField = document.getElementById('user_input');
  if (!userInputField) return;
  

  function updateJSTypingArea(phrase, userInput) {
    const cursorPosition = userInputField.selectionStart;
    // Split the phrases into arrays of characters
    const phraseChars = Array.from(phrase);
    const userInputChars = Array.from(userInput);
    // const jsTypingArea = document.getElementById('js-typing-area');

    // Find the <code> tag within the jsTypingArea
    const codeElement = document.querySelector('#js-typing-area code');
    if (!codeElement) return;
    // if (!jsTypingArea) return;
    // Build the HTML content with span tags for styling
    let htmlContent = phraseChars.map((char, index) => {
    const userChar = userInputChars[index];
    let classList = [];
    let displayChar = char; // Display the actual character by default

    // Highlight errors: if user input is present and does not match the phrase at this position
    if (userChar !== undefined && userChar !== char) {
      classList.push('error');
      // Use a placeholder for space if it's an error
      if (char === ' ') {
        displayChar = '␣'; // Placeholder for space errors
      }
    }

   // Highlight the current position in the phrase without altering the space character
    if (index === userInput.length) {
      classList.push('current');
    }     
    if (index === cursorPosition) {
      classList.push('cursor-position'); // Apply cursor class at the current position
    }
   // For correct or future spaces, ensure they are displayed normally
    if (char === ' ' && (!userChar || userChar === char)) {
      displayChar = '&nbsp;'; // Use HTML entity for space to ensure it's visible
    }
    
    return `<span class="${classList.join(' ')}">${displayChar}</span>`;
    }).join('');
  
  codeElement.innerHTML = htmlContent;
  }
// Function to update the timer display smoothly
function updateTimer() {
  if (!timerStarted) {
    return; // Stop the timer update loop if the timer is not supposed to be running
  }
  const now = new Date();
  elapsedTime = now - startTime;
  const seconds = (elapsedTime / 1000).toFixed(2); // Convert to seconds with two decimal places

  const timerDisplay = document.getElementById('js-timer');
  if (timerDisplay) {
    timerDisplay.textContent = `JS Elapsed time: ${seconds} seconds`;
  }

  requestAnimationFrame(updateTimer);
}

function startTimer() {
  if (!timerStarted) {
    startTime = new Date();
    timerStarted = true;
    updateTimer(); // Start the smooth timer update
  }
}

function stopTimer() {
  if (timerStarted) {
    timerStarted = false;
    const endTime = new Date();
    elapsedTime = endTime - startTime; // Update elapsedTime to ensure it's current
    const seconds = elapsedTime / 1000; // Convert to seconds
    const minutes = seconds / 60; // Convert to minutes

    const totalChars = userInputField.value.trim().length;
    const wordsTyped = totalChars / 5; // Standard definition of a "word"
    const wpm = wordsTyped / minutes; // Calculate words per minute

    const timerDisplay = document.getElementById('js-timer');
    if (timerDisplay) {
      timerDisplay.textContent = `Final time: ${seconds.toFixed(2)} seconds, ${wpm.toFixed(2)} WPM`;
    }
  }
}

const updateFunction = () => {
  const codeElement = document.querySelector('#js-typing-area code');
  if (codeElement) {
    const phrase = codeElement.getAttribute('data-phrase');
    if(phrase){updateJSTypingArea(phrase, userInputField.value);
    }else{console.error('data-phrase not found! '+ codeElement.getAttribute());}

    
  } else {
    console.error('Code element not found!');
  }
};




  // Listen for cursor position changes without input changes (e.g., arrow keys, mouse click)
  userInputField.addEventListener('click', updateFunction);

  userInputField.addEventListener('keyup', (event) => {
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight' || event.key === 'Home' || event.key === 'End') {
      updateFunction();
    }
  });
    // Listen for input changes
userInputField.addEventListener('input', (event) => {
  const userInput = event.target.value.trim();
  const codeElement = document.querySelector('#js-typing-area code');
  
  if (codeElement) {
    const phrase = codeElement.getAttribute('data-phrase').trim();
    updateJSTypingArea(phrase, userInput);

    if (userInput.localeCompare(phrase, undefined, { sensitivity: 'base' }) === 0) {
      stopTimer();
    } else if (!timerStarted && userInput.length > 0) {
      startTimer();
    }
  } else {
    console.error('Code element not found!');
  }
});
});


function darkExpected() {
  return localStorage.theme === 'dark' || (!('theme' in localStorage) &&
    window.matchMedia('(prefers-color-scheme: dark)').matches);
}

function initDarkMode() {
  // On page load or when changing themes, best to add inline in `head` to avoid FOUC
  if (darkExpected()) document.documentElement.classList.add('dark');
  else document.documentElement.classList.remove('dark');
}

window.addEventListener("toogle-darkmode", e => {
  if (darkExpected()) localStorage.theme = 'light';
  else localStorage.theme = 'dark';
  initDarkMode();
})



window.liveSocket = liveSocket

