@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales ++prd +bpa'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #COMPOSITE
@Analytics.dataCategory: #CUBE
define view entity ZAMCO_SLS_CUBE as select from ZAMCO_SALES( I_CURR: 'USD' ) as sales
association of many to many ZAMI_BPA as _BusinessPartner
on $projection.Buyer = _BusinessPartner.BusinessPartnerId
{
    key sales.OrderId,
    key sales.ItemId,
    sales.Product,
    sales.ConvertCurrency,
    @Aggregation.default: #SUM
    sales.ConvertedAmount,
    sales.Buyer,
    sales.ProductName,
    sales.ProductCategory,
    _BusinessPartner.CompanyName
}
