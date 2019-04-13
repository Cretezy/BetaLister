// tslint:disable-next-line
import "dotenv/config";

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

let entities;
let entitiesPromise;

admin.initializeApp();

const client = axios.create({
  baseURL: "https://play.google.com/apps/testing/",
  headers: { Cookie: process.env.COOKIE },
  responseType: "text",
  maxContentLength: 999999
});

// In-memory cache
const packagesCache = {};

export const checkPackages = functions.https.onCall(
  async ({ packageNames }) => {
    if (!Array.isArray(packageNames)) {
      return null;
    }

    const response = {};

    const packagesRef = admin.firestore().collection("packages");

    const addRequestPromise = admin
      .firestore()
      .collection("requests")
      .add({ packageNames, time: new Date() });

    const fetchPackagesPromises = packageNames.map(async packageName => {
      if (packageName in packagesCache) {
        response[packageName] = packagesCache[packageName];
        return;
      }

      const packageRef = packagesRef.doc(packageName);
      const packageInfo = await packageRef.get();

      if (!packageInfo.exists) {
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

        response[packageName] = beta;
        packagesCache[packageName] = beta;
      }
    });

    await Promise.all(fetchPackagesPromises);
    await addRequestPromise;

    return response;
  }
);

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
    if (!entities && !entitiesPromise) {
      entitiesPromise = (async () => {
        entities = await import("entities");
      })();
    }

    const results = await client.get(packageName);
    await entitiesPromise;

    const beta = !results.data.includes("App not available");
    const name = beta
      ? entities.decodeHTML(results.data.match(/>App: (.*?)</)[1])
      : null;
    const owner = beta
      ? entities.decodeHTML(results.data.match(/>Owner: (.*?)</)[1])
      : null;

    const icon = beta
      ? results.data.match(/img class="icon" src="(.*?)"/)[1]
      : null;

    return { beta, name, owner, icon };
  } catch (error) {
    console.error(`Error check status: for ${packageName}`, error);

    return null;
  }
}
