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
Hooks.HashCalculator = {
  mounted() {
    console.log("HashCalculator mounted. Initializing hash calculation script.");
    this.el.addEventListener('click', () => {
      const fileInput = document.getElementById('fileInput');
      const files = fileInput.files;
      if (files.length === 0) {
        console.log("No file selected.");
        alert("Please select a file.");
        return;
      }
      console.log(`File selected: ${files[0].name}`);

      const file = files[0];
      file.arrayBuffer().then(arrayBuffer => {
        console.log("File loaded into array buffer. Calculating hash.");
        return crypto.subtle.digest('SHA-256', arrayBuffer);
      }).then(hashBuffer => {
        console.log("Hash calculated. Converting to hex string.");
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
        console.log(`Hash calculated: ${hashHex}`);
        const hashResult = document.getElementById('custom_phrase');
        hashResult.textContent = hashHex;
        const hashResult2 = document.getElementById('custom_phrase_hidden');
        hashResult2.value = hashHex;
        this.pushEvent("hash_calculated", {hash: hashHex, fileName: file.name});
        // liveSocket.pushEvent("#content", "hash_calculated", {hash: hashHex, fileName: file.name});
      }).catch(error => {
        console.error("Error calculating hash: ", error);
      });
    });
  }
};
// const calculateHashButton = document.getElementById('calculateHashButton');
//   if (calculateHashButton) {
//     console.log("Calculate Hash Button found. Adding event listener.");
//     calculateHashButton.addEventListener('click', function() {
//       const fileInput = document.getElementById('fileInput');
//       const files = fileInput.files;
//       if (files.length === 0) {
//         console.log("No file selected.");
//         alert("Please select a file.");
//         return;
//       }
//       console.log(`File selected: ${files[0].name}`);

//       const file = files[0];
//       file.arrayBuffer().then(arrayBuffer => {
//         console.log("File loaded into array buffer. Calculating hash.");
//         return crypto.subtle.digest('SHA-256', arrayBuffer);
//       }).then(hashBuffer => {
//         console.log("Hash calculated. Converting to hex string.");
//         const hashArray = Array.from(new Uint8Array(hashBuffer));
//         const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
//         console.log(`Hash calculated: ${hashHex}`);
        
//         // Ensure `liveSocket` is correctly initialized and accessible here
//         liveSocket.pushEventTo("#content", "hash_calculated", {hash: hashHex, fileName: file.name});
//       }).catch(error => {
//         console.error("Error calculating hash: ", error);
//       });
//     });
//   } else {
//     console.log("Calculate Hash Button not found.");
//   }

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
  //const userInputField = document.getElementById('code-editor');
  const phraseData =document.getElementById("phrase-data");
  if (!phraseData ) return;
  const phraseText = phraseData.dataset.phraseText;
  let typedLength = 0; // Tracks how many characters have been correctly or incorrectly typed

  const editableContainer = document.getElementById('editable-container');
    const remainingTextSpan = document.getElementById('remaining-text');
    let remainingTextContent = remainingTextSpan.textContent;

    editableContainer.addEventListener('keydown', function(e) {
      if (e.key === 'Backspace') {
        e.preventDefault();
        handleBackspace();
      } else if (e.key === 'Enter') {
        // Prevent default to manually handle newline
        e.preventDefault();
        handleEnter();
      }
    });

    editableContainer.addEventListener('keypress', function(e) {
      if (e.key !== 'Enter') { // Skip Enter key to avoid double handling
        e.preventDefault(); // Prevent default character input
        handleCharacterInput(e.key);
      }
    });

    function handleCharacterInput(char) {
      const correctChar = phraseText.charAt(typedLength);
      // Check for special characters like tabs (\t) that need to be handled differently
      const isCorrect = char === correctChar || (correctChar === '\n' && char === 'Enter') || (correctChar === '\t' && char === 'Tab');
      
      if (isCorrect) {
        // Handle newline characters and tab characters for indentation
        if (correctChar === '\n') {
          appendNewLine();
          // Automatically append indentation after new line if next characters are tabs or spaces
          appendIndentation();
        } else if (correctChar === '\t') {
          appendTab();
        } else {
          appendChar(char, true);
        }
        typedLength++;
        updateRemainingText();
      } else {
        // Optionally handle incorrect input
      }
    }
    
