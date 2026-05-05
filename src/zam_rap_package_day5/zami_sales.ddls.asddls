@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'sales order and item'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@Analytics.dataCategory: #FACT
define view entity ZAMI_SALES as select from zam_so_hdr as head
association of one to many zam_so_item as _Items 
on $projection.OrderId = _Items.order_id
{
    key head.order_id as OrderId,
    key _Items.item_id as ItemId,
    head.order_no as OrderNo,
    _Items.product as Product,
    @Semantics.amount.currencyCode: 'Currency'
    _Items.amount as Amount,
    _Items.currency as Currency,
    @Semantics.quantity.unitOfMeasure: 'Uom'
    _Items.qty as Qty,
    _Items.uom as Uom,
    head.buyer as Buyer
}
