@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Draft query view for ZAM_RAP_DTRAV'
define root view entity zam_rap_travq
  as select from zam_rap_dtrav
{
  key travelid as TravelId,
  agencyid as AgencyId,
  agencyname as AgencyName,
  customerid as CustomerId,
  customername as CustomerName,
  begindate as BeginDate,
  enddate as EndDate,
  bookingfee as BookingFee,
  totalprice as TotalPrice,
  currencycode as CurrencyCode,
  description as Description,
  overallstatus as OverallStatus,
  minion as Minion,
  statustext as StatusText,
  createdby as CreatedBy,
  createdat as CreatedAt,
  lastchangedat as LastChangedAt,
  lastchangedby as LastChangedBy,
  draftentitycreationdatetime as draftentitycreationdatetime,
  draftentitylastchangedatetime as draftentitylastchangedatetime,
  draftadministrativedatauuid as draftadministrativedatauuid,
  draftentityoperationcode as draftentityoperationcode,
  hasactiveentity as hasactiveentity,
  draftfieldchanges as draftfieldchanges
}
