CLASS lhc_BookSuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calcTotalPriceBook FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookSuppl~calcTotalPriceBook.

ENDCLASS.

CLASS lhc_BookSuppl IMPLEMENTATION.

  METHOD calcTotalPriceBook.

    MODIFY ENTITIES OF ZAM_R_Travel IN LOCAL MODE
  ENTITY Travel
  EXECUTE reCalcTotalPrice
  FROM CORRESPONDING #( keys ).

  ENDMETHOD.

ENDCLASS.
