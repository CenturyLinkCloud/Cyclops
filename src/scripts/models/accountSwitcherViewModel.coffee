class Account
  constructor: (options) ->
    @rawAcct = options.rawAcct
    @alias = @rawAcct.accountAlias
    @name = ko.asObservable(@rawAcct.businessName)

    @primaryDatacenter = ko.asObservable(@rawAcct.primaryDataCenter)

    @path = options.path
    @depth = options.depth
    @depthHtml = ''
    for idx in [0..@depth] when idx > 0
      @depthHtml = "#{@depthHtml}<span class='marker'>&mdash;</span>"

    @pathDisplayText = ko.pureComputed () =>
      return "#{@path} - #{@name()}"

class AccountSwitcherViewModel
  constructor: (options) ->
    options = options || {}

    @isOpen = ko.observable false

    @isOpen.subscribe (newValue) =>
      if newValue
        $("account-switcher .take-over").animate({ top: 40, bottom: 0 })
      else
        $("account-switcher .take-over").animate({ top: '-100%', bottom: '100%' })

    @toggleHandler = (data, event) =>
      $('body').toggleClass 'account-switcher-open'
      @isOpen !@isOpen()
      if @isOpen()
        if !@loading()
          $('account-switcher .take-over .search-input input').focus()
        $('account-switcher .toggle-btn svg').animate(
          {  deg: 180 },
          {
            step: (now,fx) ->
              $(this).css('-webkit-transform','rotate('+now+'deg)');
              $(this).css('-moz-transform','rotate('+now+'deg)');
              $(this).css('transform','rotate('+now+'deg)');
            , duration: 250
        }, 250);
      else
        $('account-switcher .toggle-btn svg').animate(
          {  deg: 0 },
          {
            step: (now,fx) ->
              $(this).css('-webkit-transform','rotate('+now+'deg)');
              $(this).css('-moz-transform','rotate('+now+'deg)');
              $(this).css('transform','rotate('+now+'deg)');
            , duration: 250
        },250);
        @clearSearch()
        @forceShowAllAccts false
        _activeItemIndex -1

    _close = () =>
      $('body').removeClass 'account-switcher-open'
      @isOpen false
      @clearSearch()
      @forceShowAllAccts false
      _activeItemIndex -1

    @clearSearch = () =>
      @flatOrgList.query ''
      _activeItemIndex = -1
      @flatOrgList.clearSort()

    @currentAccountAlias = ko.asObservable(options.currentAccountAlias)

    @loading = ko.asObservable(options.loading)

    @rawAccounts = ko.asObservableArray(options.accounts || [])

    @flatOrgList = ko.filterableArray([], {
      fields: ['alias', 'name'],
      comperer: (query, acct) ->
        if acct.alias.indexOf(query.toLowerCase()) == 0
          return true
        if acct.businessName.toLowerCase().indexOf(query.toLowerCase()) > -1
          return true
        return false
    });

    # if they change the query turn off force all
    @flatOrgList.query.subscribe () =>
      @forceShowAllAccts(false)
      _activeItemIndex 0
    , null, 'beforeChange'


    @isSearching = ko.computed () =>
      return !!@flatOrgList.query()

    _createAccountModel = (options) =>
      path = "#{options.path} / #{options.rawAcct.accountAlias}"
      depth = options.depth++
      options.accounts.push new Account { rawAcct: options.rawAcct, path: path, depth: depth }
      options.rawAcct.subAccounts.forEach (acct) =>
        _createAccountModel { rawAcct: acct, path: path, depth: depth + 1, accounts: options.accounts }

    ko.computed () =>
      accounts = []
      @rawAccounts().forEach (acct) =>
        _createAccountModel { rawAcct: acct, path: '', depth: 0, accounts: accounts }
      @flatOrgList(accounts)
      return

    @getImpersonatedOrgDiaplayText = (acct) =>
      return "#{acct.alias.toUpperCase()} - #{ko.unwrap(acct.name)}"

    @impersonatedOrg = ko.observable()

    @impersonatedOrg.subscribe (newValue) =>
      @currentAccountAlias(newValue.alias)

    _setCurrentAccount = () =>
      possibleAccounts = @flatOrgList().filter (acct) =>
        acct.alias.toLowerCase() == @currentAccountAlias().toLowerCase()

      if possibleAccounts.length == 1
        @impersonatedOrg possibleAccounts[0]
      else
        throw 'There is more than one account with the same alias, this should not be possible check the data please.'


    if !@loading()
      _setCurrentAccount()
    else
      @loading.subscribe (newValue) =>
        if !newValue
          _setCurrentAccount()


    @impersonateOrg = (acct)  =>
      @impersonatedOrg(acct)
      @toggleHandler()


    ###############################
    # Limit the num of accts shown
    ###############################

    pageSize = 50;

    @forceShowAllAccts = ko.observable(false);

    @showAllOrgsHandler = () =>
      @forceShowAllAccts true

    @showingAllOrgs = ko.pureComputed () =>
      total = @flatOrgList().length
      visible = @displayOrgs().length
      return visible == total

    @limitedOrgsDisplayedMessage = ko.pureComputed () =>
      total = @flatOrgList().length
      visible = @displayOrgs().length

      if @loading()
        return ''
      else if @forceShowAllAccts() or visible == total
        return "#{total} accounts"
      else
        return "Showing #{visible} of #{total} accounts"


    _sortByWeight = (a,b) =>
      query = @flatOrgList.query()
      aVal = _calcWeight(a, query)
      bVal = _calcWeight(b, query)

      if (aVal > bVal)
        return -1;
      else if (aVal < bVal)
        return 1;
      else
        if @flatOrgList.all().indexOf(a) < @flatOrgList.all().indexOf(b)
          return -1
        else
          return 1


    _calcWeight = (acct, query) ->
      result = 0
      if(!!query)
        query = query.toLowerCase()
        # exact alias matches should always be first
        alias = acct.alias.toLowerCase()
        if alias == query
          result += 100
        # if alais starts with query
        else if alias.indexOf(query) == 0
          result += 30

        idx = acct.rawAcct.businessName.toLowerCase().indexOf(query)
        # if the business name starts with the query
        if idx == 0
          result += 20
        # if the business name contains with the query
        else if idx > -1
          result += 10

      return result


    @displayOrgs = ko.pureComputed () =>
      result = @flatOrgList()
      if not @forceShowAllAccts()
        end = 1 * pageSize # 1 is the starting page, could be changed in the future
        start = end - pageSize
        result = @flatOrgList().slice(start, end)
      return helpers.stableMergeSort(result, _sortByWeight)

    ###############################
    # Selection of account logic
    ###############################

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

    @forceShowAllAccts.subscribe () ->
      _activeItemIndex 0


    ###############################
    # Keyboard shortcut wireup
    ###############################
    $(document).on 'keydown', (e) =>
      if e.ctrlKey && e.keyCode ==73
        @toggleHandler()

      else if(@isOpen())
        # up arrow
        if e.keyCode == 38
          if _activeItemIndex() > 0
            _activeItemIndex _activeItemIndex() - 1
          return false

        # down arrow
        else if e.keyCode == 40
          if _activeItemIndex() < @displayOrgs().length - 1
            _activeItemIndex _activeItemIndex() + 1
          return false

        # esc arrow
        else if e.keyCode == 27
          _close()
          return false

        # enter
        else if e.keyCode == 13
          e.preventDefault()
          activeAccount = @activeItem()
          if activeAccount
            @impersonateOrg(activeAccount)
          return false;
