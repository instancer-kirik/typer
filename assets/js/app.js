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


Hooks.DarkModeToggle = {
  mounted() {
    this.applyInitialTheme();

    this.el.addEventListener("click", () => {
      // Toggle between mytheme and mytheme2 based on the current class
      const newTheme = document.body.classList.contains("mytheme") ? "mytheme2" : "mytheme";
      document.body.classList.toggle("mytheme");
      document.body.classList.toggle("mytheme2");

      // Update the data attribute to reflect the new state
      this.el.dataset.darkMode = newTheme === "mytheme2" ? "true" : "false";

      // Update the cookie to reflect the current theme
      this.setCookie("dark_mode", newTheme === "mytheme2" ? "true" : "false", 365);

      // Optionally, push the event to LiveView to update the server-side state
      this.pushEvent("toggle_dark_mode", { dark_mode: newTheme === "mytheme2" });
    });
  },

  applyInitialTheme() {
    const currentTheme = this.getCookie("dark_mode");
    // Apply the theme based on the cookie value
    if (currentTheme === "true") {
      document.body.classList.add("mytheme2");
      document.body.classList.remove("mytheme");
    } else {
      document.body.classList.add("mytheme");
      document.body.classList.remove("mytheme2");
    }
  },

  setCookie(name, value, days) {
    let expires = "";
    if (days) {
      let date = new Date();
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
      expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "") + expires + "; path=/";
  },

  getCookie(name) {
    let nameEQ = name + "=";
    let ca = document.cookie.split(';');
    for(let i=0;i < ca.length;i++) {
        let c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
  }
};
Hooks.AutoFocus = {
  mounted() {
    this.el.focus();
    //this.pushEvent("process_input", { key: this.el.innerHTML });11ss22srrraaassssssrr
    
    
  },
  updated() {
    this.el.focus();
  }
};
Hooks.ForceReload = {
  mounted() {
    //console.log("ForceReload hook mounted.");
    this.handleEvent("update_client", () => {
      //console.log(payload.message); // Server says hello
      window.location.reload();
    });
    this.handleEvent("alert", (payload) => {
      console.log(payload.message); // Server says hello
      // window.location.reload();
    });
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


Hooks.Countdown = {
  mounted() {
    this.handleCountdown();
  },
  handleCountdown() {
    let duration = 2; // Start at 2 because 3 is already displayed
    let countdownElement = this.el;
    //let contentElement = document.getElementById("content");

    let interval = setInterval(() => {
      let currentNumber = parseInt(countdownElement.innerText, 10);
      if (currentNumber > 1) {
        countdownElement.innerText = currentNumber - 1;
      } else {
        clearInterval(interval);
        countdownElement.style.display = "none"; // Hide the countdown
        countdownElement.innerText ="";
        countdownElement.style.show="false";
        //contentElement.style.display = "block"; // Show your content
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
     this.showElixir = this.el.dataset.showElixir === "true";
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
  
  updated() {
    this.el.focus();
  },
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
          if(this.showElixir){
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
        }
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
  

//-------------------------------------------------------------------------------------------------------------------------------
  
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

