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

export const checkPackages = functions.https.onCall(
  async ({ packageNames }) => {
    const packagesRef = admin.firestore().collection("packages");
    const packages = {};

    const addRequestPromise = admin
      .firestore()
      .collection("requests")
      .add({ packageNames, time: new Date() });

    const fetchPackagesPromises = packageNames.map(async packageName => {
      const packageRef = packagesRef.doc(packageName);
      const packageInfo = await packageRef.get();

      if (!packageInfo.exists) {
        try {
          const results = await client.get(packageName);

          const beta = !results.data.includes("App not available");

          await packageRef.set({ beta });

          packages[packageName] = beta;
        } catch (error) {
          console.error(error);
          packages[packageName] = null;
        }
      } else {
        packages[packageName] = packageInfo.data().beta;
      }
    });

    await Promise.all([addRequestPromise, ...fetchPackagesPromises]);

    return packages;
  }
);
