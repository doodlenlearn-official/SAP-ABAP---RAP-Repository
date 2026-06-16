CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.
    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE Travel\_Booking.
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

  METHOD earlynumbering_cba_Booking.

  data max_booking_id TYPE /dmo/booking_id.

 read ENTITIES of zam_r_travel IN local mode
 entity travel by \_Booking
 from corresponding #(  entities )
 link data(lt_bookings).

 LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelId.


 LOOP AT lt_bookings into data(ls_bookings) USING key entity
                                            where source-TravelId = <travel_group>-TravelId.

 if max_booking_id < ls_bookings-target-BookingId.
  max_booking_id = ls_bookings-target-BookingId.
 endif.

 endloop.
endloop.

LOOP at entities  ASSIGNING FIELD-SYMBOL(<travel>) GROUP by <travel>-TravelId.

LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<travel_wo_number>).

APPEND corresponding #( <travel_wo_number> ) to mapped-booking
                        ASSIGNING FIELD-SYMBOL(<mapped_booking>).

if <mapped_booking>-BookingId is initial.
max_booking_id += 10.
<mapped_booking>-BookingId = max_booking_id.
endif.

endloop.



ENDLOOP.


  ENDMETHOD.

  METHOD get_instance_features.



  READ entities of zam_r_travel IN local mode
        entity travel
        fields ( travelid overallstatus )
        with CORRESPONDING #( keys )
        result data(lt_travel)
        failed data(lt_failed).

        READ table lt_travel into data(ls_travel) index 1.
        if ( ls_travel-OverallStatus = 'X' ).
            data(lv_allow) = if_abap_behv=>fc-o-disabled.
        else.
                lv_allow = if_abap_behv=>fc-o-enabled.
        endif.


        result = value #( for ls_travel1 in lt_travel ( %tky = ls_travel1-%tky
                                                        %assoc-_Booking = lv_allow )  ).

  ENDMETHOD.

  METHOD copyTravel.



  data: travels TYPE TABLE for CREATE zam_r_travel\\Travel,
  booking_cba TYPE TABLE for CREATE zam_r_travel\\Travel\_Booking,
   booksuppl_cba TYPE TABLE for CREATE zam_r_travel\\Booking\_Booksuppl.

   read table keys with key %cid = '' into data(key_with_initial_cid).
   assert key_with_initial_cid is INITIAL.


   READ ENTITIES OF zam_r_travel in LOCAL MODE
   ENTITY travel
   ALL FIELDS WITH CORRESPONDING #( keys )
   result data(travel_read_result)
   failed failed.


   READ ENTITIES OF zam_r_travel in LOCAL MODE
   ENTITY travel by \_Booking
   ALL FIELDS WITH CORRESPONDING #( travel_read_result )
   result data(book_read_result)
   failed failed.


   READ ENTITIES OF zam_r_travel in LOCAL MODE
   ENTITY Booking by \_Booksuppl
   ALL FIELDS WITH CORRESPONDING #( book_read_result )
   result data(booksuppl_read_result)
   failed failed.


LOOP AT travel_read_result ASSIGNING FIELD-SYMBOL(<travel>).


APPEND value #( %cid = keys[ %tky = <travel>-%tky ]-%cid
                %data = corresponding #( <travel> except travelid )
                ) to travels ASSIGNING FIELD-SYMBOL(<new_travel>).


<new_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
<new_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
<new_travel>-OverallStatus = 'N'.

Endloop.


  ENDMETHOD.

ENDCLASS.
