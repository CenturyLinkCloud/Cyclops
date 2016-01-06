For the latest release info, see the [Release section](https://github.com/CenturyLinkCloud/Cyclops/releases).

--------------------------------------------------------------------------------

[![CenturyLink Cyclops](www/assets/img/centurylink-cyclops.png)](http://assets.ctl.io/)

# CYCLOPS
The UX/UI Pattern Guide for the CenturyLink Platform

## Get Started
Include the built cyclops javaScript and CSS files as well as the dependencies listed below. Add `.cyclops` to the `html` tag to properly scope the styles. This allows Cyclops to override any existing styles that have been defined by legacy markup. Documentation for cyclops can be viewed by running the development server `gulp dev`


## Developing Cyclops

```
npm install coffee -g
npm install
gulp dev
```

## Creating a Release/Build
Releases are placed in the `dist` folder at the root of the project inside of a version number folder. The version number is pulled from `package.json`
```
gulp dist
```

## Dependencies
For more information view the [dependencies page](https://github.com/CenturyLinkCloud/Cyclops/blob/master/www/views/dependencies.html) in the documentation.

## Required
* [jQuery](https://jquery.com/) >= 2.1.4
* [Knockout](http://knockoutjs.com/) >= 3.3.0 

### Optional
* [jQuery UI](https://jqueryui.com/) >= 1.11.4
* [Knockout Validation](https://github.com/Knockout-Contrib/Knockout-Validation) >= 2.0.3

## Credit

#### [Bootstrap](http://getbootstrap.com/)
Much of this pattern library is based on [Bootstrap](http://getbootstrap.com/). We've taken many foundational patterns from this project, and extended it to suit the needs of CenturyLink's Platform.

#### [FontAwesome](http://fontawesome.io/)
Many of the icons in the SVG icon library are based off of the work done by [FontAwesome](https://github.com/FortAwesome/Font-Awesome).

#### Matthew Osborn
* https://twitter.com/osbornm
* https://github.com/osbornm

#### Rathromony Ros
* https://twitter.com/hellorathy
* https://github.com/rathromony

#### Nathan Young
* https://twitter.com/nathanyoung
* https://github.com/nathanyoung

## License

Code and documentation is released under the [MIT license](https://github.com/CenturyLinkCloud/Cyclops/blob/master/LICENSE).

### NOTE
Cyclops uses several 3rd party libraries, a list of which can be viewed in the [package.json](https://github.com/CenturyLinkCloud/Cyclops/blob/master/package.json) file, please review each of their license and user agreements as well.
