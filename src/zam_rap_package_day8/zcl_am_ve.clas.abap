CLASS zcl_am_ve DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_am_ve IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.


    check not it_original_data is INITIAL.

    DATA: lt_calc_data TYPE STANDARD TABLE OF ZAM_P_Travel_processor with default key,
          lv_rate type p decimals 2 VALUE '0.025'.

          lt_calc_data = CORRESPONDING #( it_original_data ).

          LOOP AT lt_calc_data ASSIGNING FIELD-SYMBOL(<fs_calc_data>).

          <fs_calc_data>-CO2Tax = <fs_calc_data>-TotalPrice * lv_rate.
          <fs_calc_data>-dayOfFlight = 'Sunday'.

          Endloop.

          ct_calculated_data = CORRESPONDING #( lt_calc_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.


  ENDMETHOD.
ENDCLASS.
