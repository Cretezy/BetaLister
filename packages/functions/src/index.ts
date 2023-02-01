// tslint:disable-next-line
import "dotenv/config";

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
// import type { decodeHTML } from "entities"

let decodeHTML: typeof import("entities")["decodeHTML"];
let decodeHTMLPromise: Promise<void>;

admin.initializeApp();

const client = axios.create({
  baseURL: "https://play.google.com/apps/testing/",
  headers: { Cookie: process.env.COOKIE },
  responseType: "text",
  maxContentLength: 999999,
});

// In-memory cache
const packagesCache = {};

export const checkPackages = functions
  .runWith({
    timeoutSeconds: 120,
    memory: "512MB",
  })
  .https.onCall(async ({ packageNames }) => {
    if (!Array.isArray(packageNames)) {
      return null;
    }

    const response = {};

    const packagesRef = admin.firestore().collection("packages");

    const addRequestPromise = admin
      .firestore()
      .collection("requests")
      .add({ packageNames, time: new Date() });

    const fetchPackagesPromises = packageNames.map(async (packageName) => {
      try {
        if (packageName in packagesCache) {
          response[packageName] = packagesCache[packageName];
          return;
        }

        const packageRef = packagesRef.doc(packageName);
        const packageInfo = await packageRef.get();

        if (!packageInfo.exists || !packageInfo.data().name) {
          const data = await getPackageStatus(packageName);

          if (data === null) {
            response[packageName] = null;
            return;
          }

          await packageRef.set(data);

          packagesCache[packageName] = data.beta;
          response[packageName] = data.beta;
        } else {
          const { beta } = packageInfo.data();

          response[packageName] = !!beta;
          packagesCache[packageName] = !!beta;
        }
      } catch (error) {
        console.error(`Error checking package ${packageName}`, error);
      }
    });

    await Promise.all(fetchPackagesPromises);
    await addRequestPromise;

    return response;
  });

interface PackageStatus {
  beta: boolean;
  name: string;
  owner: string;
  icon: string;
}

async function getPackageStatus(
  packageName: string
): Promise<PackageStatus | null> {
  try {
    if (!decodeHTML && !decodeHTMLPromise) {
      decodeHTMLPromise = (async () => {
        decodeHTML = (await import("entities")).decodeHTML;
      })();
    }

    const results = await client.get(packageName);
    await decodeHTMLPromise;

    const nameMatch = results.data.match(/>App: (.*?)</);
    const ownerMatch = results.data.match(/>Owner: (.*?)</);

    const beta = !!(
      !results.data.includes("App not available") &&
      nameMatch &&
      ownerMatch
    );

    const name = beta ? decodeHTML(nameMatch[1]) : null;
    const owner = beta ? decodeHTML(ownerMatch[1]) : null;

    const iconMatch = results.data.match(/img class="icon" src="(.*?)"/);

    const icon = beta && iconMatch ? iconMatch[1] : null;

    return { beta, name, owner, icon };
  } catch (error) {
    console.error(`Error check status: for ${packageName}`, error);

    return null;
  }
}
