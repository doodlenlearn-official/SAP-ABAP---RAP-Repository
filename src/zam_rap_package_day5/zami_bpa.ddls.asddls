@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BPA'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
@Analytics.dataCategory: #DIMENSION
define view entity ZAMI_BPA as select from zam_bpa
{
    key bp_id as BusinessPartnerId,
    bp_role as BpRole,
    company_name as CompanyName,
    street as Street,
    country as Country
}
