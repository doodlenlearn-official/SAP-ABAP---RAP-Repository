@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for travel root entity'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity ZAM_P_TRAVEL_APPROVER
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
      _Booking : redirected to composition child ZAM_P_Booking_approver,
      _Currency,
      _Customer,
      _Overallstatus
}
