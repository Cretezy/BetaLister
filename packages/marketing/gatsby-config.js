module.exports = {
  plugins: [
    "gatsby-plugin-typescript",
    "gatsby-plugin-emotion",
    {
      resolve: "gatsby-plugin-google-analytics",
      options: {
        trackingId: "UA-138323558-1",
        head: false,
        anonymize: true,
        respectDNT: true
      }
    },
    {
      resolve: "gatsby-plugin-manifest",
      options: {
        name: "Beta Lister",
        short_name: "starter",
        start_url: "/",
        background_color: "#F44336",
        theme_color: "#F44336",
        display: "minimal-ui",
        icon: "src/images/icon.png"
      }
    }
  ]
};
