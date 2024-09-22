let lastFileHandle = null;

const pickFile = async (inputElement) => {
  try {
    const options = {
      types: [
        {
          description: 'Markdown files',
          accept: {
            'text/markdown': ['.md']
          }
        },
      ],
    };

    if (lastFileHandle) {
      options.startIn = lastFileHandle;
    }

    const [fileHandle] = await window.showOpenFilePicker(options);
    lastFileHandle = fileHandle;

    const file = await fileHandle.getFile();
    let contents = await file.text();

    // Process Obsidian-style image links
    const { processedContent, imageReferences } = processObsidianImages(contents);

    // Send the processed file contents and image references back to the LiveView
    inputElement.dispatchEvent(new CustomEvent('file-selected', {
      detail: { 
        filename: file.name, 
        contents: processedContent,
        imageReferences: imageReferences
      },
      bubbles: true
    }));

  } catch (err) {
    console.error('Error picking file:', err);
  }
};

function processObsidianImages(content) {
  const imageRegex = /!\[\[([^|\]\n]+)(\|([^\]\n]+))?\]\]/g;
  const matches = content.matchAll(imageRegex);
  const imageReferences = [];

  for (const match of matches) {
    const [fullMatch, imageName, _, altText] = match;
    imageReferences.push({
      name: imageName,
      altText: altText || imageName
    });

    // Replace Obsidian-style link with a placeholder
    content = content.replace(fullMatch, `![${altText || imageName}](PLACEHOLDER_${imageName})`);
  }

  return { processedContent: content, imageReferences };
}

export { pickFile };