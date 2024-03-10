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
// editableContainer.addEventListener('keypress', function(e) {
//   if (e.key !== 'Enter') { // Skip Enter key to avoid double handling
//     e.preventDefault(); // Prevent default character input
//     handleCharacterInput(e.key);
//   }
// });

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

// Hooks.EditableContainer = {//enter doesn't form the push_event arg right, no \n and indent
//   mounted() {
//     let userInput = ''; // Initialize an empty string to keep track of user input
    
//     this.el.addEventListener('keydown', (e) => {
//       // Handle backspace by removing the last character from `userInput`
//       if (e.key === 'Backspace' && userInput.length > 0) {
//         e.preventDefault(); // Prevent the default backspace behavior
//         userInput = userInput.slice(0, -1); // Remove the last character
//         this.pushEvent("input", { user_input: userInput }); // Send the updated user input
//       }
//     });
// //in order for this approach to work, I need to calculate the indentations and send them correctly each 
//     this.el.addEventListener('keypress', (e) => {
//       // Ignore Enter key here to avoid duplication
//       if (e.key === 'Enter') {
//         // Handle new line input separately if needed


//         userInput += '\n'; // Append a newline character to `userInput`
//       } else {
//         e.preventDefault(); // Prevent the default character input
//         userInput += e.key; // Append the pressed key to `userInput`
//       }
      
//       this.pushEvent("input", { user_input: userInput }); // Send the updated user input
//     });

//     // Optional: Implement a function to handle special characters like tabs ('\t') as needed
//   }
// };
// Hooks.EditableContainer = {//if i can just send the typed text and not the whole phrase every time, efficiency stuff
//   mounted() {
    
//     this.el.addEventListener('keypress', (e) => {
      
//       this.pushEvent("input", { user_input: this.el.innerText });
//     });
//   }
// };

