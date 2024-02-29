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
    //this.pushEvent("process_input", { key: this.el.innerHTML });11ss22srrraaassssssrr
    
    
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
// >> liveSocket.disableLatencySim()❀, ✿, ❁, ✾★, ☆, ✪, ✹✖┼☓▄'█'‽

// Initialize the JS managed area after the document is fully loaded
document.addEventListener('DOMContentLoaded', () => {
  let elapsedTime = 0; // Initialize elapsedTime to capture the durationr
  let startTime;
  let timerStarted = false;
  const userInputField = document.getElementById('code-editor');
  const phraseData =document.getElementById("phrase-data");
  if (!phraseData ) return;
  const phraseText = phraseData.dataset.phraseText;
  const lines = phraseText.split('\n'); // For lines
  if (!userInputField ) return;
  ///////Maybe make it recognize "eld ) return;" with "eld) return;"
  function updateJSTypingArea(phrase, userInput) {
    const codeElement = document.querySelector('#js-typing-area');
    if (!codeElement) return;
  
    const phraseLines = phrase.split('\n');
    const userInputLines = userInput.split('\n');
    let htmlContent = '';
  
    phraseLines.forEach((phraseLine, lineIndex) => {
      const userInputLine = userInputLines[lineIndex] || '';
      let lineHtmlContent = '';
      let wordHtmlContent = '';
      let extraSpacesHandled = false;
      let isLineBlank = true; // Assume the line is blank until proven otherwise

      for (let i = 0; i < phraseLine.length; i++) {
        const phraseChar = phraseLine[i];
        const userInputChar = userInputLine[i] || ' ';
        let classList = ['ghost-text'];
        let displayChar = phraseChar === ' ' ? '&nbsp;' : phraseChar;
  
        if (userInputChar !== undefined) {
          isLineBlank = false; // There's content in this line
          if (phraseChar === userInputChar || (phraseChar === ' ' && userInputChar === ' ')) {
            classList = ['correct-input'];//ssssr
          } else if (userInputChar !== ' ') {
            classList = ['error'];
            displayChar = userInputChar === ' ' ? '▄' : userInputChar; // Use ▄ for error spaces
          }
        }
  // Append the character to the word HTML, handling spaces as their own "word"
        if (phraseChar === ' ') {
          // Close the previous word and start a new span for the space
          lineHtmlContent += `<span class="word">${wordHtmlContent}</span>`;
          wordHtmlContent = ''; // Reset word HTML content
          // Add the space as its own word span
          lineHtmlContent += `<span class="word"><span class="${classList.join(' ')}">${displayChar}</span></span>`;
      } else {
          wordHtmlContent += `<span class="${classList.join(' ')}">${displayChar}</span>`;
      }

      // Ensure the last word is added if it's not followed by a space
      if (i === phraseLine.length - 1 && wordHtmlContent !== ' ') {
          lineHtmlContent += `<span class="word">${wordHtmlContent}</span>`;
      }
    }
      //   wordHtmlContent += `<span class="${classList.join(' ')}">${displayChar}</span>`;//changed from space to blank
  
      //   if (phraseChar === ' ' || i === phraseLine.length - 1) {
      //     lineHtmlContent += `<span class="word">${wordHtmlContent}</span>`;
      //     wordHtmlContent = '';
      //   }
      // }
  
      // Handle trailing spaces in user input as correct, if they exist beyond the phrase length
      if (userInputLine.length > phraseLine.length) {
        const extraChars = userInputLine.slice(phraseLine.length);
        if (/^\s*$/.test(extraChars)) { // Check if all extra characters are spaces
          extraChars.split('').forEach(() => {
            lineHtmlContent += `<span class="correct">&nbsp;</span>`;
          });
          extraSpacesHandled = true;
        }
      }
  
      // If there were no extra spaces or other characters that were handled as correct,
      // handle any remaining extra characters as errors.
      if (!extraSpacesHandled && userInputLine.length > phraseLine.length) {
        const extraChars = userInputLine.slice(phraseLine.length);
        extraChars.split('').forEach(char => {
          const displayChar = char === ' ' ? '&nbsp;' : char;
          lineHtmlContent += `<span class="error">${displayChar}</span>`;
        });
      }
      if (isLineBlank) {
        // If the line is still considered blank, insert a zero-width space
        lineHtmlContent += `<div class="line">&#8203;</div>`;
      }
      htmlContent += `<div class="line">${lineHtmlContent}</div>`;
    });
  
    codeElement.innerHTML = htmlContent;
  }

  // function updateJSTypingArea(phrase, userInput) {
  //   const codeElement = document.querySelector('#js-typing-area');
  //   if (!codeElement) return;

  //   const phraseLines = phrase.split('\n'); // Split phrase into lines
  //   const userInputLines = userInput.split('\n'); // Split user input into lines
  //   let htmlContent = '';s
    
  //   // Process each line
  //   phraseLines.forEach((line, lineIndex) => {
  //     const phraseChars = Array.from(line || ''); // Convert current line to characters
  //     const userInputChars = Array.from(userInputLines[lineIndex] || ''); // Safely handle undefined lines
  //     let lineHtmlContent = '';
  //     // Special handling for expected blank lines
  //   if (phraseChars.length === 0) {
  //     // For blank lines, if the user has typed something, it should be marked as incorrect
  //     if (userInputLines[lineIndex] && userInputLines[lineIndex].length > 0) {
  //       userInputChars.forEach(char => {
  //         const displayChar = char === ' ' ? '&nbsp;' : char; // Handle spaces
  //         lineHtmlContent += `<span class="error">${displayChar}</span>`; // Mark user input as incorrect
  //       });
  //     } else {
  //       // If there's no user input, render a zero-width space to keep the line's visual presence
  //       lineHtmlContent += `&#8203;`; // Use a zero-width space
  //     }
  //     htmlContent += `<div class="blank-line">${lineHtmlContent}</div>`;
  //     return; // Proceed to the next line
  //   }
  //     phraseChars.forEach((char, charIndex) => {
  //       let classList = ['ghost-text']; // Default class for untyped text
  //       let displayChar = char === ' ' ? '&nbsp;' : char; // Handle spaces
  // // Check if the current character index is within the length of the user's input for this line
     
  //       if (charIndex < userInputChars.length) {
  //         const userChar = userInputChars[charIndex];
  //         if (userChar === char) {
  //           classList = ['correct']; // Correct input
  //         } else {
  //           classList = ['error']; // Incorrect input
  //         }
  //       }

  //       // Append character span to lineHtmlContent
  //       lineHtmlContent += `<span class="${classList.join(' ')}">${displayChar}</span>`;
  //     });

  //     // Wrap each line of content in a div for proper line breaks
  //     htmlContent += `<div>${lineHtmlContent}</div>`;
  //   });

  //   codeElement.innerHTML = htmlContent; // Update the code element with the new HTML content
  // }


  // function updateJSTypingArea(phrase, userInput) {
  //   const codeElement = document.querySelector('#js-typing-area');
  //   if (!codeElement) return;
  
  //   const phraseLines = phrase.split('\n'); // Split phrase into lines
  //   const userInputLines = userInput.split('\n'); // Split user input into lines
  //   let htmlContent = '';
  
  //   // Process each line
  //   phraseLines.forEach((line, lineIndex) => {
  //     const phraseChars = Array.from(line || ''); // Convert current line to characters
  //     const userInputChars = Array.from(userInputLines[lineIndex] || ''); // Safely handle undefined lines
  //     let lineHtmlContent = '';
  
  //     phraseChars.forEach((char, charIndex) => {
  //       let classList = ['ghost-text']; // Default class for untyped text
  //       let displayChar = char === ' ' ? '&nbsp;' : char; // Handle spaces
  
  //       if (charIndex < userInputChars.length) {
  //         const userChar = userInputChars[charIndex];
  //         if (userChar === char) {
  //           classList = ['correct-input']; // Correct input
  //         } else {
  //           classList = ['error']; // Incorrect input
  //         }
  //       }
  
  //       // Append character span to lineHtmlContent
  //       lineHtmlContent += `<span class="${classList.join(' ')}">${displayChar}</span>`;
  //     });
  
  //     // Wrap each line of content in a div or span for proper line breaks
  //     htmlContent += `<div>${lineHtmlContent}</div>`;
  //   });
  
  //   codeElement.innerHTML = htmlContent; // Update the code element with the new HTML content
  // }

// Function to update the timer display smoothly
function updateTimer() {
  if (!timerStarted) {
    return; // Stop the timer update loop if the timer is not supposed to be running
  }
  const now = new Date();
  elapsedTime = now - startTime;
  const seconds = (elapsedTime / 1000).toFixed(2); //1 Convert to seconds with two decimal places

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
    

    const totalChars = userInputField.value.length;
    console.log(totalChars);
    const wordsTyped = totalChars / 5; // Standard definition of a "word"
    const wpm = wordsTyped / minutes; // Calculate words per minute

    const timerDisplay = document.getElementById('js-timer');
    if (timerDisplay) {
      timerDisplay.textContent = `Final time: ${seconds.toFixed(2)} seconds, ${wpm.toFixed(2)} WPM`;
    }
  }
}

const updateFunction = () => {
  const userInput =  userInputField.value; // Use textContent for accuracy
  //const codeElement = document.querySelector('#js-typing-area');
  if (phraseText) {
    //const phrase = codeElement.getAttribute('data-phrase');

    console.log('Phrase:', phraseText); // Check what phrase contains
    console.log('User input:', userInput); // Check what userInput contains

    
      // Check for completion using a more nuanced comparison if necessary
      if (userInput === phraseText) { // Consider case sensitivity based on your requirements
        stopTimer();
      } else if (!timerStarted && userInput.length > 0) {
        startTimer();
      }
      updateJSTypingArea(phraseText, userInput);
    } else {
      console.error('Phrase text is undefined!');
    }

    
  
};
 
// Listen for input changes
userInputField.addEventListener('input', (event) => {
    console.log(event)
  
  updateFunction();
  
});
userInputField.addEventListener('keydown', e => {
  if (e.key === 'Enter') {
      e.preventDefault(); // Prevent default Enter behaviors

      let currentValue = userInputField.value;
      let cursorPosition = userInputField.selectionStart;
      console.log(`Before calculation: cursorPosition=${cursorPosition}, currentValue=${currentValue}`);

    // Calculate new cursor position
    let { newPosition, modifiedValue } = calculateNewCursorPosition(currentValue, cursorPosition, phraseText);
    
      // Debugging output
    console.log(`After calculation: newPosition=${newPosition}, modifiedValue=${modifiedValue}`);
    // Apply the modified value to the textarea
    userInputField.value = modifiedValue;
    updateFunction();
      setTimeout(() => {
        userInputField.setSelectionRange(newPosition, newPosition);
     
      }, 10);
  }
});
  // Listen for cursor position changes without input changes (e.g., arrow keys, mouse click)
  userInputField.addEventListener('click', updateFunction);

  userInputField.addEventListener('keyup', (event) => {
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight' || event.key === 'Home' || event.key === 'End') {
      updateFunction();
    }
  });
   
  
});
// function calculateNewCursorPosition(currentValue, cursorPosition, expectedPhrase) {
//   let newPosition = cursorPosition; // Initialize newPosition to current cursorPosition

