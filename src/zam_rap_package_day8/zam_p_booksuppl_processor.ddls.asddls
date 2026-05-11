@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for booking supplement entity'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #CONSUMPTION
define view entity ZAM_P_BookSuppl_processor as projection on ZAM_C_Booksuppl
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking: redirected to parent ZAM_P_Booking_processor ,
    _Supplement,
    _SupplementText,
    _Travel: redirected to ZAM_P_Travel_processor
}
