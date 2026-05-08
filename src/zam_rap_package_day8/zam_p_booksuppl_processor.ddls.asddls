@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for booking supplement entity'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #CONSUMPTION
define view entity ZAM_P_BookSuppl_processor as projection on ZAM_C_BOOKSUPPL
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _BOOKING: redirected to parent zam_p_booking_processor ,
    _Supplement,
    _SupplementText,
    _Travel: redirected to zam_p_travel_processor
}