function getIndentationLevel(line) {
  // Matches leading spaces in the line
  const result = line.match(/^(\s*)/);
  return result ? result[1].length : 0;
}
    function appendNewLine(isCorrect) {
      const newLineSpan = document.createElement('span');
      newLineSpan.innerHTML = '&#x23ce;'; // Represents a return symbol, adjust as needed
      newLineSpan.className = isCorrect ? 'correct' : 'incorrect';
      remainingTextSpan.parentNode.insertBefore(newLineSpan, remainingTextSpan);
    }
    function appendTab() {
      const tabSpan = document.createElement('span');
      tabSpan.textContent = '\t'; // Visual representation of a tab, adjust as needed
      tabSpan.className = 'correct'; // Assuming tab is correct for simplicity
      remainingTextSpan.parentNode.insertBefore(tabSpan, remainingTextSpan);
    }
    function appendIndentation() {
      let nextChars = phraseText.substring(typedLength);
      let match = nextChars.match(/^(\s+)/); // Regex to capture leading spaces or tabs
      
      if (match) {
        let indentation = match[1];
        for (let i = 0; i < indentation.length; i++) {
          let char = indentation[i];
          if (char === '\t') {
            appendTab();
          } else {
            appendChar(' ', true); // Assuming space is correct for simplicity
          }
          typedLength++;
        }
      }
    }
    
    function appendChar(char, isCorrect) {
      const charSpan = document.createElement('span');
      charSpan.textContent = char;
      charSpan.className = isCorrect ? 'correct' : 'incorrect';
      remainingTextSpan.parentNode.insertBefore(charSpan, remainingTextSpan);
    }
    
    function updateRemainingText() {
      let newText = phraseText.substring(typedLength).replace(/\n/g, '<br>'); // Convert newline characters to <br> for display
      remainingTextSpan.innerHTML = newText; // Use innerHTML to interpret <br> tags
    }
    function handleBackspace() {
      if (typedLength > 0) {
        typedLength--;
        // editableContainer.removeChild(editableContainer.childNodes[typedLength+1]);
        // updateRemainingText();
        let removeIndex = typedLength; // Adjust if your indexing needs refinement
        let childNodes = Array.from(editableContainer.childNodes);
        let targetNode = childNodes.find((node, index) => index === removeIndex);
        if (targetNode) editableContainer.removeChild(targetNode);
        updateRemainingText();
      
      }
    }

    function handleEnter() {

      const currentLine = getCurrentLine(editableContainer.textContent, typedLength);
      const indentationLevel = getIndentationLevel(currentLine);
    
      // Append a newline
      appendChar('\n', true);
    
      // Append the correct number of spaces for indentation
      for (let i = 0; i < indentationLevel; i++) {
        appendChar(' ', true); // Assuming spaces for indentation
      }
    
}
  // const lines = phraseText.split('\n'); // For lines
  // //if (!userInputField ) return;

  // const container = document.getElementById('editable-container');
    
  //   let userInput = "";

  //   // Initialize display with the phrase as ghost text
  //   initializeDisplay(phraseText);

  //   container.addEventListener('input', function(e) {
  //       // Update userInput based on the current text content and cursor position
  //       const cursorPosition = getCaretCharacterOffsetWithin(container);
  //       userInput = container.innerText.substring(0, cursorPosition);
  //       updateDisplay(phraseData, userInput);

  //       // Restore the cursor position after display update
  //       setCaretPosition(container, cursorPosition);
  //   });

  //   function initializeDisplay(phrase) {
  //       container.innerHTML = phrase.split('').map(char => `<span class="ghost">${char}</span>`).join('');
  //   }

  //   function updateDisplay(phrase, input) {
  //       let displayHTML = "";
  //       for (let i = 0; i < phrase.length; i++) {
  //           const char = phrase[i];
  //           const inputChar = input[i];
  //           let charClass = inputChar === char ? 'match' : 'ghost';
  //           if (inputChar && inputChar !== char) charClass = 'mismatch';
  //           displayHTML += `<span class="${charClass}">${char}</span>`;
  //       }
  //       container.innerHTML = displayHTML;
  //   }

  //   function getCaretCharacterOffsetWithin(element) {
  //       let caretOffset = 0;
  //       const doc = element.ownerDocument || element.document;
  //       const win = doc.defaultView || doc.parentWindow;
  //       let sel;
  //       if (typeof win.getSelection != "undefined") {
  //           sel = win.getSelection();
  //           if (sel.rangeCount > 0) {
  //               const range = win.getSelection().getRangeAt(0);
  //               const preCaretRange = range.cloneRange();
  //               preCaretRange.selectNodeContents(element);
  //               preCaretRange.setEnd(range.endContainer, range.endOffset);
  //               caretOffset = preCaretRange.toString().length;
  //           }
  //       }
  //       return caretOffset;
  //   }

  //   function setCaretPosition(element, position) {
  //       let count = 0;
  //       const setPos = (node) => {
  //           if (node.nodeType === 3) { // Text node
  //               if (count + node.length >= position) {
  //                   const range = document.createRange();
  //                   const sel = window.getSelection();
  //                   range.setStart(node, position - count);
  //                   range.collapse(true);
  //                   sel.removeAllRanges();
  //                   sel.addRange(range);
  //                   return true; // Stop the loop
  //               }
  //               count += node.length;
  //           } else if (node.nodeType === 1) { // Element node
  //               for (let child of node.childNodes) {
  //                   if (setPos(child)) return true; // Found position, stop loop
  //               }
  //           }
  //       };
  //       for (let child of element.childNodes) {
  //           if (setPos(child)) break; // Found position, stop loop
  //       }
  //   }


  // ///////Maybe make it recognize "eld ) return;" with "eld) return;"
  // function updateJSTypingArea(phrase, userInput) {
  //   const codeElement = document.querySelector('#js-typing-area');
  //   if (!codeElement) return;
    
  //   const phraseLines = phrase.split('\n');
  //   const userInputLines = userInput.split('\n');
  //   let htmlContent = '';
  
  //   phraseLines.forEach((phraseLine, lineIndex) => {
  //     const userInputLine = userInputLines[lineIndex] || '';
  //     let lineHtmlContent = '';
  //     let wordHtmlContent = '';
  //     let extraSpacesHandled = false;
  //     let isLineBlank = true; // Assume the line is blank until proven otherwise
  //     let isLineStart = true; // Flag to track the start of a linea
  //     for (let i = 0; i < phraseLine.length; i++) {
  //       const phraseChar = phraseLine[i];
  //       const userInputChar = userInputLine[i] || ' ';
  //       let classList = ['ghost-text'];
  //       let displayChar = phraseChar === ' ' ? '&nbsp;' : phraseChar;
  
  //       if (userInputChar !== undefined) {
          
  //         if (phraseChar === userInputChar || (phraseChar === ' ' && userInputChar === ' ')) {
  //           classList = ['correct-input'];
  //           isLineBlank = false; // There's content in this line
  //         } else if (userInputChar !== ' ') {
  //           classList = ['error'];
  //           isLineBlank = false; // There's content in this line
  //           displayChar = userInputChar === ' ' ? '▄' : userInputChar; // Use ▄ for error spaces
  //         }
  //       }
  //        // Handle the zero-width space for the first character in a line or after a newline
      
  // // Append the character to the word HTML, handling spaces as their own "word"
  //       if (phraseChar === ' ') {
  //         if (isLineStart) {
  //           displayChar = '&#8203;'; // Use zero-width space if the actual space is the first character
  //           isLineStart = false; // Reset flag after handling the first character'
  //         } else{
  //           isLineStart = false; // Any non-space character means we're no longer at the start
  //         }
  //         // Close the previous word and start a new span for the space
  //         lineHtmlContent += `<span class="word">${wordHtmlContent}</span>`;
  //         wordHtmlContent = ''; // Reset word HTML content
  //         // Add the space as its own word span
  //         lineHtmlContent += `<span class="word"><span class="${classList.join(' ')}">${displayChar}</span></span>`;
  //     } else {
  //         wordHtmlContent += `<span class="${classList.join(' ')}">${displayChar}</span>`;
  //     }

  //     // Ensure the last word is added if it's not followed by a space
  //     if (i === phraseLine.length - 1 && wordHtmlContent !== ' ') {
  //         lineHtmlContent += `<span class="word">${wordHtmlContent}</span>`;
  //         wordHtmlContent = '';
  //     }
  //     // if (phraseChar === ' ' || i === phraseLine.length - 1) {
  //     //   lineHtmlContent += `<span class="word">${wordHtmlContent}</span>`;
        
  //     // }
  //   }
  //     //   wordHtmlContent += `<span class="${classList.join(' ')}">${displayChar}</span>`;//changed from space to blank
  
        
  //     // }
  
  //     // Handle trailing spaces in user input as correct, if they exist beyond the phrase length
  //     if (userInputLine.length > phraseLine.length) {
  //       const extraChars = userInputLine.slice(phraseLine.length);
  //       if (/^\s*$/.test(extraChars)) { // Check if all extra characters are spaces
  //         extraChars.split('').forEach(() => {
  //           lineHtmlContent += `<span class="correct">&nbsp;</span>`;
  //         });
  //         extraSpacesHandled = true;
  //       }
  //     }
  
  //     // If there were no extra spaces or other characters that were handled as correct,
  //     // handle any remaining extra characters as errors.
  //     if (!extraSpacesHandled && userInputLine.length > phraseLine.length) {
  //       const extraChars = userInputLine.slice(phraseLine.length);
  //       extraChars.split('').forEach(char => {
  //         const displayChar = char === ' ' ? '&nbsp;' : char;
  //         lineHtmlContent += `<span class="error">${displayChar}</span>`;
  //       });
  //     }
  //     if (isLineBlank) {
  //       // If the line is still considered blank, insert a zero-width space&#8203;
  //       lineHtmlContent += `<div class="line">&nbsp;</div>`;
  //     }
  //     htmlContent += `<div class="line">${lineHtmlContent}</div>`;
  //   });
  
  //   codeElement.innerHTML = htmlContent;
  // }

  // function updateJSTypingArea(phrase, userInput) {
  //   const codeElement = document.querySelector('#js-typing-area');
  //   if (!codeElement) return;

  //   const phraseLines = phrase.split('\n'); // Split phrase into lines
  //   const userInputLines = userInput.split('\n'); // Split user input into lines
  //   let htmlContent = '';ss
    
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

