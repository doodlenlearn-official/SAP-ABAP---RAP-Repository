CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_Booksuppl FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Booksuppl.
    METHODS calcTotalPriceBook FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calcTotalPriceBook.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Booksuppl.

    data max_booking_suppl_id TYPE /dmo/booking_supplement_id.

 read ENTITIES of zam_r_travel IN local mode
 entity booking by \_BookSuppl
 from corresponding #(  entities )
 link data(lt_booking_suppl).

 LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>) GROUP BY <booking_group>-%tky-BookingId.


 LOOP AT lt_booking_suppl into data(ls_book_suppl) USING key entity
                                            where source-TravelId = <booking_group>-TravelId and
                                            source-BookingId = <booking_group>-BookingId.

* if max_booking_suppl_id < ls_book_suppl-target-BookingSupplementId.
*  max_booking_suppl_id = ls_book_suppl-target-BookingSupplementId.
* endif.

 if max_booking_suppl_id < ls_book_suppl-target-BookingId.
  max_booking_suppl_id = ls_book_suppl-target-BookingId.
 endif.

 endloop.

 loop at entities into DATA(ls_entity) USING KEY entity
                                       WHERE TravelId = <booking_group>-TravelId and
                                             BookingId = <booking_group>-BookingId.
LOOP AT ls_entity-%target into data(ls_target).
  if max_booking_suppl_id < ls_target-BookingSupplementId.
  max_booking_suppl_id = ls_target-BookingSupplementId.
 endif.
ENDLOOP.
 endloop.


LOOP at entities  ASSIGNING FIELD-SYMBOL(<booking>)
                                           WHERE travelid = <booking_group>-TravelId AND
                                                 bookingid = <booking_group>-BookingId.

        ""Step 5: Increment the Booking id +10 and assign the new id
        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_number>).
          APPEND CORRESPONDING #( <booksuppl_wo_number> ) TO mapped-booksuppl
                               ASSIGNING FIELD-SYMBOL(<mapped_book_suppl>).
          ""Determine the Already created Booking Id which is maximum
          ""Assining the +10 as new booking id
          IF <mapped_book_suppl>-BookingSupplementId IS INITIAL.
            max_booking_suppl_id += 1.
            <mapped_book_suppl>-BookingSupplementId = max_booking_suppl_id.
          ENDIF.

endloop.

endloop.

ENDLOOP.


  ENDMETHOD.

  METHOD calcTotalPriceBook.


  MODIFY ENTITIES OF ZAM_R_Travel IN LOCAL MODE
  ENTITY Travel
  EXECUTE reCalcTotalPrice
  FROM CORRESPONDING #( keys ).

  ENDMETHOD.

ENDCLASS.