//   // Split the expected phrase and current value into lines
//   let expectedLines = expectedPhrase.split('\n');
//   let currentLines = currentValue.split('\n');

//   // Find the current line number
//   let currentLineNumber = currentValue.substring(0, cursorPosition).split('\n').length - 1;
//   let currentLine = currentLines[currentLineNumber] || '';
//   let expectedLine = expectedLines[currentLineNumber] || '';

//   // If the current line is incomplete and Enter is pressed
//   if (currentLine.length < expectedLine.length) {
//     let incompletePart = expectedLine.substring(currentLine.length);
//     let invalidInput = incompletePart.replace(/./g, '|'); // Replace all characters with '|'
//     currentLines[currentLineNumber] += invalidInput;

//     currentValue = currentLines.join('\n'); // Update the currentValue with the modified line
//     newPosition = currentValue.length; // Move cursor to the end of the modified line
//   }

//   // Move to the next line if applicable
//   if (currentLineNumber + 1 < expectedLines.length) {
//     let nextLineExpected = expectedLines[currentLineNumber + 1];
//     let leadingSpaces = nextLineExpected.match(/^ */)[0].length; // Count leading spaces for indentation
//     newPosition = currentValue.length + 1 + leadingSpaces; // Adjust for new line and indentation
//   } else {
//     newPosition = currentValue.length; // If there are no more lines, stay at the end
//   }