Hooks.Countdown = {
  mounted() {
    this.handleCountdown();
  },
  handleCountdown() {
    let duration = 2; // Start at 2 because 3 is already displayed
    let countdownElement = this.el;
    let contentElement = document.getElementById("content");

    let interval = setInterval(() => {
      let currentNumber = parseInt(countdownElement.innerText, 10);
      if (currentNumber > 1) {
        countdownElement.innerText = currentNumber - 1;
      } else {
        clearInterval(interval);
        countdownElement.style.display = "none"; // Hide the countdown
        contentElement.style.display = "block"; // Show your content
      }
    }, 1000);
  }
};
Hooks.EditableContainer = {
  
  mounted() {
     // Initialize timer-related properties
     this.timerStarted = false;
     this.elapsedTime = 0;
     this.startTime = null;
     this.userInput ="";
    const phraseData =document.getElementById("phrase-data");
    if (!phraseData ) return;
    this.phraseText = phraseData.dataset.phraseText;
    this.typedLength = 0; // Tracks how many characters have been correctly or incorrectly typeds

    this.editableContainer = document.getElementById('editable-container');
    this.remainingTextSpan = document.getElementById('remaining-text');
  
    this.rightArrow();
      
    // Assuming `this.phraseText` is already defined within your hook
    this.el.addEventListener('keypress', (e) => {
      this.rightArrow();
      if (e.key !== 'Enter') {
        e.preventDefault();
        this.handleCharacterInput(e.key);
        
        this.updateAndPushUserInput();
      }
    });

    this.el.addEventListener('keydown', (e) => {
      if (e.key === 'Backspace') {
        e.preventDefault();
        this.handleBackspace();
      } else if (e.key === 'Enter') {
        e.preventDefault();
        this.handleEnter();
      }
      this.updateAndPushUserInput();
    });

    this.el.focus();
  },//mounted
  
  handleCharacterInput(char) {
    
    const correctChar = this.phraseText.charAt(this.typedLength);
    // Check for special characters like tabs (\t) that need to be handled differently
    const isCorrect = char === correctChar || (correctChar === '\n' && char === 'Enter') || (correctChar === '\t' && char === 'Tab');
    const isEndOfLine = correctChar === '\n' || correctChar === ''; // Check if at the end of a line or text
    if (isEndOfLine) {
      //NO OP it just waits for enter
      // Prevent adding the space directly
      // appendExtraCharacter(); // Function to append the ▄ character
      // if(char=== ' '){
      //   appendChar('▄', true);
      // }else{
      //   appendChar(char,false);
      // }
      
    } else {
      if (isCorrect) {
        
        // Handle newline characters and tab characters for indentation
        if (correctChar === '\n') {
          this.appendNewLine();
          // Automatically this.append indentation after new line if next characters are tabs or spaces
          this.appendIndentation();
        } else if (correctChar === '\t') {
          this.appendTab();
        } else {
          this.appendChar(char, true);
        }
        this.typedLength++;
        this.moveCaretBeforeRemainingText();
        this.updateRemainingText();
      } else {
        if (correctChar === '\n') {
          this.appendNewLine();
          // Automatically this.append indentation after new line if next characters are tabs or spaces
          this.appendIndentation();
        } else if (correctChar === '\t') {
          this.appendTab();
        } else if(char === " ") {
          char = "▄";
          this.appendChar(char, false);
        
        }else{
          this.appendChar(char, false);
        }
        this.typedLength++;
        this.moveCaretBeforeRemainingText();
        this.updateRemainingText();
        
          
        // Optionally handle incorrect input
      }
      
    }//isNotEndOfLine
    if (this.phraseText) {
      // console.log('Phrase:', this.phraseText);
      // console.log('User input:', this.userInput);

       if (!this.timerStarted&& this.elapsedTime==0) {
        this.startTimer();
      }
    }
  },
  appendIndentation() {
    let nextChars = this.phraseText.substring(this.typedLength);
    let match = nextChars.match(/^(\s+)/); // Regex to capture leading spaces or tabs
    
    if (match) {
      let indentation = match[1];
      for (let i = 0; i < indentation.length; i++) {
        let char = indentation[i];
        if (char === '\t') {
          this.appendTab();
        } else {
          this.appendChar(' ', true); // Assuming space is correct for simplicity
        }
        this.typedLength++;
      }
    }
  },
  appendChar(char, isCorrect) {
    const charSpan = document.createElement('span');
    charSpan.textContent = char;
    charSpan.className = isCorrect ? 'correct' : 'incorrect';
    this.remainingTextSpan.parentNode.insertBefore(charSpan, this.remainingTextSpan);
  },
  getIndentationLevel(line) {
    console.log(line);
    // Matches leading spaces in the line
    const result = line.match(/^(\s*)/);
    
    return result ? result[1].length : 0;
  },
  appendNewLine(isCorrect) {
     const newLineSpan = document.createElement('br');
    // newLineSpan.innerHTML = '&#x23ce;'; // Represents a return symbol, adjust as needed
    // newLineSpan.className = isCorrect ? 'correct' : 'incorrect';
    this.remainingTextSpan.parentNode.insertBefore(newLineSpan, this.remainingTextSpan);
  },
  appendTab() {
    const tabSpan = document.createElement('span');
    tabSpan.textContent = '    '; // Visual representation of a tab, adjust as needed
    tabSpan.className = 'correct'; // Assuming tab is correct for simplicity
    this.remainingTextSpan.parentNode.insertBefore(tabSpan, this.remainingTextSpan);
  },
  updateRemainingText() {
    let html = '';
  
    // Split the text into segments of words and whitespace/newlines
    const segments = this.phraseText.substring(this.typedLength).split(/(\s+)/);
  
    // Process each segment, wrapping words in spans and preserving whitespace
    segments.forEach(segment => {
      if (segment.match(/\s+/)) {
        // For segments that are purely whitespace, replace spaces with &nbsp; but leave newlines as <br>
        html += segment.replace(/\n/g, '<br>');
      } else {
        // Wrap words in spans to keep them unbroken; no &nbsp; needed here
        html += `<span>${segment}</span>`;
      }
    });
  
    // Set the processed HTML as the innerHTML of the remaining text span
    
    this.remainingTextSpan.innerHTML = html;
    this.verifyAndHandleTimer();
  },
  moveCaretBeforeRemainingText(){
    const sel = window.getSelection();
    const range = document.createRange();
    // Position the range right before the this.remainingTextSpan
          range.setStartBefore(this.remainingTextSpan);
          range.collapse(true); // Collapse the range to its start point to ensure it doesn't span any content
          
          sel.removeAllRanges(); // Clear any existing selections
          sel.addRange(range); // Add the new range, which positions the caret
          
          this.editableContainer.focus(); // Ensure the editable container is focused
        },

        rightArrow() {
          // I can just simulate a rightarrow
    
          const event = new KeyboardEvent('keydown', {
            key: "ArrowRight",
            code: "ArrowRight",
            keyCode: 39, // Deprecated but included for compatibility
            which: 39, // Deprecated but included for compatibility
            bubbles: true,
            cancelable: true
          });
    
          document.dispatchEvent(event);
        
    
    
    
          
        },
        handleBackspace() {
          if (this.typedLength > 0) {
            this.typedLength--;
            this.editableContainer.removeChild(this.editableContainer.childNodes[this.typedLength+1]);
            // updateRemainingText();
            // let removeIndex = this.typedLength; // Adjust if your indexing needs refinement
            // let childNodes = Array.from(editableContainer.childNodes);
            // let targetNode = childNodes.find((node, index) => index === removeIndex);
            // if (targetNode) editableContainer.removeChild(targetNode);
            this.updateRemainingText();
            
          }
        },
        handleEnter() {
          //const currentLine = getCurrentLine(editableContainer.textContent, this.typedLength);
          const remainingLineText = this.phraseText.substring(this.typedLength).split('\n')[0];
          const nextLineStartIndex = this.typedLength + remainingLineText.length + 1; // +1 for the newline character itself
        
          // Replace remaining text in the current line with a marker (if any)
          if (remainingLineText.trim().length > 0) {
            for (let _char of remainingLineText) {
              this.appendChar('|', false); // Using • as a marker, marking it as incorrect for visual distinction
              this.typedLength++;
            }
          }
        
          // Move to the next line
          this.appendNewLine(true);
          this.typedLength++; // Account for the newline character
        
          // Handle blank lines by not appending indentation until the next Enter press
          const nextLineText = this.phraseText.substring(nextLineStartIndex).split('\n')[0];
          if (nextLineText.trim().length === 0) {
            // If the next line is blank, simply wait at the end/beginning of the line
          } else {
            // For non-blank lines, insert the correct indentation
            const indentationLevel = this.getIndentationLevel(nextLineText);
            console.log(indentationLevel);
            for (let i = 0; i < indentationLevel; i++) {
              this.appendChar( ' ', true);//nextLineText[i] === '\t' ? '\t' :
              // appendChar( '&nbsp;', true);
              // appendChar( '&nbsp;', true);
              // appendChar( '&nbsp;', true);
              this.typedLength++;
              
            }
          }
        
          this.updateRemainingText();
          this.moveCaretBeforeRemainingText();
        },
        updateAndPushUserInput() {
          // Obtain the full text including both the user's input and the remaining text
          let fullText = this.el.innerText;
      
          // If you have stored the initial remaining text in this.remainingText upon initialization or another method,
          // you can use it to trim off the remaining text from the full text.
          
          if (this.remainingTextSpan) {
              // Obtain only the portion of the text that precedes the remaining text
              let remainingTextIndex = fullText.lastIndexOf(this.remainingTextSpan.innerText);
              this.userInput = remainingTextIndex >= 0 ? fullText.substring(0, remainingTextIndex) : fullText;
          } else {
              // If for some reason the remainingTextSpan is not available, fallback to using the full text.
              this.userInput = fullText;
          }
      
          // Trim the userInput to remove any leading or trailing whitespace
          this.userInput = this.userInput.trim();
      
          // Now, send the trimmed userInput to the server
          this.pushEvent("input", { user_input: this.userInput });
      },
      
  startTimer() {
    if (!this.timerStarted) {
      this.startTime = new Date();
      this.timerStarted = true;
      this.updateTimer(); // Start the smooth timer update
    }
  },

  updateTimer() {
    if (!this.timerStarted) {
      return; // Stop the timer update loop if the timer is not supposed to be running
    }
    const now = new Date();
    this.elapsedTime = now - this.startTime;
    const seconds = (this.elapsedTime / 1000).toFixed(2); // Convert to seconds with two decimal places

    const timerDisplay = document.getElementById('js-timer');
    if (timerDisplay) {
      timerDisplay.textContent = `JS Elapsed time: ${seconds} seconds`;
    }

    requestAnimationFrame(this.updateTimer.bind(this)); // Ensure proper context for `this`
  },

  stopTimer() {
    if (this.timerStarted) {
      this.timerStarted = false;
      const endTime = new Date();
      this.elapsedTime = endTime - this.startTime; // Update elapsedTime to ensure it's current
      const seconds = this.elapsedTime / 1000; // Convert to seconds
      const minutes = seconds / 60; // Convert to minutes

      // Adjust how you calculate totalChars and wordsTyped based on your input handling
      const totalChars = this.typedLength; // Assuming typedLength accurately reflects the number of typed characters
      console.log(totalChars);
      const wordsTyped = totalChars / 5; // Standard definition of a "word"
      const wpm = wordsTyped / minutes; // Calculate words per minute

      const timerDisplay = document.getElementById('js-timer');
      if (timerDisplay) {
        timerDisplay.textContent = `Final time: ${seconds.toFixed(2)} seconds, ${wpm.toFixed(2)} WPM`;
      }
    }
  },
  verifyAndHandleTimer() {
    const charSpans = this.el.querySelectorAll(':scope > span:not(#remaining-text)');
    // Check if there are no spans with the 'incorrect' class
    // const noErrors = Array.from(charSpans).every(span => !span.classList.contains('incorrect'));
    const allCorrect = Array.from(charSpans).every(span => span.classList.contains('correct'));
    // Ensure the length matches the target phrase to consider completion
    if (allCorrect && charSpans.length === this.phraseText.length) {
      console.log("Input complete without errors.");
      this.stopTimer();
      document.getElementById('completion-message').innerText="🎉 Congratulations! You've completed the typing task! 🎉"
      // Additional logic for handling the completion of input without errors
    } else {
      // Handle cases where input is not complete or contains errors
    }
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
  
//process the phrase into words because it wraps like 1 whole big word rn


    
   
     
    
    
   
    // function updateRemainingText() {
    //   // Convert the remaining phrase text into a format suitable for HTML display
    //   let newText = phraseText.substring(typedLength)
    //     .replace(/\n/g, '<br>') // Convert newline characters to <br> for display
    //     .replace(/\t/g, '    '); // Optionally convert tabs to spaces for visual consistency
    
    //   // Handle markers for skipped text (if using special characters like •)
    //   // Ensure that these markers are also properly displayed
    //   newText = newText.replace(/•/g, '<span class="marker">•</span>');
    
    //   remainingTextSpan.innerHTML = newText; // Use innerHTML to interpret <br> tags and other HTML entities
    // }
    
    



    
    // function updateRemainingText() {
    //   let newText = phraseText.substring(typedLength)
    //     .replace(/\n/g, '<br>') // Convert newline characters to <br>
    //     .replace(/ /g, '&nbsp;') // Convert spaces to non-breaking spaces
    //     // .replace(/\t/g, '<span class="tab">    </span>'); // Optionally represent tabs with a styled span
    
    //   remainingTextSpan.innerHTML = newText;
    // }
    // function updateRemainingText() {
    //   let newText = phraseText.substring(typedLength).replace(/\n/g, '<br>'); // Convert newline characters to <br> for display
    //   remainingTextSpan.innerHTML = newText; // Use innerHTML to interpret <br> tags
    // }
    

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
// function updateTimer() {
//   if (!timerStarted) {
//     return; // Stop the timer update loop if the timer is not supposed to be running
//   }
//   const now = new Date();
//   elapsedTime = now - startTime;
//   const seconds = (elapsedTime / 1000).toFixed(2); //1 Convert to seconds with two decimal places

//   const timerDisplay = document.getElementById('js-timer');
//   if (timerDisplay) {
//     timerDisplay.textContent = `JS Elapsed time: ${seconds} seconds`;
//   }

//   requestAnimationFrame(updateTimer);
// }

// function startTimer() {
//   if (!timerStarted) {
//     startTime = new Date();
//     timerStarted = true;
//     updateTimer(); // Start the smooth timer update
//   }
// }

// function stopTimer() {
//   if (timerStarted) {
//     timerStarted = false;
//     const endTime = new Date();
//     elapsedTime = endTime - startTime; // Update elapsedTime to ensure it's current
//     const seconds = elapsedTime / 1000; // Convert to seconds
//     const minutes = seconds / 60; // Convert to minutes
    

//     const totalChars = userInputField.innerText.length;
//     console.log(totalChars);
//     const wordsTyped = totalChars / 5; // Standard definition of a "word"
//     const wpm = wordsTyped / minutes; // Calculate words per minute

//     const timerDisplay = document.getElementById('js-timer');
//     if (timerDisplay) {
//       timerDisplay.textContent = `Final time: ${seconds.toFixed(2)} seconds, ${wpm.toFixed(2)} WPM`;
//     }
//   }
// }

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

