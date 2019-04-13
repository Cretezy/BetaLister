import * as React from "react";
import { css } from "@emotion/core";

import Layout from "../components/layout";
import Meta from "../components/meta";
import { mobileOnly } from "../utils/media-queries";

export default function Index() {
  return (
    <Layout>
      <Meta title="Home" />
      <h2>Find Beta Versions Of Installed Apps</h2>
      <a href="https://play.google.com/store/apps/details?id=app.betalister&utm_source=website">
        <img
          css={css`
            width: 300px;
            margin: 0;
            @media ${mobileOnly} {
              width: 200px;
            }
          `}
          alt="Get it on Google Play"
          src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
        />
      </a>
      <br />
      <small>
        Google Play and the Google Play logo are trademarks of Google LLC.
      </small>
    </Layout>
  );
}
