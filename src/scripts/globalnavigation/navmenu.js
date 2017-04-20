var currentServiceName = '';
var currentService = '';
var servicesList = ['CAM', 'MH', 'MS', 'CLC', 'DCC'];

toggleMenu = function() {
    var servicesMenuContainer, servicesMenuFade, servicesMenuItem;
    servicesMenuContainer = document.getElementById('services-menu-container');
    servicesMenuFade = document.getElementById('services-menu-fade');
    servicesMenuItem = document.getElementById('navbar-services-menu');
    servicesMenuContainer.classList.toggle('hidden');
    servicesMenuFade.classList.toggle('hidden');
    servicesMenuItem.classList.toggle('open');
    if (!servicesMenuContainer.classList.contains('hidden')) {
        insertServicesMenuAt('services-menu', this.currentService, this.servicesList);
        servicesMenuFade.style.height = '100%';
    }
};

setServicesList = function(displayList) {
  return this.servicesList = displayList;
};

setCurrentService = function(service) {
  var navbarServicesMenuCurrentService;
  this.currentService = service;
  this.currentServiceName = (function() {
    switch (false) {
      case service !== 'CAM':
        return 'Cloud Application Manager';
      case service !== 'MH':
        return 'Managed Hosting';
      case service !== 'MS':
        return 'Managed Security';
      case service !== 'CLC':
        return 'Public Cloud';
      case service !== 'DCC':
        return 'Private Cloud';
    }
  })();
  navbarServicesMenuCurrentService = document.getElementById('navbar-services-menu__current_service');
  navbarServicesMenuCurrentService.textContent = this.currentServiceName;
};

window.setCurrentService = setCurrentService;
window.setServicesList = setServicesList;