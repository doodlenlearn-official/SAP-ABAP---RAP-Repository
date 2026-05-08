@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for booking entity'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #CONSUMPTION
define view entity ZAM_P_Booking_processor as projection on ZAM_C_BOOKING
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _BookingStatus,
    _BOOKSUPPL : redirected to composition child zam_p_booksuppl_processor ,
    _Carrier,
    _Connection,
    _Customer,
    _Travel: redirected to parent ZAM_P_Travel_processor
}
