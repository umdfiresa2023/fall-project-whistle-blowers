const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

const url = 'https://www.sec.gov/Archives/edgar/data/29915/000002991519000008/dow201810k.htm';

axios.get(url)
  .then(response => {
    const html = response.data;
    const $ = cheerio.load(html);

    // Get the text content of the entire page
    const pageText = $('body').text();
    
    // Split the text into sentences or paragraphs based on your document structure
    const paragraphs = pageText.split(/\s*\.\s*|\s*\n\s*/);

    // Search for occurrences of the word "environment" and store the context
    const keyword = 'environment';
    const contextLength = 50; // Number of characters to show before and after the keyword
    const extractedContexts = [];

    paragraphs.forEach(paragraph => {
      const index = paragraph.indexOf(keyword);
      if (index !== -1) {
        const start = Math.max(index - contextLength, 0);
        const end = index + keyword.length + contextLength;
        const context = paragraph.substring(start, end);
        extractedContexts.push(context);
      }
    });

    // Create an HTML file with the extracted contexts
    const extractedHTML = `<html><body>${extractedContexts.join('<br><br>')}</body></html>`;
    fs.writeFile('extracted_environment.html', extractedHTML, (err) => {
      if (err) {
        console.error('Error writing HTML file:', err);
      } else {
        console.log('Extracted data saved successfully as extracted_environment.html');
      }
    });
  })
  .catch(error => {
    console.error('Error fetching data:', error);
  });