// const updateFunction = () => {
//   const userInput =  userInputField.value; // Use textContent for accuracy
//   //const codeElement = document.querySelector('#js-typing-area');
//   if (phraseText) {
//     //const phrase = codeElement.getAttribute('data-phrase');

//     console.log('Phrase:', phraseText); // Check what phrase contains
//     console.log('User input:', userInput); // Check what userInput contains

    
//       // Check for completion using a more nuanced comparison if necessary
//       if (userInput === phraseText) { // Consider case sensitivity based on your requirements
//         stopTimer();
//       } else if (!timerStarted && userInput.length > 0) {
//         startTimer();
//       }
//       updateJSTypingArea(phraseText, userInput);
//     } else {
//       console.error('Phrase text is undefined!');
//     }

    
  
// };
// document.getElementById('input').addEventListener('input', function(e) {
//   const userInput = e.target.innerText;
//   const phrase = "Your target phrase goes here. Include\nnew lines or long text to wrap.";
//   let backgroundHTML = '';

//   for (let i = 0; i < phrase.length; i++) {
//     const char = phrase[i];
//     const inputChar = userInput[i] || '';
//     let spanClass = '';

//     if (char === '\n') {
//       backgroundHTML += '<br/>';
//       continue;
//     }

//     if (inputChar === char) {
//       spanClass = 'correct'; // Add your correct class styling
//     } else if (inputChar) {
//       spanClass = 'incorrect'; // Add your incorrect class styling
//     }

