# What's New in Version 1.1.0
- [Account Context Switcher](http://assets.ctl.io/cyclops/1.1.0/components.html#accountSwitcher)
- [Nav Tabs component](http://assets.ctl.io/cyclops/1.1.0/components.html#navTabs)
- [Multi and single server selector](http://assets.ctl.io/cyclops/1.1.0/forms.html#hierarchyPicker)
- [Group picker](http://assets.ctl.io/cyclops/1.1.0/forms.html#groupPicker)
- [Server picker](http://assets.ctl.io/cyclops/1.1.0/forms.html#serverPicker)
- [Icons](http://assets.ctl.io/cyclops/1.1.0/icons.html)
  - Bell
  - Exclamation Triangle
  - Failover
  - Messaging (Text)
  - Queue Add
  - Queue Archive
  - Queue Delete
  - Queue Restore

- New Knockout bindings
  - title
  - scrollTo
  - indeterminate

- [Pagination component](http://assets.ctl.io/cyclops/1.1.0/components.html#pagination)
- [Price Estimate component on Create Page](http://assets.ctl.io/cyclops/1.1.0/components.html#priceEstimate)
- [Show password](http://assets.ctl.io/cyclops/1.1.0/components.html#showPassword)
- ["Add" Card example](http://assets.ctl.io/cyclops/1.1.0/cards.html#addCard)
- Fixed anchor links in button dropdown
- Back to Top button on Cyclops documentation pages (lower right of the page)
- The ["Kitchen Sink"](http://assets.ctl.io/cyclops/1.1.0/all.html): A single page that displays all styles and components for quick testing purposes.
- Fixed a bug where the tick marks were on the wrong side of the [slider](http://assets.ctl.io/cyclops/1.1.0/forms.html#slider)
- Allow button tags to be used in action-toolbar in addition to a tags.
- Fixed bug where the slider didn't allow you to drag all the way to the maximum value
- Fixed bug where validation messages would BUFOC

--------------------------------------------------------------------------------

[![CenturyLink Cyclops](www/assets/img/centurylink-cyclops.png)](http://assets.ctl.io/)

# CYCLOPS
The UX/UI Pattern Guide for the CenturyLink Platform

## Get Started
Cyclops is hosted on the [CenturyLink Platform assets server](http://assets.ctl.io/) for anyone to use. Add `.cyclops` to the `html` tag to properly scope the styles. This allows Cyclops to override any existing styles that have been defined by legacy markup. See the [version documentation](http://assets.ctl.io/) for what includes are required.

## Developing Cyclops

```
npm install
gulp dev
```
