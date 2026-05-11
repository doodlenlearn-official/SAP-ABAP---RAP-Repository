@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CHild og Travel - Booking'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define view entity ZAM_C_Booking
  as select from /dmo/booking_m
  composition of many ZAM_C_Booksuppl                as _Booksuppl
  association        to parent ZAM_R_Travel                 as _Travel on  $projection.TravelId = _Travel.TravelId
  association of one to one /DMO/I_Customer          as _Customer      on  $projection.CustomerId = _Customer.CustomerID
  association of one to one /DMO/I_Carrier           as _Carrier       on  $projection.CarrierId = _Carrier.AirlineID
  association of one to one /DMO/I_Connection        as _Connection    on  $projection.CarrierId    = _Connection.AirlineID
                                                                       and $projection.ConnectionId = _Connection.ConnectionID
  association of one to one /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.BookingStatus = _BookingStatus.BookingStatus
  association of one to one I_Currency               as _Currency      on $projection.CurrencyCode = _Currency.Currency
{

  key /dmo/booking_m.travel_id       as TravelId,
  key /dmo/booking_m.booking_id      as BookingId,
      /dmo/booking_m.booking_date    as BookingDate,
      @Consumption.valueHelpDefinition: [{
                            entity: {
                            name: '/DMO/I_Customer',
                            element: 'CustomerID'
                            }
       }]
      /dmo/booking_m.customer_id     as CustomerId,
      @Consumption.valueHelpDefinition: [{
                            entity: {
                            name: '/DMO/I_Carrier',
                            element: 'AirlineID'
                            }
       }]
      /dmo/booking_m.carrier_id      as CarrierId,
      @Consumption.valueHelpDefinition: [{
                            entity: {
                            name: '/DMO/I_Connection',
                            element: 'ConnectionID'
                            },
                            additionalBinding: [{
                            localElement: 'CarrierId',
                            element: 'AirlineID'
                             }]
       }]
      /dmo/booking_m.connection_id   as ConnectionId,
      /dmo/booking_m.flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      /dmo/booking_m.flight_price    as FlightPrice,
      @Consumption.valueHelpDefinition: [{
                            entity: {
                            name: 'I_Currency',
                            element: 'Currency'
                            }
       }]
      /dmo/booking_m.currency_code   as CurrencyCode,
      @Consumption.valueHelpDefinition: [{
                            entity: {
                            name: '/DMO/I_Booking_Status_VH',
                            element: 'BookingStatus'
                            }
       }]
      /dmo/booking_m.booking_status  as BookingStatus,
      @Semantics.systemDateTime.lastChangedAt: true
      /dmo/booking_m.last_changed_at as LastChangedAt,

      //    _association_name // Make association public
      _Travel,
      _Booksuppl,
      _Customer,
      _Carrier,
      _Connection,
      _BookingStatus
}
