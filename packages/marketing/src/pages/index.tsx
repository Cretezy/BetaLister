import * as React from "react";
import { css } from "@emotion/core";

import Layout from "../components/layout";
import Meta from "../components/meta";
import { mobileOnly } from "../utils/media-queries";
import { OutboundLink } from "gatsby-plugin-google-analytics";
import screenshot1 from "../images/1.png";
import screenshot2 from "../images/2.png";

const screenshotCss = css`
  width: 100%;
  height: 100%;
`;

const screenshotWrapperCss = css`
  margin: 24px;
  @media ${mobileOnly} {
    margin: 10px;
  }
`;

export default function Index() {
  return (
    <Layout>
      <Meta title="Home" />
      <h2>Find Beta Versions Of Installed Apps</h2>

      <p>
        Love being on the bleeding edge of your software? Craving to be ahead of
        the curve for updates? Look no more, Beta Lister is there for you.
      </p>
      <p>
        Beta Lister finds all available betas for apps installed on your device.
      </p>

      <h3> Features</h3>
      <ul>
        <li>Lists installed apps with app information (icon, name, version)</li>
        <li>Shows beta availability for apps</li>
        <li> Links directly to beta enrollment page</li>
      </ul>

      <p>
        Have an app that crashes? Maybe it's beta fixes it! <br />
        Have an app you want to help out? Beta test for the developers!
      </p>

      <div
        css={css`
          display: flex;
        `}
      >
        <div css={screenshotWrapperCss}>
          <img src={screenshot1} css={screenshotCss} />
        </div>
        <div css={screenshotWrapperCss}>
          <img src={screenshot2} css={screenshotCss} />
        </div>
      </div>

      <div
        css={css`
          text-align: center;
        `}
      >
        <OutboundLink href="https://play.google.com/store/apps/details?id=app.betalister&utm_source=website">
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
        </OutboundLink>
      </div>

      <small>
        Google Play and the Google Play logo are trademarks of Google LLC.
      </small>
    </Layout>
  );
}
