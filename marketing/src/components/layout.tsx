import * as React from "react";

import Header from "./header";
import "./layout.css";

export default function Layout({ children }) {
  return (
    <>
      <Header />
      <div
        style={{
          margin: "0 auto",
          maxWidth: 960,
          padding: "0px 1.0875rem 1.45rem",
          paddingTop: 0
        }}
      >
        <main>{children}</main>
        <footer>© {new Date().getFullYear()} Charles Crete</footer>
      </div>
    </>
  );
}
