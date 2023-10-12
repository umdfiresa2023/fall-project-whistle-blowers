const puppeteer = require("puppeteer");
const fs = require("fs");

async function scrapeSECWebsite() {
  const browser = await puppeteer.launch({ headless: false }); // Launch Puppeteer in non-headless mode
  const page = await browser.newPage();
  await page.goto("https://www.sec.gov/edgar/search/");

  try {
    // Step 1 - Use Search bar
    await page.type("#entity-short-form", "Apple");
    await page.waitForTimeout(2000); // Wait for 2 seconds

    // Step 2 - Click on Search button and wait for navigation to complete
    await Promise.all([
      page.click("#search"),
      page.waitForNavigation({ waitUntil: "domcontentloaded" }),
    ]);

    // Step 3 - Wait for the anchor tag inside div with id "headingTwo2" to appear and click on the anchor tag
    const headingTwo2Link = await page.waitForSelector("#headingTwo2 a", {
      visible: true,
    });
    await headingTwo2Link.click();

    // Step 4 - Select 10-K from the dropdown
    await page.click('a[data-filter-key="10-K"]');

    

  } catch (error) {
    console.error("Error:", error);
  } finally {
    // Close the browser when done
    // await browser.close();
  }
}

scrapeSECWebsite();
