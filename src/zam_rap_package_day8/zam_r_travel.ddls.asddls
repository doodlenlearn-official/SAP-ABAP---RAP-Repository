@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view entity for travel processor'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define root view entity ZAM_R_Travel
  as select from /dmo/travel_m
  composition of many ZAM_C_Booking                  as _Booking
  association of one to one /DMO/I_Agency            as _Agency        on $projection.AgencyId = _Agency.AgencyID
  association of one to one /DMO/I_Customer          as _Customer      on $projection.CustomerId = _Customer.CustomerID
  association of one to one I_Currency               as _Currency      on $projection.CurrencyCode = _Currency.Currency
  association of one to one /DMO/I_Overall_Status_VH as _Overallstatus on $projection.OverallStatus = _Overallstatus.OverallStatus
{
      @ObjectModel.text.element: [ 'Description'  ]
  key /dmo/travel_m.travel_id                                           as TravelId,
  @Consumption.valueHelpDefinition: [{
                entity: {
                        name: '/DMO/I_Agency',
                        element: 'AgencyID'
                }
  }]   
      /dmo/travel_m.agency_id                                           as AgencyId,
      @ObjectModel.text.element: [ 'Agencyname']
      _Agency.Name                                                      as AgencyName,
      @Consumption.valueHelpDefinition: [{ 
                            entity:{
                                name: '/DMO/I_Customer',
                                element: 'CustomerID'
                            }
       }]
      /dmo/travel_m.customer_id                                         as CustomerId,
      @ObjectModel.text.element: [ 'Customername']
      concat( concat( _Customer.FirstName, ' ' ) , _Customer.LastName ) as CustomerName,
      /dmo/travel_m.begin_date                                          as BeginDate,
      /dmo/travel_m.end_date                                            as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      /dmo/travel_m.booking_fee                                         as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      /dmo/travel_m.total_price                                         as TotalPrice,
            @Consumption.valueHelpDefinition: [{ 
                            entity: {
                            name: 'I_Currency',
                            element: 'Currency'
                            }
       }]
      /dmo/travel_m.currency_code                                       as CurrencyCode,
      /dmo/travel_m.description                                         as Description,
      @ObjectModel.text.element: [ 'StatusText' ]
      @EndUserText.label: 'Spiderman'
      @Consumption.valueHelpDefinition: [{ 
                            entity: {
                            name: '/DMO/I_Overall_Status_VH',
                            element: 'OverallStatus'
                            }
       }]
      /dmo/travel_m.overall_status                                      as OverallStatus,
      case /dmo/travel_m.overall_status
      when 'O' then 2
      when 'A' then 3
      when 'X' then 1
      else 1
      end                                                               as Minion,
      _Overallstatus._Text[ Language = $session.system_language ].Text  as StatusText,
      @Semantics.user.createdBy: true
      /dmo/travel_m.created_by                                          as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      /dmo/travel_m.created_at                                          as CreatedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      /dmo/travel_m.last_changed_at                                     as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      /dmo/travel_m.last_changed_by                                     as LastChangedBy,

      //    _association_name // Make association public
      _Booking,
      _Agency,
      _Customer,
      _Currency,
      _Overallstatus

}
