CLASS lsc_zam_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zam_r_travel IMPLEMENTATION.

  METHOD save_modified.



  DAta: lt_log_data TYPE STANDARD TABLE OF /dmo/log_travel,
 lt_final_data TYPE STANDARD TABLE OF /dmo/log_travel.

 if update-travel is not initial.

 lt_log_data = CORRESPONDING #( update-travel mapping travel_id = TravelId ).

 LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<fs_changes>).

 assign lt_log_data[ travel_id = <fs_changes>-TravelId ]
            to FIELD-SYMBOL(<travel_log_db>).

            get time stamp field <travel_log_db>-created_at.

            if <fs_changes>-%control-CustomerId = if_abap_behv=>mk-on.

            <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            <travel_log_db>-changed_field_name = 'abhijeet customer'.
            <travel_log_db>-changed_value = <fs_changes>-CustomerId.
            <travel_log_db>-changing_operation = 'update'.

            APPEND <travel_log_db> to lt_final_data.


            endif.

              if <fs_changes>-%control-AgencyId = if_abap_behv=>mk-on.

            <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            <travel_log_db>-changed_field_name = 'abhijeet agency'.
            <travel_log_db>-changed_value = <fs_changes>-AgencyId.
            <travel_log_db>-changing_operation = 'update'.

            APPEND <travel_log_db> to lt_final_data.


            endif.


 endloop.

insert /dmo/log_travel from table @lt_final_data.

 endif.




  ENDMETHOD.

ENDCLASS.

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
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.
    METHODS calctotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calctotalprice.
    METHODS validateheaderdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateheaderdata.
    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE Travel\_Booking.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizations.


DATA ls_return LIKE line of result.

READ ENTITIES OF zam_r_travel
ENTITY travel
fields ( travelid overallstatus )
with CORRESPONDING #( keys )
result data(lt_travel)
failed data(lt_failed).

LOOP AT lt_travel into data(ls_travel).

data(lv_auth) = abap_false.

if ( ls_travel-OverallStatus = 'X' ).

authority-check object 'ZAM_AUTH'
    ID 'ACTVT' field '02' .

    if sy-subrc = 0.

    lv_auth = abap_true.

    endif.

else.

lv_auth = abap_true.

endif.

ls_return = value #(  travelid = ls_travel-TravelId
                      %action-Edit = cond #(
                                            when lv_auth eq abap_false
                                            then if_abap_behv=>auth-unauthorized
                                            else if_abap_behv=>auth-allowed
                       )
                       %update = cond #(
                                            when lv_auth eq abap_false
                                            then if_abap_behv=>auth-unauthorized
                                            else if_abap_behv=>auth-allowed
                       )


).

append ls_return to result.


endloop.

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
    APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                    %is_draft = entity-%is_draft ) TO mapped-travel.
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
  bookings_cba TYPE TABLE for CREATE zam_r_travel\\Travel\_Booking,
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

        APPEND value #(  %cid_ref = keys[ key entity %tky = <travel>-%tky ]-%cid
                        ) to bookings_cba assigning field-symbol(<booking_cba>).

        LOOP at book_read_result assigning FIELD-SYMBOL(<booking>) where travelid = <travel>-TravelId.

        APPEND value #( %cid = keys[ key entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                        %data = CORRESPONDING #( book_read_result[  key entity %tky = <booking>-%tky  ] except travelid ) )
                        to <booking_cba>-%target ASSIGNING FIELD-SYMBOL(<new_booking>).

                        <new_booking>-BookingStatus = 'N'.


                APPEND value #(  %cid_ref = keys[ key entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                        ) to booksuppl_cba assigning field-symbol(<booksuppl_cba>).

                LOOP at booksuppl_read_result assigning FIELD-SYMBOL(<book_suppl>) where travelid = <travel>-TravelId
                                                                                     and bookingid = <booking>-bookingid.

                APPEND value #( %cid = keys[ key entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId && <book_suppl>-BookingSupplementId
                        %data = CORRESPONDING #( booksuppl_read_result[  key entity %tky = <book_suppl>-%tky  ] except travelid BookingId ) )
                        to <booksuppl_cba>-%target .

                Endloop.

        Endloop.


        Endloop.

        modify ENTITIES OF ZAM_R_Travel IN LOCAL MODE
        ENTITY Travel
        CREATE FIELDS ( agencyid customerid begindate enddate bookingfee totalprice currencycode OverallStatus )
        WITH travels
        CREATE BY \_Booking FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice )
        with bookings_cba
        ENTITY booking
        CREATE BY \_Booksuppl FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
        with booksuppl_cba
        mapped data(mapped_data).

