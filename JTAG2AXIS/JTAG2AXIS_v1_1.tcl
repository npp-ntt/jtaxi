# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S_AXIS_TDATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEPTH_FIFO_IN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEPTH_FIFO_OUT" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_S_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DEPTH_FIFO_IN { PARAM_VALUE.DEPTH_FIFO_IN } {
	# Procedure called to update DEPTH_FIFO_IN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEPTH_FIFO_IN { PARAM_VALUE.DEPTH_FIFO_IN } {
	# Procedure called to validate DEPTH_FIFO_IN
	return true
}

proc update_PARAM_VALUE.DEPTH_FIFO_OUT { PARAM_VALUE.DEPTH_FIFO_OUT } {
	# Procedure called to update DEPTH_FIFO_OUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEPTH_FIFO_OUT { PARAM_VALUE.DEPTH_FIFO_OUT } {
	# Procedure called to validate DEPTH_FIFO_OUT
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DEPTH_FIFO_IN { MODELPARAM_VALUE.DEPTH_FIFO_IN PARAM_VALUE.DEPTH_FIFO_IN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEPTH_FIFO_IN}] ${MODELPARAM_VALUE.DEPTH_FIFO_IN}
}

proc update_MODELPARAM_VALUE.DEPTH_FIFO_OUT { MODELPARAM_VALUE.DEPTH_FIFO_OUT PARAM_VALUE.DEPTH_FIFO_OUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEPTH_FIFO_OUT}] ${MODELPARAM_VALUE.DEPTH_FIFO_OUT}
}

