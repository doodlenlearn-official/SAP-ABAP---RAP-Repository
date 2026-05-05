@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analytic'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #CONSUMPTION
@Analytics.query:true
define view entity ZAMC_SLS_ANA as select from ZAMCO_SLS_CUBE
{
    key ProductName,
    @Consumption.filter.selectionType: #SINGLE
    key ProductCategory,
    @AnalyticsDetails.query.axis: #ROWS 
    key CompanyName,
    Product,
    ConvertCurrency,
    ConvertedAmount,
    Buyer
    
}
