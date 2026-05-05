@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child of Bookinf - Supplement'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define view entity ZAM_C_BOOKSUPPL as select from /dmo/booksuppl_m
    association to parent ZAM_C_BOOKING as _BOOKING on $projection.TravelId = _BOOKING.TravelId
                                                   and $projection.BookingId = _BOOKING.BookingId
    association of one to one ZAM_R_Travel          as _Travel      on  $projection.TravelId = _Travel.TravelId
    association of one to one /DMO/I_Supplement        as _Supplement       on  $projection.SupplementId = _Supplement.SupplementID
    association of one to many /DMO/I_SupplementText           as _SupplementText       on  $projection.SupplementId = _SupplementText.SupplementID
{
    key /dmo/booksuppl_m.travel_id as TravelId,
    key /dmo/booksuppl_m.booking_id as BookingId,
    key /dmo/booksuppl_m.booking_supplement_id as BookingSupplementId,
    /dmo/booksuppl_m.supplement_id as SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    /dmo/booksuppl_m.price as Price,
    /dmo/booksuppl_m.currency_code as CurrencyCode,
    @Semantics.systemDateTime.createdAt: true
    /dmo/booksuppl_m.last_changed_at as LastChangedAt,
//    _association_name // Make association public
    _BOOKING,
    _Travel,
    _Supplement ,
    _SupplementText 
}
