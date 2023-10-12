const puppeteer = require("puppeteer");
const fs = require("fs");

async function scrapeSECWebsite() {
  const browser = await puppeteer.launch({ headless: false }); // Launch Puppeteer in non-headless mode
  const page = await browser.newPage();
  await page.goto("https://www.sec.gov/edgar/search/");

  // Step 1 - Use Search bar
  await page.type("#entity-short-form", "Apple");
  await page.waitForTimeout(1000);

  // Step 2 - Click on Search button
  //   await page.click('#search');
  //   await page.waitForTimeout(1000);

  // Step 2 - Click on Search button and wait for a specific element to appear
  await Promise.all([
    page.waitForNavigation(), // Wait for navigation to complete
    page.click("#search"),
  ]);

  // Step 3 - Click on the anchor tag inside div with id "headingTwo2"
  await page.waitForSelector("#headingTwo2 a");
  await page.click("#headingTwo2 a");

  //   // Step 4 - Select 10-K from the dropdown
  //   await page.click('a[data-filter-key="10-K"]');

  //   // Step 5 - Click on 10-K option
  //   await page.waitForXPath('//a[contains(@class, "preview-file") and contains(text(), "10K")]');
  //   const links = await page.$x('//a[contains(@class, "preview-file") and contains(text(), "10K")]');

  //   for (const link of links) {
  //     const linkText = await (await link.getProperty('textContent')).jsonValue();
  //     await link.click();

  //     // Step 6 - Click on Open Filing option in modal
  //     await page.waitForSelector('#open-submission');
  //     await page.click('#open-submission');

  //     // Step 7 - Find and click on the anchor tag with a link to the new website
  //     await page.waitForSelector('table#tableFile tr td a');
  //     const anchors = await page.$$('table#tableFile tr td a');

  //     for (const anchor of anchors) {
  //       const href = await (await anchor.getProperty('href')).jsonValue();
  //       // Download the HTML content and save it to a file
  //       const response = await page.goto(href);
  //       const content = await response.text();
  //       const fileName = `10K_${linkText}.html`;
  //       fs.writeFileSync(fileName, content);
  //     }

  //     // Go back to the previous page to process the next 10-K filing
  //     await page.goBack();
  //   }

  //   await browser.close();
}

scrapeSECWebsite();
