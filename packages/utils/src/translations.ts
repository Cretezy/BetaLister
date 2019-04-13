import "dotenv/config";
import axios from "axios";
import * as R from "ramda";
import * as querystring from "querystring";
import * as fs from "fs-extra";
import * as path from "path";

// Utils
const getResults = x => R.path(["result", x]);
const unflattenObj = R.pipe(
  R.toPairs,
  R.reduce((acc, value) => {
    const [key, val] = value;
    return R.assocPath(R.split(".", key), val, acc);
  }, {})
);

const options = {
  api_token: process.env.POEDITOR_API_KEY,
  id: process.env.POEDITOR_PROJECT_ID
};

const translationsPath = "../mobile/assets/i18n";

async function main() {
  // Reset translations directory
  await fs.remove(translationsPath);
  await fs.ensureDir(translationsPath);
  await fs.writeFile(
    path.join(translationsPath, "README"),
    "Do not manually edit these files, they are automatically generated from POEditor."
  );

  console.log("Fetching languages...");

  const { data: languagesResults } = await axios.post(
    " https://api.poeditor.com/v2/languages/list",
    querystring.stringify(options)
  );

  const languages = R.pipe(
    getResults("languages"),
    R.map(R.prop("code"))
  )(languagesResults);

  console.log("Got languages:", languages.join(", "));

  const termsPromises = R.map(async language => {
    console.log("Fetching terms for language", language);

    const { data: termsResults } = await axios.post(
      " https://api.poeditor.com/v2/terms/list",
      querystring.stringify({
        ...options,
        language
      })
    );

    const terms = R.pipe(
      getResults("terms"),
      R.map(({ term, translation }) => [term, translation.content]),
      R.fromPairs
    )(termsResults);

    await fs.writeJson(
      path.join(translationsPath, `${language}.json`),
      unflattenObj(terms)
    );

    console.log("Saved terms for language", language);
  })(languages);

  await Promise.all(termsPromises);
}

main();
