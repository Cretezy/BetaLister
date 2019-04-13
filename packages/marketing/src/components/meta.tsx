import * as React from "react";
import Helmet from "react-helmet";

interface MetaProps {
  title?: string;
  description?: string;
  keywords?: string[];
  meta?: object[];
}

export default function Meta({
  description,
  meta = [],
  keywords,
  title
}: MetaProps) {
  return (
    <Helmet
      htmlAttributes={{
        lang: "en"
      }}
      title={title}
      titleTemplate={"%s | Beta Lister"}
      meta={[
        title && {
          property: "og:title",
          content: title
        },
        title && {
          name: "twitter:title",
          content: title
        },
        description && {
          name: "description",
          content: description
        },
        description && {
          property: "og:description",
          content: description
        },
        description && {
          name: "twitter:description",
          content: description
        },
        {
          property: "og:type",
          content: "website"
        },
        {
          name: "twitter:card",
          content: "summary"
        },
        keywords &&
          keywords.length && {
            name: "keywords",
            content: keywords.join(", ")
          },
        ...meta
      ].filter(Boolean)}
    />
  );
}
