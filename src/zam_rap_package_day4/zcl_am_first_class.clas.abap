CLASS zcl_am_first_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_am_first_class IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  SELECT * from i_country into table @data(lt_country).

  out->write(
    EXPORTING
      data   = lt_country
*      name   =
*    RECEIVING
*      output =
  ).


  ENDMETHOD.
ENDCLASS.
