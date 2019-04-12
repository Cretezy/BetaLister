import * as React from "react";

import Layout from "../components/layout";
import Meta from "../components/meta";
import { Link } from "gatsby";

export default function NotFound() {
  return (
    <Layout>
      <Meta title="Not found" />
      <h2>Page not found.</h2>
      <Link to='/'>Go back home.</Link>
    </Layout>
  );
}
