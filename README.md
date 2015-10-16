[![CenturyLink Cyclops](www/assets/img/centurylink-cyclops.png)](http://assets.ctl.io/)

# CYCLOPS
The UX/UI Pattern Guide for the CenturyLink Platform

## Get Started
Cyclops is hosted on the [CenturyLink Platform assets server](http://assets.ctl.io/) for anyone to use. Add `.cyclops` to the `html` tag to properly scope the styles. This allows Cyclops to override any existing styles that have been defined by legacy markup.

```
<html lang="en" class="cyclops">
```

Then, include these links in your page layouts:

```
<!-- In between the head tags -->
<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600" rel="stylesheet" type="text/css">
<link href="https://assets.ctl.io/cyclops/0.1.0-alpha.3/css/cyclops.min.css" rel="stylesheet" type="text/css" />
<!-- your styles here -->

<!-- ...your page content... -->

<!-- At the bottom of your page -->

<script src="https://code.jquery.com/jquery-2.1.4.min.js" ></script>
<script src="https://ajax.aspnetcdn.com/ajax/knockout/knockout-3.3.0.js" ></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/knockout-validation/2.0.3/knockout.validation.min.js" ></script>
<script src="https://assets.ctl.io/cyclops/0.1.0-alpha.3/scripts/cyclops.min.js" ></script>
<!-- your scripts here -->
```

## Developing Cyclops

```
npm install
gulp dev
```
