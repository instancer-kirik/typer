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
import { pickFile } from "./file_picker";
import ResizeContent from "./hooks/resize_content"

//import "htmx.org";
let Hooks = { ResizeContent: ResizeContent};
// Hooks.Multiplayer = {
//   mounted() {
//     this.handleEvent("update_user_input", (payload) => {
//       console.log(payload.user_input);
//     });
//   }
// };

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

Hooks.FilePicker = {// this is for the md file picker in the post live
  mounted() {
    console.log("FilePicker hook mounted");
    this.el.addEventListener("click", () => {
      console.log("FilePicker clicked");
      let input = document.createElement('input');
      input.type = 'file';
      input.accept = '.md';
      input.onchange = (e) => {
        console.log("File selected");
        let file = e.target.files[0];
        let reader = new FileReader();
        reader.onload = (e) => {
          console.log("File read, pushing event");
          this.pushEvent("file-selected", {
            filename: file.name,
            contents: e.target.result
          });
        };
        reader.readAsText(file);
      };
      input.click();
    });
  }
}
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
Hooks.ProgressFader = {
  mounted() {
    this.el.addEventListener("animationend", () => {
      this.el.classList.remove("user-other-progress", "user-unsigned-progress");
    });
  },
  updated() {
    if (this.el.classList.contains("user-other-progress") || this.el.classList.contains("user-unsigned-progress")) {
      setTimeout(() => {
        this.el.querySelector("::after").classList.add("fading");
      }, 100);
    }
  }
}



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
    this.el.addEventListener('input', () => {
      this.sendInputToServer();
      // this.updateColorFillEffect();
    });
     // Initialize timer-related properties
     this.timerStarted = false;
     this.elapsedTime = 0;
     this.startTime = null;
     this.userInput ="";
    //'' this.showElixir = this.el.dataset.showElixir === "true";
    const phraseData =document.getElementById("phrase-data");
    if (!phraseData ) return;
    this.phraseText =phraseData.dataset.phraseText; //this.convertToEntities(phraseData.dataset.phraseText);
    // Convert your phrase to use HTML entities
     // Assuming phraseData.dataset.phraseText might contain HTML entities/tags
   
    //this.phraseText = cleanText; // Cleaned and ready for counting
    this.typableCharacters =this.countText2(phraseData.dataset.phraseText); // Accurate character count
    this.typedLength = 0; // Tracks how many characters have been correctly or incorrectly typeds

    this.editableContainer = document.getElementById('editable-container');
    this.remainingTextSpan = document.getElementById('remaining-text');
  
    this.rightArrow();
      

    // this.editableContainer.addEventListener('input', () => {
    //   this.updateContent();
    // });

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
      }else if (e.key =='Tab'){
        e.preventDefault();
        document.getElementById('completion-message').innerHTML =
        "if (e.key =='Tab'){" + "<br>" +
        "&nbsp;&nbsp;&nbsp;&nbsp;" + "e.preventDefault();" + "<br>" +
        "&nbsp;&nbsp;&nbsp;&nbsp;" + "document.getElementById('completion-message').innerText = " +"<br>"+ 
        "&nbsp;&nbsp;&nbsp;&nbsp;" +"\"if (e.key =='Tab'){" + "<br>" + 
        "&nbsp;&nbsp;&nbsp;&nbsp;" +"&nbsp;&nbsp;&nbsp;&nbsp;" + "e.preventDefault();" + "<br>" +
        "&nbsp;&nbsp;&nbsp;&nbsp;" +"&nbsp;&nbsp;&nbsp;&nbsp;" +"document.getElementById('completion-message').innerText = ..." + "<br>" +
        "&nbsp;&nbsp;&nbsp;&nbsp;" + "&nbsp;&nbsp;&nbsp;&nbsp;" +  "this.el.focus();"+ "<br>" +
        "&nbsp;&nbsp;&nbsp;&nbsp;" +"}\";" + "<br>" +
        "&nbsp;&nbsp;&nbsp;&nbsp;" +  "this.el.focus();"+ "<br>" +"}";
        this.el.focus();
      }
      this.updateAndPushUserInput();
    });

    this.el.focus();
    // Calculate initial indentation of the first line and adjust cursor position accordingly
  this.adjustCursorForInitialNewlinesAndIndentation();
  this.updateRemainingText();//this takes it out of the initial render as block to multiline regular display
  // this.colorFillEffect = this.el.querySelector('.color-fill-effect');
  // if (!this.colorFillEffect) {
  //   this.colorFillEffect = document.createElement('div');
  //   this.colorFillEffect.className = 'color-fill-effect';
  //   this.el.insertBefore(this.colorFillEffect, this.el.firstChild);
  // }

  //   this.updateColorFillEffect();
  },//mounted  

  
  updated() {
    this.el.focus();
  },
  // updateContent() {
  //   // Get the raw text content
  //   let textContent = this.editableContainer.innerText;
  
  //   // Clear the current content
  //   this.editableContainer.innerHTML = '';
  
  //   // Rebuild the content, wrapping each known character in a span
  //   // and appending the remaining text in its own span
  //   [...textContent].forEach(char => {
  //     const charSpan = document.createElement('span');
  //     charSpan.textContent = char;
  //     this.editableContainer.appendChild(charSpan);
  //   });
  
  //   // Append the remaining text span if necessary
  //   const remainingTextSpan = document.createElement('span');
  //   remainingTextSpan.id = 'remaining-text';
  //   // Set the remaining text content appropriately
  //   //remainingTextSpan.textContent = /* remaining text */;
  //   this.editableContainer.appendChild(remainingTextSpan);
  
  //   // Ensure cursor management to place the cursor correctly after updates
  //   this.setCursorPosition();
  // },
  // updateColorFillEffect() {
  //   if (!this.colorFillEffect) return;

  //   const progress = this.typedLength / this.typableCharacters;
  //   const hue = progress * 120; // This will transition from red (0) to green (120)
  //   this.colorFillEffect.style.width = `${progress * 100}%`;
  //   this.colorFillEffect.style.backgroundColor = `hsla(${hue}, 100%, 50%, 0.3)`;
  // },
  
  // handleCharacterInput(key) {
  //   if (this.typedLength < this.typableCharacters) {
  //     this.typedLength++;
  //     this.updateColorFillEffect();
  //   }
  // },



  handleCharacterInput(char) {
    
    let correctChar = this.phraseText.charAt(this.typedLength);

    // Special handling for HTML entities
  if (correctChar === '&') {
    // Check if the next sequence is an HTML entity, adjust `typedLength` and `correctChar` accordingly
    const entityMatch = this.phraseText.substring(this.typedLength).match(/^(&[a-z]+;)/);
    if (entityMatch) {
      correctChar = this.htmlEntityToChar(entityMatch[0]); // Convert HTML entity to char for comparison
      if (char === correctChar) {
        this.typedLength += entityMatch[0].length - 1; // Adjust typedLength to skip the entire entity
      }
    }
  }
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
        //this.appendIndentation();
      } else if (correctChar === '\t') {
        this.appendTab();
      } else {
        this.appendChar(char, true);
      }
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
    }
      this.typedLength++;
      this.moveCaretBeforeRemainingText();
      this.updateRemainingText();
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
    console.log(result);
    return result ? result[1].length : 0;
  },
  determineNextLineIndentation() {
    // Find the start of the current line
    const currentLineStart = this.phraseText.lastIndexOf('\n', this.typedLength - 1) + 1;
    // Calculate the end of the current line
    let currentLineEnd = this.phraseText.indexOf('\n', this.typedLength);
    if (currentLineEnd === -1) currentLineEnd = this.phraseText.length;
  
    // Extract the current line text
    const currentLineText = this.phraseText.substring(currentLineStart, currentLineEnd);
  
    // Use a regex to match leading whitespace characters (spaces or tabs)
    const leadingWhitespaceMatch = currentLineText.match(/^[\s\t]*/);
    if (leadingWhitespaceMatch) {
      return leadingWhitespaceMatch[0].length; // Return the count of leading whitespace characters
    }
  
    return 0; // Default to no indentation if there's no leading whitespace
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
    //console.log("this.phraseText")
    //console.log(this.phraseText)
    // Process each segment, wrapping words in spans and preserving whitespace
    segments.forEach(segment => {
      //console.log(segment)
      if (segment.match(/\s+/)) {
        // For segments that are purely whitespace, replace spaces with &nbsp; but leave newlines as <br>
        html += segment.replace(/\n/g, '<br>');
      } else {
        // Wrap words in spans to keep them unbroken; no &nbsp; needed here
        html += `<span>${this.escapeHtml(segment)}</span>`;
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
  escapeHtml(text) {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  },
        
  // Utility function to convert HTML entities back to characters for comparison
  htmlEntityToChar(entity) {
    const textarea = document.createElement('textarea');
    textarea.innerHTML = entity;
    return textarea.value;
  },
  getTextContentFromHtml(htmlString) {
    const tempDiv = document.createElement("div");
    // Set the innerHTML to the provided string
    tempDiv.innerHTML = htmlString;
    // Use textContent to get the decoded and tag-free content
    return tempDiv.textContent || tempDiv.innerText || "";
},
inspectTextForCounts(text) {
  // Assuming \n for newlines; adjust if necessary (e.g., \r\n for Windows-style breaks)
  const newlineAdjustedText = text.replace(/\r\n/g, "\n");
  const totalCharacters = newlineAdjustedText.length;

  // Detailed inspection for debugging
  // console.log(`Total characters (including spaces and line breaks): ${totalCharacters}`);
  // newlineAdjustedText.split('').forEach((char, index) => {
  //     console.log(`${index + 1}: '${char}' (${char.charCodeAt(0)})`);
  // });

  return totalCharacters;
},
countText(htmlString) {
  const div = document.createElement('div');
  div.innerHTML = htmlString;
  const text = div.textContent || div.innerText || "";
  // Replace all types of whitespace with a single space for consistent counting
  const cleanedText = text.replace(/\s+/g, ' ').trim();
  return cleanedText.length;
},
countText2(text) {
  // Replace each tab with 4 spaces
  const textWithTabsAsSpaces = text.replace(/\t/g, "    ");
  
  // Remove all line breaks (\r for carriage return, \n for newline)
  const textWithoutLineBreaks = textWithTabsAsSpaces.replace(/[\r\n]+/g, '');
  
  // Now, count the remaining characters
  const totalCharacters = textWithoutLineBreaks.length;
  
  return totalCharacters;
},
countText3(text) {
  // Convert tabs to 4 spaces
  let convertedText = text.replace(/\t/g, "    ");
  
  // Split the text by newlines to process lines individually
  let lines = convertedText.split(/\r?\n/);

  // Process each line to trim leading and trailing spaces as they might not be intended for counting
  // Especially leading spaces before a line break could be unintentional
  lines = lines.map(line => line.trimStart());

  // Rejoin the lines without newlines as they are not counted
  const processedText = lines.join('');

  // Count the characters in the processed text
  const totalCharacters = processedText.length;
  
  return totalCharacters;
},
  // Method to adjust cursor for initial newlines and indentation
adjustCursorForInitialNewlinesAndIndentation() {
  let textAfterNewlines = this.phraseText;
  // Skip leading newlines
  while(textAfterNewlines.startsWith('\n')) {
    this.appendNewLine(true); // true to simulate correct input; adjust based on your method signature
    textAfterNewlines = textAfterNewlines.substring(1);
    this.typedLength++; // Increase typedLength to account for the newline character
  }

  // Now calculate the indentation of the first non-empty line
  const initialIndentation = this.getIndentationLevel(textAfterNewlines);
  for (let i = 0; i < initialIndentation; i++) {
    console.log("APPENDING");
    this.appendChar(' ', true); // Assuming space for indentation; adjust for tabs as needed
    this.typedLength++; // Adjust typedLength for each space added
  }
  
  this.moveCaretBeforeRemainingText(); // Ensure the caret is correctly positioned after adjustments
},
  // adjustCursorForInitialIndentation() {
  //   const initialIndentation = this.getIndentationLevel(this.phraseText);
  //   // Assuming appendChar method can handle space ' ' and correctly position it
  //   for (let i = 0; i < initialIndentation; i++) {
  //     this.handleCharacterInput(" "); // Pass 'true' to simulate correct input for the sake of positioning
  //   }
  //   this.moveCaretBeforeRemainingText(); // Ensure the caret is moved after the initial spaces
  // },
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
          // Identify the end of the current line or use the full text length if no newline character is found.
          let endOfCurrentLineIndex = this.phraseText.indexOf('\n', this.typedLength);
          if (endOfCurrentLineIndex === -1) {
              endOfCurrentLineIndex = this.phraseText.length;
          }
        
          // Mark the rest of the current line as incorrect if Enter is pressed before reaching its end.
          if (this.typedLength < endOfCurrentLineIndex) {
              this.markRemainingAsIncorrect(this.typedLength, endOfCurrentLineIndex);
              // Ensure typedLength points to the end of the current line, ready to move to the next line.
              this.typedLength = endOfCurrentLineIndex;
          }
        
          // Handle moving to the next line: append a visual representation of a newline if needed.
          if (this.typedLength < this.phraseText.length - 1) {
              this.appendNewLine();
          }
        
          // Update the cursor position to the start of the next line.
          this.typedLength++;
          // Now, let's determine and apply the correct indentation for the new line.
          const nextLineIndentation = this.determineNextLineIndentation();
          for (let i = 0; i < nextLineIndentation; i++) {
              this.appendChar(' ', true); // Assuming space for indentation; adjust if using tabs.
              this.typedLength++;
          }
          // Update the UI to reflect the changes.
          this.updateRemainingText();
          this.moveCaretBeforeRemainingText();
        },
      markAsIncorrect(startIndex, endIndex) {
        const textContainer = document.getElementById('textContainer');
        const characterSpans = textContainer.getElementsByTagName('span');
    
        // Loop from startIndex to endIndex, marking each character as incorrect
        for (let i = startIndex; i < endIndex; i++) {
            if (characterSpans[i]) { // Check if the span exists to avoid errors
                characterSpans[i].classList.add('incorrect');
            }
        }
    },
        
    markRemainingAsIncorrect(startIndex, endIndex) {
      for (let i = startIndex; i < endIndex; i++) {
        // Create a visual indicator for incorrect characters.
        // This example uses '|' as the indicator, but you might use a different approach.
        this.appendChar('|', false); 
      }
    },
        updateAndPushUserInput() {
          // Obtain the full text including both the user's input and the remaining text
          let fullText = this.el.innerText;
      
          // If you have stored the initial remaining text in this.remainingTextSpan upon initialization or another method,
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
          //if(this.showElixir){
          // Now, send the trimmed userInput to the server
          this.pushEvent("input", { user_input: this.userInput });
          // Log the sent input for debugging
          console.log("Sent user input to server:", this.userInput);
          //}
          
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
  // verifyAndHandleTimer() {
  //   const charSpans = this.el.querySelectorAll(':scope > span:not(#remaining-text)');
  //   // Check if there are no spans with the 'incorrect' class
  //   // const noErrors = Array.from(charSpans).every(span => !span.classList.contains('incorrect'));
  //   const allCorrect = Array.from(charSpans).every(span => span.classList.contains('correct'));
  //   // Ensure the length matches the target phrase to consider completion
  //   if (allCorrect && charSpans.length === this.phraseText.length) {
  //     console.log("Input complete without errors.");
  //     this.stopTimer();
  //     document.getElementById('completion-message').innerText="🎉 Congratulations! You've completed the typing task! 🎉"
  //     // Additional logic for handling the completion of input without errors
  //   } else {
  //     // Handle cases where input is not complete or contains errors
  //   }
  // }  
  verifyAndHandleTimer() {
    
    const charSpans = this.el.querySelectorAll(':scope > span:not(#remaining-text)');
    const allCorrect = Array.from(charSpans).every(span => span.classList.contains('correct'));
    
   
    // Total attempted characters include both correct and incorrect ones
    const totalAttempted = charSpans.length;
    const correctChars = Array.from(charSpans).filter(span => span.classList.contains('correct')).length;
    const m = `totalAttempted ${totalAttempted} all: ${this.typableCharacters}`;
    console.log(m);
    // Ensure the length matches the target phrase to consider completion
    if( totalAttempted === this.typableCharacters) {
      if (allCorrect){
       
      this.stopTimer();
      document.getElementById('completion-message').innerText = "🎉 Congratulations! You've completed the typing task! 🎉";
      // Additional logic for handling the completion of input without errors
    } else {
      this.stopTimer();
  
      const accuracy = (correctChars / totalAttempted) * 100;
      
      document.getElementById('completion-message').innerText = `Yay. You\'ve concluded the typing task! Accuracy: ${accuracy.toFixed(2)}%`;
    }
  }
  
  },
  sendInputToServer() {
    let userInput = this.getUserInput();
    this.pushEvent("input", { user_input: userInput });
  },

  
  
  getUserInput() {
    // This method should return the current user input as a string
    return this.el.innerText;
  },

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
  

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
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