*        mapped-travel = mapped_data.
        mapped = mapped_data.

  ENDMETHOD.

  METHOD reCalcTotalPrice.


  TYPES: BEGIN OF ty_total_cost,
        amount type /dmo/total_price,
        currency type /dmo/currency_code,
        end of ty_total_cost.

        data amounts_per_currencycode type  STANDARD TABLE OF ty_total_cost.
        data ls_header_curr type /dmo/currency_code.

           READ ENTITIES OF zam_r_travel in LOCAL MODE
           ENTITY travel
           FIELDS ( BookingFee CurrencyCode )
           WITH CORRESPONDING #( keys )
           result data(travel)
           failed failed.


           READ ENTITIES OF zam_r_travel in LOCAL MODE
           ENTITY travel by \_Booking
           FIELDS ( FlightPrice CurrencyCode )
           WITH CORRESPONDING #( travel )
           result data(booking)
           failed failed.


           READ ENTITIES OF zam_r_travel in LOCAL MODE
           ENTITY Booking by \_Booksuppl
           FIELDS ( Price CurrencyCode )
           WITH CORRESPONDING #( booking )
           result data(booksuppl)
           failed failed.


           delete travel where currencycode is initial.
           delete booking where currencycode is initial.
           delete booksuppl where currencycode is initial.

            LOOP AT travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

            amounts_per_currencycode = value #( ( amount = <fs_travel>-BookingFee
                                                  currency = <fs_travel>-CurrencyCode ) ).
           ls_header_curr = <fs_travel>-CurrencyCode.
            LOOP AT booking into data(wa_booking).

            collect value ty_total_cost( amount = wa_booking-FlightPrice
                             currency = wa_booking-CurrencyCode )
                             into amounts_per_currencycode.

            LOOP AT booksuppl into data(wa_booksuppl).

            collect value ty_total_cost( amount = wa_booksuppl-price
                             currency = wa_booksuppl-CurrencyCode )
                             into amounts_per_currencycode.



            endloop.
            endloop.
            clear <fs_travel>-totalprice.
            endloop.



            LOOP at amounts_per_currencycode into data(ls_amount_per_currency).

            if ls_amount_per_currency-currency = ls_header_curr.

            <fs_travel>-TotalPrice += ls_amount_per_currency-amount.

            else.

            /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                iv_amount               = ls_amount_per_currency-amount
                iv_currency_code_source = ls_amount_per_currency-currency
                iv_currency_code_target = ls_header_curr
                iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
              IMPORTING
                ev_amount               = data(total_amt)
            ).

            <fs_travel>-TotalPrice += total_amt.

            endif.


            endloop.

            modify ENTITIES OF zam_r_travel IN LOCAL MODE
            entity travel
            update fields (  totalprice )
            WITH CORRESPONDING #(  travel ).


  ENDMETHOD.

  METHOD calcTotalPrice.


  MODIFY ENTITIES OF ZAM_R_Travel IN LOCAL MODE
  ENTITY Travel
  EXECUTE reCalcTotalPrice
  FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD validateHeaderData.

  data: lt_customers TYPE SORTED TABLE of /dmo/customer with unique key customer_id,
        lt_agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

   READ ENTITIES OF ZAM_R_Travel
   ENTITY travel
   FIELDS ( agencyid customerid begindate enddate )
            WITH CORRESPONDING #( keys )
            RESULT data(lt_travel).


   lt_customers = CORRESPONDING #( lt_travel Discarding duplicates mapping customer_id = customerid except * ).
   lt_agency = CORRESPONDING #( lt_travel Discarding duplicates mapping agency_id = agencyid except * ).

   delete lt_customers where customer_id is initial.
   delete lt_agency where agency_id is initial.

   if lt_customers is NOT INITIAL.

   SELECT FROM /dmo/customer fields customer_id
   FOR ALL entries in @lt_customers
   where customer_id = @lt_customers-customer_id
   into TABLE @DATA(LT_CUST_DB).

   endif.


   IF lt_AGENCY is NOT INITIAL.

   SELECT FROM /dmo/AGENCY fields AGENCY_id
   FOR ALL entries in @lt_AGENCY
   where AGENCY_id = @lt_AGENCY-AGENCY_id
   into TABLE @DATA(LT_AGENCY_DB).

   ENDIF.


LOOP AT lt_travel into data(ls_travel).


if ( ls_travel-customerid is initial OR NOT line_exists( lt_cust_db[ customer_id = ls_travel-customerid ] ) ).

APPEND VALUE #( %tky = ls_travel-%tky ) to failed-travel.
APPEND VALUE #( %tky = ls_travel-%tky
                %element-customerid = if_abap_behv=>mk-on
                %msg = new /dmo/cm_flight_messages(
                                                    textid = /dmo/cm_flight_messages=>customer_unkown
                                                    customer_id = ls_travel-CustomerId
                                                    severity = if_abap_behv_message=>severity-error
                 )
) to reported-travel.


endif.


if ( ls_travel-agencyid is initial OR NOT line_exists( lt_agency_db[ agency_id = ls_travel-agencyid ] ) ).

APPEND VALUE #( %tky = ls_travel-%tky ) to failed-travel.
APPEND VALUE #( %tky = ls_travel-%tky
                %element-agencyid = if_abap_behv=>mk-on
                %msg = new /dmo/cm_flight_messages(
                                                    textid = /dmo/cm_flight_messages=>agency_unkown
                                                    agency_id = ls_travel-agencyId
                                                    severity = if_abap_behv_message=>severity-error
                 )
) to reported-travel.


endif.


ENDLOOP.




  ENDMETHOD.

ENDCLASS.