//   return { newPosition, modifiedValue: currentValue };
// }
function calculateNewCursorPosition(currentValue, cursorPosition, expectedPhrase) {
  let newPosition = cursorPosition; // Initialize newPosition to current cursorPosition
  let modifiedValue = currentValue; // Start with the current value, potentially modify it below

  // Split the expected phrase and current value into lines
  let expectedLines = expectedPhrase.split('\n');
  let currentLines = currentValue.split('\n');

  // Find the current line number
  let currentLineNumber = currentValue.substring(0, cursorPosition).split('\n').length - 1;
  let currentLine = currentLines[currentLineNumber] || '';
  let expectedLine = expectedLines[currentLineNumber] || '';

  // If the current line is shorter than expected, append error indicators
  if (currentLine.length < expectedLine.length) {
    let incompletePart = expectedLine.substring(currentLine.length);
    let invalidInput = incompletePart.replace(/./g, '|'); // Indicate errors
    currentLines[currentLineNumber] += invalidInput;
    modifiedValue = currentLines.join('\n'); // Rebuild the full text
  }

  // Moving to the next line if necessary
  if (currentLineNumber + 1 < expectedLines.length) {
    // We have another line to go to
    let nextLine = currentLineNumber + 1 < currentLines.length ? currentLines[currentLineNumber + 1] : "";
    let leadingSpacesNextLine = expectedLines[currentLineNumber + 1].match(/^ */)[0].length; // Count leading spaces for indentation of the next expected line
    if (nextLine.length === 0 || nextLine.length < leadingSpacesNextLine) {
      // If the next line is empty or not fully indented, adjust it
      modifiedValue += '\n' + " ".repeat(leadingSpacesNextLine); // Add new line and indent for the next line
      newPosition = modifiedValue.length; // Move cursor to the end of the new line (after indentation)
    } else {
      // Move cursor to the beginning of the next line if it already exists
      let positionToNextLine = currentValue.indexOf('\n', cursorPosition) + 1; // Find next line break and move one character beyond it
      newPosition = positionToNextLine + leadingSpacesNextLine; // Adjust for indentation
    }
  }

  return { newPosition, modifiedValue };
}
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

