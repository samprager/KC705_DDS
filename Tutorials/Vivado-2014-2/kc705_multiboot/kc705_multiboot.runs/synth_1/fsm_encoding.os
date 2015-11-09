
 add_fsm_encoding \
       {wr_chnl.GEN_WDATA_SM_NO_ECC_DUAL_REG_WREADY.wr_data_sm_cs} \
       { }  \
       {{000 000010} {001 000100} {010 001000} {011 010000} {100 100000} }

 add_fsm_encoding \
       {rd_chnl.rlast_sm_cs} \
       { }  \
       {{000 000010} {001 100000} {010 001000} {011 000100} {100 010000} }

 add_fsm_encoding \
       {icap_statemachine.icap_nstate_cs} \
       { }  \
       {{0000 000000000000010} {0001 000000000001000} {0010 000000010000000} {0011 000000000100000} {0100 000010000000000} {0101 000000001000000} {0110 000000000010000} {0111 000000000000100} {1000 000100000000000} {1001 000001000000000} {1010 001000000000000} {1011 010000000000000} {1100 100000000000000} {1101 000000100000000} }

 add_fsm_encoding \
       {rx16550.receive_state} \
       { }  \
       {{0000 000000000000010} {0001 000000000000100} {0010 000000000001000} {0011 000000000010000} {0100 000000000100000} {0101 000000001000000} {0110 000000010000000} {0111 000000100000000} {1000 001000000000000} {1001 010000000000000} {1010 000001000000000} {1011 000100000000000} {1100 100000000000000} {1101 000010000000000} }

 add_fsm_encoding \
       {tx16550.transmit_state} \
       { }  \
       {{0000 00000000000010} {0001 00000000000100} {0010 00000000001000} {0011 00000000010000} {0100 00000000100000} {0101 00000001000000} {0110 00000010000000} {0111 00000100000000} {1000 00100000000000} {1001 01000000000000} {1010 00001000000000} {1011 00010000000000} {1100 10000000000000} }