//     // Handle spaces specially to ensure they're visible
//     const displayChar = char === ' ' ? '␣' : char; // Use a visible symbol for spaces
//     backgroundHTML += `<span class="${spanClass}">${displayChar}</span>`;
//   }

//   document.getElementById('background').innerHTML = backgroundHTML;
// });
// // Listen for input changes
// userInputField.addEventListener('input', (event) => {
//     console.log(event)
  
//   updateFunction();
  
// });
// userInputField.addEventListener('keydown', e => {
//   if (e.key === 'Enter') {
//       e.preventDefault(); // Prevent default Enter behaviors

//       let currentValue = userInputField.value;
//       let cursorPosition = userInputField.selectionStart;
//       console.log(`Before calculation: cursorPosition=${cursorPosition}, currentValue=${currentValue}`);

//     // Calculate new cursor position
//     let { newPosition, modifiedValue } = calculateNewCursorPosition(currentValue, cursorPosition, phraseText);
    
//       // Debugging output
//     console.log(`After calculation: newPosition=${newPosition}, modifiedValue=${modifiedValue}`);
//     // Apply the modified value to the textarea
//     userInputField.value = modifiedValue;
//     updateFunction();
//       setTimeout(() => {
//         userInputField.setSelectionRange(newPosition, newPosition);
     
