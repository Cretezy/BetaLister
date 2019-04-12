module.exports = {
  plugins: [
    "gatsby-plugin-typescript",
    "gatsby-plugin-emotion",
    "gatsby-plugin-react-helmet",
    {
      resolve: "gatsby-source-filesystem",
      options: {
        name: "images",
        path: `${__dirname}/src/images`
      }
    },
    "gatsby-transformer-sharp",
    "gatsby-plugin-sharp",
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
