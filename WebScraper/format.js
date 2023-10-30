import fs from "fs";


// Specify the input and output file paths
const inputFile = '2011.txt'; // Replace with your input file path
const outputFile = 'output.txt'; // Replace with your output file path

// Read the content of the input file
fs.readFile(inputFile, 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading the input file:', err);
    return;
  }

  // Replace characters with commas
  const strippedString = data.replace(/[.,\t\n\r\s]/g, ',');

  // Write the formatted content to the output file
  fs.writeFile(outputFile, strippedString, 'utf8', (err) => {
    if (err) {
      console.error('Error writing to the output file:', err);
      return;
    }

    console.log('File formatting complete.');
  });
});

