class DateTimePickerViewModel
  constructor: (options) ->
    options = $.extend {
      dateTime: ko.observable(moment().add(1, 'days'))
    }, options

    @hourOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
      13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    @minuteOptions = [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
      24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43,
      44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59
    ]
    @zoneOptions = [
      { display: "UTC-12:00", value: -720 }
      { display: "UTC-11:00", value: -660 }
      { display: "UTC-10:00", value: -600 }
      { display: "UTC-9:00", value: -540 }
      { display: "UTC-8:00", value: -480 }
      { display: "UTC-7:00", value: -420 }
      { display: "UTC-6:00", value: -360 }
      { display: "UTC-5:00", value: -300 }
      { display: "UTC-4:00", value: -240 }
      { display: "UTC-3:00", value: -180 }
      { display: "UTC-2:00", value: -120 }
      { display: "UTC-1:00", value: -60 }
      { display: "UTC", value: 0 }
      { display: "UTC+1:00", value: 60 }
      { display: "UTC+2:00", value: 120 }
      { display: "UTC+3:00", value: 180 }
      { display: "UTC+4:00", value: 240 }
      { display: "UTC+5:00", value: 300 }
      { display: "UTC+6:00", value: 360 }
      { display: "UTC+7:00", value: 420 }
      { display: "UTC+8:00", value: 480 }
      { display: "UTC+9:00", value: 540 }
      { display: "UTC+10:00", value: 600 }
      { display: "UTC+11:00", value: 660 }
      { display: "UTC+12:00", value: 720 }
    ]

    @datepickerOptions = {
      prevText: ''
      nextText: ''
    }

    @padNumber = (value) ->
      if value < 10
        return "0#{value}"
      else
        return value

    @sourceDateTime = ko.asObservable options.dateTime

    if not @sourceDateTime()._isAMomentObject
      throw 'The date-time-picker expects the dateTime value to be a momentjs object.'

    @dateValue = ko.observable @sourceDateTime().format("MM/DD/YYYY")
    @zoneValue = ko.observable @sourceDateTime().utcOffset()
    @hourValue = ko.observable @sourceDateTime().hour()
    @minuteValue = ko.observable @sourceDateTime().minute()

    @zoneValue.subscribe (newValue) =>
      @sourceDateTime().utcOffset newValue, true
      @sourceDateTime.notifySubscribers()
      return

    @hourValue.subscribe (newValue) =>
      @sourceDateTime().hour newValue
      @sourceDateTime.notifySubscribers()
      return

    @minuteValue.subscribe (newValue) =>
      @sourceDateTime().minute newValue
      @sourceDateTime.notifySubscribers()
      return

    @dateValue.subscribe (newValue) =>
      # we want to keep the first moment so we need to
      # set the day, month, year instead of create a new moment
      newMoment = moment newValue, 'MM/DD/YYYY'
      newMoment.utcOffset @zoneValue()
      # All our code is Daylight Savings Time agnostic so
      # make sure we set the UTC Offset back to what the user selected
      @sourceDateTime().utcOffset @zoneValue(), true
      @sourceDateTime().date newMoment.date()
      @sourceDateTime().month newMoment.utc().month()
      @sourceDateTime().year newMoment.year()
      @sourceDateTime.notifySubscribers()
      return

    @sourceDateTime.subscribe (newDateTime) =>
      # this is needed to negate the extra calls created but the
      # subscribes above.
      if (newDateTime)
        @zoneValue newDateTime.utcOffset()
        @minuteValue newDateTime.minute()
        @hourValue newDateTime.hour()
        @dateValue newDateTime.format('MM/DD/YYYY')
      return

    @localTimePreview = ko.computed () =>
      clone = @sourceDateTime().clone()
      currentOffset = moment().utcOffset()
      return clone.utcOffset(currentOffset).format('ddd, MMM D, YYYY hh:mm A ([UTC]Z)')