//       }, 10);
//   }
// });
//   // Listen for cursor position changes without input changes (e.g., arrow keys, mouse click)
//   userInputField.addEventListener('click', updateFunction);

//   userInputField.addEventListener('keyup', (event) => {
//     if (event.key === 'ArrowLeft' || event.key === 'ArrowRight' || event.key === 'Home' || event.key === 'End') {
//       updateFunction();
//     }
//   });
   
  
// });
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

// //recent===============================================================================================================================================
// function calculateNewCursorPosition(currentValue, cursorPosition, expectedPhrase) {
//   let newPosition = cursorPosition; // Initialize newPosition to current cursorPosition
//   let modifiedValue = currentValue; // Start with the current value, potentially modify it below

//   // Split the expected phrase and current value into lines
//   let expectedLines = expectedPhrase.split('\n');
//   let currentLines = currentValue.split('\n');

//   // Find the current line number
//   let currentLineNumber = currentValue.substring(0, cursorPosition).split('\n').length - 1;
//   let currentLine = currentLines[currentLineNumber] || '';
//   let expectedLine = expectedLines[currentLineNumber] || '';

//   // If the current line is shorter than expected, append error indicators
//   if (currentLine.length < expectedLine.length) {
//     let incompletePart = expectedLine.substring(currentLine.length);
//     let invalidInput = incompletePart.replace(/./g, '|'); // Indicate errors
//     currentLines[currentLineNumber] += invalidInput;
//     modifiedValue = currentLines.join('\n'); // Rebuild the full text
//   }

//   // Moving to the next line if necessary
//   if (currentLineNumber + 1 < expectedLines.length) {
//     // We have another line to go to
//     let nextLine = currentLineNumber + 1 < currentLines.length ? currentLines[currentLineNumber + 1] : "";
//     let leadingSpacesNextLine = expectedLines[currentLineNumber + 1].match(/^ */)[0].length; // Count leading spaces for indentation of the next expected line
//     if (nextLine.length === 0 || nextLine.length < leadingSpacesNextLine) {
//       // If the next line is empty or not fully indented, adjust it
//       modifiedValue += '\n' + " ".repeat(leadingSpacesNextLine); // Add new line and indent for the next line
//       newPosition = modifiedValue.length; // Move cursor to the end of the new line (after indentation)
//     } else {
//       // Move cursor to the beginning of the next line if it already exists
//       let positionToNextLine = currentValue.indexOf('\n', cursorPosition) + 1; // Find next line break and move one character beyond it
//       newPosition = positionToNextLine + leadingSpacesNextLine; // Adjust for indentation
//     }
//   }

//   return { newPosition, modifiedValue };
// }
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

});

window.liveSocket = liveSocket

