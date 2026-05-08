@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for travel root entity'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity ZAM_P_Travel_processor
  as projection on ZAM_R_Travel
{
  key TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      AgencyName,
      CustomerName,
      StatusText,
      Minion,
      /* Associations */
      _Agency,
      _BOOKING : redirected to composition child ZAM_P_Booking_processor,
      _Currency,
      _Customer,
      _Overallstatus
}
