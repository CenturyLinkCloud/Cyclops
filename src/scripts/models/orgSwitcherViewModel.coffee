# TODO:
# - animation and the scroll-area are off
# - iphone layout
# - will disabled accounts be passed to us?

# - arrow keys with search

# DONE:
# - keydown events on mobile
# - textbox on mobile causes a zoom font-sizes greater that 16 dont cause this :)
# - remove monkey class
# - textbox style
# - logic in scrollTo for detecting if it is offScreen is wrong

class Organization
  constructor: (options) ->
    @rawOrg = options.rawOrg
    @alias = @rawOrg.accountAlias
    @name = ko.asObservable(@rawOrg.businessName)
    @status = ko.asObservable(@rawOrg.accountStatus)
    @primaryDatacenter = ko.asObservable(@rawOrg.primaryDataCenter)

    @path = options.path
    @depth = options.depth
    @depthHtml = ''
    for idx in [0..@depth] when idx > 0
      @depthHtml = "#{@depthHtml}<span class='marker'>&mdash;</span>"

    @pathDisplayText = ko.pureComputed () =>
      return "#{@path} - #{@name()}"

class OrgSwitcherViewModel
  constructor: (options) ->
    options = options || {}

    @isOpen = ko.observable false
    @toggleHandler = (data, event) =>
      $('body').toggleClass 'org-switcher-open'
      @isOpen !@isOpen()
      if @isOpen()
        $('org-switcher .take-over .search-input input').focus()
        $('org-switcher .toggle-btn svg').animate(
          {  deg: 180 },
          {
            step: (now,fx) ->
              $(this).css('-webkit-transform','rotate('+now+'deg)');
              $(this).css('-moz-transform','rotate('+now+'deg)');
              $(this).css('transform','rotate('+now+'deg)');
            , duration: 250
        }, 250);
      else
        $('org-switcher .toggle-btn svg').animate(
          {  deg: 0 },
          {
            step: (now,fx) ->
              $(this).css('-webkit-transform','rotate('+now+'deg)');
              $(this).css('-moz-transform','rotate('+now+'deg)');
              $(this).css('transform','rotate('+now+'deg)');
            , duration: 250
        },250);
        @clearSearch()
        @forceShowAllOrgs false
        _activeItemIndex -1

    _close = () =>
      $('body').removeClass 'org-switcher-open'
      @isOpen false
      @clearSearch()
      @forceShowAllOrgs false
      _activeItemIndex -1

    @clearSearch = () =>
      @flatOrgList.query ''
      _activeItemIndex = -1

    @impersonatedAlias = ko.asObservable(options.impersonatedAlias)
    @rawOrganizations = ko.asObservableArray(options.organizations || [])


    @flatOrgList = ko.filterableArray([], {
      fields: ['alias', 'name'],
      comperer: (query, org) ->
        if org.alias.indexOf(querytoLowerCase()) == 0
          return true
        if org.businessName.toLowerCase().indexOf(query.toLowerCase()) > -1
          return true
        return false
    });

    # if they change the query turn off force all
    @flatOrgList.query.subscribe () =>
      @forceShowAllOrgs(false)
    , null, 'beforeChange'

    @isSearching = ko.computed () =>
      return !!@flatOrgList.query()

    _doStuff = (options) =>
      path = "#{options.path} / #{options.rawOrg.accountAlias}"
      depth = options.depth++
      options.array.push new Organization { rawOrg: options.rawOrg, path: path, depth: depth }
      options.rawOrg.subAccounts.forEach (org) =>
        _doStuff { rawOrg: org, path: path, depth: depth + 1, array: options.array }

    _doesntMatter = ko.computed () =>

      _tempArray = []
      @rawOrganizations().forEach (org) =>
        _doStuff { rawOrg: org, path: '', depth: 0, array: _tempArray }
      @flatOrgList(_tempArray)

      return

    @getImpersonatedOrgDiaplayText = (org) ->
      return "#{org.alias.toUpperCase()} - #{ko.unwrap(org.name)}"

    @impersonatedOrg = ko.observable()

    @impersonatedOrg.subscribe (newValue) =>
      @impersonatedAlias(newValue.alias)

    foo = @flatOrgList().filter (org) =>
      org.alias.toLowerCase() == @impersonatedAlias().toLowerCase()

    if foo.length == 1
      @impersonatedOrg foo[0]
    else
      throw 'alias is not right'

    @impersonateOrg = (org)  =>
      @impersonatedOrg(org)
      @toggleHandler()


    # Everything to do with showing limited results for perf

    pageSize = 50;

    @forceShowAllOrgs = ko.observable(false);

    @showAllOrgsHandler = () =>
      @forceShowAllOrgs true

    @showingAllOrgs = ko.pureComputed () =>
      total = @flatOrgList().length
      visible = @displayOrgs().length
      return visible == total

    @limitedOrgsDisplayedMessage = ko.pureComputed () =>
      total = @flatOrgList().length
      visible = @displayOrgs().length

      if @forceShowAllOrgs() or visible == total
        if @isSearching()
          return "#{total} organizations with '#{@flatOrgList.query()}'"
        return "#{total} organizations"
      else
        if @isSearching()
          return "Showing #{visible} of #{total} organizations with '#{@flatOrgList.query()}'"
      return "Showing #{visible} of #{total} organizations"

    @displayOrgs = ko.pureComputed () =>
      if @forceShowAllOrgs()
        return @flatOrgList()
      end = 1 * pageSize # 1 is the starting page, could be changed in the future
      start = end - pageSize
      return @flatOrgList().slice(start, end);


    _activeItemIndex = ko.observable(-1)
    @activeItem = ko.pureComputed () =>
      value = _activeItemIndex()
      if value > -1
        return @displayOrgs()[value]

    @hoverHandler = (data, event) =>
      _activeItemIndex @displayOrgs().indexOf(data)

    @isActiveItem = (data) =>
      return data == @activeItem()

    @isCurrentItem = (data) =>
      return data == @impersonatedOrg()

    @forceShowAllOrgs.subscribe () ->
      _activeItemIndex 0

    @userScrolling = ko.observable(false);
    _timer = null
    $(".scroll-area").on 'scroll', () =>
      @userScrolling  true
      window.clearTimeout(_timer)
      _timer = window.setTimeout () =>
        @userScrolling  false
      , 500


    $(document).on 'keydown', (e) =>
      if e.ctrlKey && e.keyCode ==73
        @toggleHandler()

      else if(@isOpen())
        # up arrow
        if e.keyCode == 38
          if _activeItemIndex() > 0
            _activeItemIndex _activeItemIndex() - 1
          else
            _activeItemIndex(@displayOrgs().length - 1)

        # down arrow
        else if e.keyCode == 40
          if _activeItemIndex() < @displayOrgs().length - 1
            _activeItemIndex _activeItemIndex() + 1
            return false
          else
            _activeItemIndex(0)

        # esc arrow
        else if e.keyCode == 27
          _close()
          return false

        # enter
        else if e.keyCode == 13
          e.preventDefault()
          @impersonateOrg(@activeItem())
          return false;
