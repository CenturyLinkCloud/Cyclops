/* testing function */

function toggleMenu(){
    var servicesMenuContainer = document.getElementById('services-menu-container');
    var servicesMenuFade = document.getElementById('services-menu-fade');
    var servicesMenuItem = document.getElementById('navbar-services-menu');

    servicesMenuContainer.classList.toggle('hidden');
    servicesMenuFade.classList.toggle('hidden');
    servicesMenuItem.classList.toggle('open');

    if (!servicesMenuContainer.classList.contains('hidden')) {
        insertServicesMenuAt('services-menu', 'DCC', ['CAM', 'MH', 'MS', 'CLC','DCC']);
        servicesMenuFade.style.height = '100%';
    }
}