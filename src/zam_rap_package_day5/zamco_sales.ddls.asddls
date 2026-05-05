@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales and prod'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #COMPOSITE  
define view entity ZAMCO_SALES 
with parameters I_CURR : abap.cuky(5)
as select from ZAMI_SALES as sales
association of many to many ZAMI_product as _Product
on $projection.Product = _Product.ProductId
{
    key sales.OrderId,
    key sales.ItemId,
    sales.OrderNo,
    sales.Product,
    sales.Amount,
    sales.Currency,
    cast('USD' as abap.cuky) as ConvertCurrency,
    @Semantics.amount.currencyCode: 'ConvertCurrency'
    currency_conversion( amount => Amount, 
                        source_currency => Currency, 
                        target_currency => $parameters.I_CURR, 
                        exchange_rate_date => $session.system_date ) as ConvertedAmount,
    sales.Qty,
    sales.Uom,
    sales.Buyer,
    _Product.Name as ProductName,
    _Product.Category as ProductCategory
}
