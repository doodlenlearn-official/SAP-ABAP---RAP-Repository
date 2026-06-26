CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD augment_create.


  data travel_create TYPE TABLE FOR CREATE zam_r_travel.

  travel_create = CORRESPONDING #( entities ).

  LOOP AT travel_create ASSIGNING FIELD-SYMBOL(<fs_create>).


  <fs_create>-AgencyId = '70004'.
  <fs_create>-OverallStatus = 'O'.
  <fs_create>-%control-AgencyId = if_abap_behv=>mk-on.
  <fs_create>-%control-OverallStatus = if_abap_behv=>mk-on.



  endloop.

  modify augmenting ENTITIES OF zam_r_travel
  ENTITY travel
  CREATE FROM travel_create.


  ENDMETHOD.

ENDCLASS.
