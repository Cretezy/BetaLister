import "dotenv/config";
import axios from "axios";
import * as R from "ramda";
import * as querystring from "querystring";
import * as fs from "fs-extra";

const getResults = x => R.path(["result", x]);

const unflattenObj = R.pipe(
  R.toPairs,
  R.reduce((acc, value) => {
    const [key, val] = value;
    return R.assocPath(R.split(".", key), val, acc);
  }, {})
);

async function main() {
  const options = {
    api_token: process.env.POEDITOR_API_KEY,
    id: process.env.POEDITOR_PROJECT_ID
  };

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

    await fs.writeJson(`../mobile/assets/i18n/${language}.json`, unflattenObj(terms));


  })(languages);

  await Promise.all(termsPromises);
}

main();
