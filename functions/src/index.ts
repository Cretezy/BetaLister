// tslint:disable-next-line
import "dotenv/config";

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

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
        const beta = await getPackageStatus(packageName);

        if (beta !== null) {
          await packageRef.set({ beta });
          packagesCache[packageName] = beta;
        }

        response[packageName] = beta;
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

async function getPackageStatus(packageName: string): Promise<boolean | null> {
  try {
    const results = await client.get(packageName);

    return !results.data.includes("App not available");
  } catch (error) {
    console.error(`Error check status: for ${packageName}`, error);

    return null;
  }
}
