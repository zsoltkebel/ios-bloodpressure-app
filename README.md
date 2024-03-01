# Blood Pressure, Heart Rate Log

## Configure

You need a project.xcconfig file at the root of the project with the following contents:

```xcconfig
PRODUCT_BUNDLE_IDENTIFIER = <bunndle id>
DEVELOPMENT_TEAM = <developer team id>
```

Once that is set up you need to tell Xcode to [load build settings from a file](https://stackoverflow.com/questions/75215730/is-there-a-way-to-hide-bundle-id-and-apple-developer-team-from-public-github-pro
).

