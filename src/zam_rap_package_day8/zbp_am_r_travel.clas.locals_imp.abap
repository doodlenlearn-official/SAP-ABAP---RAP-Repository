CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

METHOD earlynumbering_create.

  DATA: entity        TYPE STRUCTURE FOR CREATE zam_r_travel,
        travel_id_max TYPE /dmo/travel_id.

  "Step 1: travel id must not be passed by the user
  LOOP AT entities INTO entity WHERE travelid IS NOT INITIAL.
    APPEND CORRESPONDING #( entity ) TO mapped-travel.
  ENDLOOP.

  "Step 2: keep only the records where travel id is blank
  DATA(entities_wo_travelid) = entities.
  DELETE entities_wo_travelid WHERE travelid IS NOT INITIAL.

  "Step 3: SNRO generator
  TRY.
      cl_numberrange_runtime=>number_get(
        EXPORTING nr_range_nr       = '01'
                  object            = CONV #( '/DMO/TRAVL' )
                  quantity          = CONV #( lines( entities_wo_travelid ) )
        IMPORTING number            = DATA(number_range_key)
                  returncode        = DATA(number_range_return_code)
                  returned_quantity = DATA(number_range_returned_quantity) ).
    CATCH cx_number_ranges INTO DATA(lx_number_ranges).
      "Step 4
      LOOP AT entities_wo_travelid INTO entity.
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges ) TO reported-travel.
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO failed-travel.
      ENDLOOP.
  ENDTRY.

  "Step 5
  CASE number_range_return_code.
    WHEN '1'.
      LOOP AT entities_wo_travelid INTO entity.
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                        %msg = NEW /dmo/cm_flight_messages(
                                 textid   = /dmo/cm_flight_messages=>number_range_depleted
                                 severity = if_abap_behv_message=>severity-warning ) ) TO reported-travel.
      ENDLOOP.
    WHEN '2' OR '3'.
      APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                      %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                                          severity = if_abap_behv_message=>severity-warning ) ) TO reported-travel.
      APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                      %fail-cause = if_abap_behv=>cause-conflict ) TO failed-travel.
  ENDCASE.

  "Step 6
  ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).

  "Step 7
  travel_id_max = number_range_key - number_range_returned_quantity.
  LOOP AT entities_wo_travelid INTO entity.
    travel_id_max += 1.
    entity-TravelId = travel_id_max.
    APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO mapped-travel.
  ENDLOOP.

ENDMETHOD.

ENDCLASS.
