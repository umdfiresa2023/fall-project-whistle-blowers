const fs = require("fs");
const sanitize = require("sanitize-filename");
const puppeteer = require("puppeteer-extra");

// add stealth plugin and use defaults (all evasion techniques)
const StealthPlugin = require("puppeteer-extra-plugin-stealth");
puppeteer.use(StealthPlugin());

const { executablePath } = require("puppeteer");

const companyNames = {
  DOW: "DOW",
  // Add more companies if needed
};

async function scrapeSECWebsite() {
  const browser = await puppeteer.launch({
    headless: true,
    executablePath: executablePath(),
  });

  for (const companyName in companyNames) {
    const entityName = companyNames[companyName];
    const url = `https://www.sec.gov/edgar/search/#/q=${companyName}&dateRange=custom&category=form-cat1&entityName=${entityName.toUpperCase()}&startdt=2010-12-31&enddt=2021-12-31&filter_forms=10-K`;

    const page = await browser.newPage();

    try {
      await page.goto(url);
      await page.waitForTimeout(2000);

      await page.keyboard.press("Enter");

      await page.waitForTimeout(1000);

      const result = await page.evaluate(() => {
        const tableElement = document.querySelector("div#hits table.table");
        if (tableElement) {
          const tbody = tableElement.querySelector("tbody");
          if (tbody) {
            const links = Array.from(tbody.querySelectorAll("a"));
            return links.map((link) => ({
              href: link.href,
              text: link.textContent,
            }));
          } else {
            return "Tbody element not found inside the table";
          }
        } else {
          return "Table element not found";
        }
      });

      const filteredLinks = [];

      result.forEach((linkInfo) => {
        filteredLinks.push(linkInfo.href);
      });

      for (const href of filteredLinks) {
        if (href.includes("ex")) {
          console.log(href);
        } else {
          if (href.includes("#")) {
            const yearArray = [];
            const yearPattern = /\d{4}(?!10K)/;
            const matches = href.match(yearPattern);
            if (matches) {
              const year = matches[0];
              if (year in yearArray) {
                console.log(year);
              } else if (yearArray.length <= 12) {
                const parts = href.split("#");
                const selector = `a[href="#${parts[1]}"]`;
                yearArray.push(year);
                await page.click(selector);

                const openFileLink = await page.$eval("a#open-file", (link) =>
                  link.getAttribute("href")
                );
                await page.waitForTimeout(300);

                console.log("\n");
                console.log("The actual link is: " + openFileLink);
                scrapeTextAndSaveToFile(openFileLink, year);
                console.log("\n");

                await page.waitForTimeout(100);
                await page.click("button#close-modal");
              } else {
                break;
              }
            }
          }
        }

        await page.waitForTimeout(100);
      }
    } catch (error) {
      console.error("Error:", error);
    }
  }

  await browser.close();
}

async function scrapeTextAndSaveToFile(url, year) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  try {
    const folderName =
      "/Users/ishaankalra/Documents/GitHub/fall-project-whistle-blowers/WebScraper/test";

    if (!fs.existsSync(folderName)) {
      fs.mkdirSync(folderName);
    }

    await page.goto(url, { waitUntil: "networkidle2" });

    const textContent = await page.evaluate(() => {
      return document.body.textContent;
    });

    // Create a sanitized filename based on the year
    const sanitizedYear = sanitize(year);
    const filename = `${folderName}/${sanitizedYear}.txt`;

    let strippedString = textContent.replace(/(<([^>]+)>)/gi, "");

    fs.writeFileSync(filename, strippedString);
    console.log(`Text content saved to ${filename}`);
  } catch (error) {
    console.error(`Error scraping and saving text: ${error}`);
  } finally {
    await browser.close();
  }
}

scrapeSECWebsite();
