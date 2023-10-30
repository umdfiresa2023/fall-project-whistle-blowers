import fs from "fs";

// Specify the input and output file paths
const inputFile = "2021.txt"; // Replace with your input file path
const outputFile = "output.txt"; // Replace with your output file path

// Read the content of the input file
// fs.readFile(inputFile, "utf8", (err, data) => {
//   if (err) {
//     console.error("Error reading the input file:", err);
//     return;
//   }

//   // Replace characters with commas
//   const strippedString = data.replace(/[.\t\n\r\s]/g, " ");

//   // Write the formatted content to the output file
//   fs.writeFile(outputFile, strippedString, "utf8", (err) => {
//     if (err) {
//       console.error("Error writing to the output file:", err);
//       return;
//     }

//     console.log("File formatting complete.");
//   });
// });

fs.readFile("output.txt", "utf-8", (err, data) => {
  const pattern = /Revenues\s+\$ (\d+(,\d{3})*(\.\d{2})?)/;

  // Use the regular expression to find the match
  const match = data.match(pattern);

  if (match) {
    // Extract the matched number
    const revenues = parseFloat(match[1].replace(/,/g, '')); // Remove commas and convert to float
    const revenuesInMillions = revenues * 1000000;
    console.log(`Found Revenues: $ ${revenuesInMillions}`);
  } else {
    console.log("Revenues not found in the text file.");
  }
});
