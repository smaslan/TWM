<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="13008000">
	<Property Name="CCSymbols" Type="Str">w_niscope,1;w_visa,1;w_daqmx,1;</Property>
	<Property Name="NI.LV.All.SourceOnly" Type="Bool">false</Property>
	<Property Name="NI.Project.Description" Type="Str"></Property>
	<Item Name="My Computer" Type="My Computer">
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="ADC" Type="Folder">
			<Item Name="Utilities" Type="Folder">
				<Item Name="ADC Deactivate Digitizer.vi" Type="VI" URL="../adc/Utilities/ADC Deactivate Digitizer.vi"/>
				<Item Name="ADC GUI Get Info.vi" Type="VI" URL="../adc/Utilities/ADC GUI Get Info.vi"/>
				<Item Name="ADC Get Current Setup.vi" Type="VI" URL="../adc/Utilities/ADC Get Current Setup.vi"/>
				<Item Name="ADC Selfcal Virtual Channels.vi" Type="VI" URL="../adc/Utilities/ADC Selfcal Virtual Channels.vi"/>
				<Item Name="ADC Get Capabilities.vi" Type="VI" URL="../adc/Utilities/ADC Get Capabilities.vi"/>
				<Item Name="ADC Reset Idle Timer.vi" Type="VI" URL="../adc/ADC Reset Idle Timer.vi"/>
				<Item Name="ADC Update and Check Idle Timer.vi" Type="VI" URL="../adc/ADC Update and Check Idle Timer.vi"/>
				<Item Name="ADC GUI Disable types.vi" Type="VI" URL="../adc/Utilities/ADC GUI Disable types.vi"/>
				<Item Name="ADC Get Valid Defaults.vi" Type="VI" URL="../adc/Utilities/ADC Get Valid Defaults.vi"/>
				<Item Name="ADC Check Overload.vi" Type="VI" URL="../adc/Utilities/ADC Check Overload.vi"/>
				<Item Name="ADC Get Status.vi" Type="VI" URL="../adc/Utilities/ADC Get Status.vi"/>
			</Item>
			<Item Name="Multiplexer" Type="Folder">
				<Item Name="MPX Type.ctl" Type="VI" URL="../adc/Multiplexer/MPX Type.ctl"/>
				<Item Name="MPX Session.ctl" Type="VI" URL="../adc/Multiplexer/MPX Session.ctl"/>
				<Item Name="MPX Record Segment Info.ctl" Type="VI" URL="../adc/Multiplexer/MPX Record Segment Info.ctl"/>
				<Item Name="MPX Sequence Item.ctl" Type="VI" URL="../adc/Multiplexer/MPX Sequence Item.ctl"/>
				<Item Name="MPX Post Process Sequence.vi" Type="VI" URL="../adc/Multiplexer/MPX Post Process Sequence.vi"/>
				<Item Name="MPX Panel.vi" Type="VI" URL="../adc/Multiplexer/MPX Panel.vi"/>
				<Item Name="MPX Check Sequence.vi" Type="VI" URL="../adc/Multiplexer/MPX Check Sequence.vi"/>
				<Item Name="MPX Fill Sequence Selectors.vi" Type="VI" URL="../adc/Multiplexer/MPX Fill Sequence Selectors.vi"/>
				<Item Name="MPX Open.vi" Type="VI" URL="../adc/Multiplexer/MPX Open.vi"/>
				<Item Name="MPX Get Path Names.vi" Type="VI" URL="../adc/Multiplexer/MPX Get Path Names.vi"/>
				<Item Name="MPX Set Path.vi" Type="VI" URL="../adc/Multiplexer/MPX Set Path.vi"/>
				<Item Name="MPX Close.vi" Type="VI" URL="../adc/Multiplexer/MPX Close.vi"/>
			</Item>
			<Item Name="ADC Session.ctl" Type="VI" URL="../adc/ADC Session.ctl"/>
			<Item Name="ADC Type.ctl" Type="VI" URL="../adc/ADC Type.ctl"/>
			<Item Name="ADC Trig Mode Source.ctl" Type="VI" URL="../adc/ADC Trig Mode Source.ctl"/>
			<Item Name="ADC Trig Slope.ctl" Type="VI" URL="../adc/ADC Trig Slope.ctl"/>
			<Item Name="ADC Trig Coupling.ctl" Type="VI" URL="../adc/ADC Trig Coupling.ctl"/>
			<Item Name="ADC Trig Config.ctl" Type="VI" URL="../adc/ADC Trig Config.ctl"/>
			<Item Name="ADC Data Packet.ctl" Type="VI" URL="../adc/ADC Data Packet.ctl"/>
			<Item Name="ADC Aux Data.ctl" Type="VI" URL="../adc/ADC Aux Data.ctl"/>
			<Item Name="ADC Capabilities.ctl" Type="VI" URL="../adc/ADC Capabilities.ctl"/>
			<Item Name="ADC Capabilities Parameters.ctl" Type="VI" URL="../adc/ADC Capabilities Parameters.ctl"/>
			<Item Name="ADC Attribute.ctl" Type="VI" URL="../adc/ADC Attribute.ctl"/>
			<Item Name="ADC Current Configuration.ctl" Type="VI" URL="../adc/ADC Current Configuration.ctl"/>
			<Item Name="ADC Sampling Rate Step Mode.ctl" Type="VI" URL="../adc/ADC Sampling Rate Step Mode.ctl"/>
			<Item Name="ADC On Close Action.ctl" Type="VI" URL="../adc/ADC On Close Action.ctl"/>
			<Item Name="ADC Initialize Drivers.vi" Type="VI" URL="../adc/ADC Initialize Drivers.vi"/>
			<Item Name="ADC Enumerate Devices.vi" Type="VI" URL="../adc/ADC Enumerate Devices.vi"/>
			<Item Name="ADC Config Panel.vi" Type="VI" URL="../adc/ADC Config Panel.vi"/>
			<Item Name="ADC Initialize Virtual Channels.vi" Type="VI" URL="../adc/ADC Initialize Virtual Channels.vi"/>
			<Item Name="ADC Close Virtual Channels.vi" Type="VI" URL="../adc/ADC Close Virtual Channels.vi"/>
			<Item Name="ADC Setup Virtual Channels.vi" Type="VI" URL="../adc/ADC Setup Virtual Channels.vi"/>
			<Item Name="ADC Initiate Digitizing Process.vi" Type="VI" URL="../adc/ADC Initiate Digitizing Process.vi"/>
			<Item Name="ADC Fetch From Digitizing Process.vi" Type="VI" URL="../adc/ADC Fetch From Digitizing Process.vi"/>
			<Item Name="ADC Cleanup Digitizing Process.vi" Type="VI" URL="../adc/ADC Cleanup Digitizing Process.vi"/>
			<Item Name="ADC Abort Digitizing Process.vi" Type="VI" URL="../adc/ADC Abort Digitizing Process.vi"/>
		</Item>
		<Item Name="drivers" Type="Folder">
			<Item Name="dsdll" Type="Folder">
				<Item Name="dsdll.lvlibp" Type="LVLibp" URL="../drivers/dsdll/dsdll.lvlibp">
					<Item Name="private" Type="Folder">
						<Item Name="dsdll_get_exe_path.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_get_exe_path.vi"/>
						<Item Name="dsdll_check_instance.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_check_instance.vi"/>
						<Item Name="dsdll_generate_error.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_generate_error.vi"/>
						<Item Name="dsdll_enumerate_devices_querry_list.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_enumerate_devices_querry_list.vi"/>
						<Item Name="dsdll_output_write_byte_array.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_write_byte_array.vi"/>
						<Item Name="dsdll_output_write_int16.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_write_int16.vi"/>
						<Item Name="dsdll_output_write_float32.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_write_float32.vi"/>
						<Item Name="dsdll_output_write_auto_float32.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_write_auto_float32.vi"/>
						<Item Name="dsdll_capture_wave_byte_array.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave_byte_array.vi"/>
						<Item Name="dsdll_capture_wave_variant.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave_variant.vi"/>
						<Item Name="dsdll_capture_wave_int16.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave_int16.vi"/>
						<Item Name="dsdll_capture_wave_float32.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave_float32.vi"/>
						<Item Name="dsdll_capture_wave_auto_float32.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave_auto_float32.vi"/>
					</Item>
					<Item Name="capture" Type="Folder">
						<Item Name="dsdll_capture_get_size.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_get_size.vi"/>
						<Item Name="dsdll_capture_wave.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave.vi"/>
						<Item Name="dsdll_capture_wave_abort.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave_abort.vi"/>
						<Item Name="dsdll_capture_wave_get_status.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/capture/dsdll_capture_wave_get_status.vi"/>
					</Item>
					<Item Name="output" Type="Folder">
						<Item Name="dsdll_output_write.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_write.vi"/>
						<Item Name="dsdll_output_play.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_play.vi"/>
						<Item Name="dsdll_output_stop.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_stop.vi"/>
						<Item Name="dsdll_output_set_volume.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_set_volume.vi"/>
						<Item Name="dsdll_output_status.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/output/dsdll_output_status.vi"/>
					</Item>
					<Item Name="control" Type="Folder">
						<Item Name="dsdll_initialize.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_initialize.vi"/>
						<Item Name="dsdll_get_dll_version_string.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_get_dll_version_string.vi"/>
						<Item Name="dsdll_enumerate_devices.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_enumerate_devices.vi"/>
						<Item Name="dsdll_open.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_open.vi"/>
						<Item Name="dsdll_close.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_close.vi"/>
						<Item Name="dsdll_config.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_config.vi"/>
						<Item Name="dsdll_status.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_status.vi"/>
					</Item>
					<Item Name="demo" Type="Folder">
						<Item Name="other" Type="Folder">
							<Item Name="gen_coherent_sine.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/other/gen_coherent_sine.vi"/>
							<Item Name="Get App Version.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/other/Get App Version.vi"/>
							<Item Name="control_enabled_state.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/other/control_enabled_state.vi"/>
							<Item Name="randn_approximation.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/other/randn_approximation.vi"/>
							<Item Name="simple_FFT.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/other/simple_FFT.vi"/>
						</Item>
						<Item Name="dsdll_basic_demo.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/dsdll_basic_demo.vi"/>
						<Item Name="dsdll_signal_demo.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/dsdll_signal_demo.vi"/>
						<Item Name="dsdll_stability_demo.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/demos/dsdll_stability_demo.vi"/>
					</Item>
					<Item Name="dsdll.dll" Type="Document" URL="../drivers/dsdll/dsdll.dll"/>
					<Item Name="dsdll_instance.ctl" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_instance.ctl"/>
					<Item Name="dsdll_device_record.ctl" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_device_record.ctl"/>
					<Item Name="dsdll_format.ctl" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_format.ctl"/>
					<Item Name="dsdll_sample_format.ctl" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/dsdll_sample_format.ctl"/>
					<Item Name="dsdll_vi_tree.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/control/dsdll_vi_tree.vi"/>
					<Item Name="COPYING" Type="Document" URL="../drivers/dsdll/COPYING"/>
					<Item Name="COPYING.LESSER" Type="Document" URL="../drivers/dsdll/COPYING.LESSER"/>
					<Item Name="NI_FileType.lvlib" Type="Library" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Utility/lvfile.llb/NI_FileType.lvlib"/>
					<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
					<Item Name="Get File Extension.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/Get File Extension.vi"/>
					<Item Name="FileVersionInformation.ctl" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/FileVersionInformation.ctl"/>
					<Item Name="FixedFileInfo_Struct.ctl" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/FixedFileInfo_Struct.ctl"/>
					<Item Name="MoveMemory.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/MoveMemory.vi"/>
					<Item Name="Clear Errors.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Clear Errors.vi"/>
					<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Error Cluster From Error Code.vi"/>
					<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
					<Item Name="BuildErrorSource.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/BuildErrorSource.vi"/>
					<Item Name="GetFileVersionInfoSize.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/GetFileVersionInfoSize.vi"/>
					<Item Name="GetFileVersionInfo.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/GetFileVersionInfo.vi"/>
					<Item Name="VerQueryValue.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/VerQueryValue.vi"/>
					<Item Name="FileVersionInfo.vi" Type="VI" URL="../drivers/dsdll/dsdll.lvlibp/1abvi3w/vi.lib/Platform/fileVersionInfo.llb/FileVersionInfo.vi"/>
				</Item>
				<Item Name="DSDLL Virtual Digitizer.lvlib" Type="Library" URL="../drivers/dsdll/DSDLL Virtual Digitizer.lvlib"/>
				<Item Name="dsdll.dll" Type="Document" URL="../dsdll.dll"/>
			</Item>
			<Item Name="Simulated ADC" Type="Folder">
				<Item Name="SimAdc Channel Cfg.ctl" Type="VI" URL="../drivers/simulated_adc/SimAdc Channel Cfg.ctl"/>
				<Item Name="SimAdc Config.ctl" Type="VI" URL="../drivers/simulated_adc/SimAdc Config.ctl"/>
				<Item Name="SimAdc Initialize Virtual Channels.vi" Type="VI" URL="../drivers/simulated_adc/SimAdc Initialize Virtual Channels.vi"/>
				<Item Name="SimAdc Clear Channels.ctl" Type="VI" URL="../drivers/simulated_adc/SimAdc Clear Channels.ctl"/>
				<Item Name="SimAdc Fetch Samples.vi" Type="VI" URL="../drivers/simulated_adc/SimAdc Fetch Samples.vi"/>
			</Item>
			<Item Name="Multiplexers" Type="Folder">
				<Item Name="Generic COM port" Type="Folder">
					<Item Name="GCOMM Signal.ctl" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Signal.ctl"/>
					<Item Name="GCOMM Logic State.ctl" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Logic State.ctl"/>
					<Item Name="GCOMM Virtual Channel.ctl" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Virtual Channel.ctl"/>
					<Item Name="GCOMM Session.ctl" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Session.ctl"/>
					<Item Name="GCOMM Open.vi" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Open.vi"/>
					<Item Name="GCOMM Set Path.vi" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Set Path.vi"/>
					<Item Name="GCOMM Close.vi" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Close.vi"/>
					<Item Name="GCOMM Check Channels" Type="VI" URL="../drivers/Multiplexers/Generic COM/GCOMM Check Channels"/>
				</Item>
				<Item Name="Generic niScope PFI" Type="Folder">
					<Item Name="niScope Mux Open.vi" Type="VI" URL="../drivers/Multiplexers/Generic niScope/niScope Mux Open.vi"/>
					<Item Name="niScope Mux Set Path.vi" Type="VI" URL="../drivers/Multiplexers/Generic niScope/niScope Mux Set Path.vi"/>
				</Item>
			</Item>
			<Item Name="Agilent DSO 90000" Type="Folder">
				<Item Name="Virtual Digitizer" Type="Folder">
					<Item Name="KeDSO session.ctl" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO session.ctl"/>
					<Item Name="KeDSO Virtual Channel.ctl" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Virtual Channel.ctl"/>
					<Item Name="KeDSO Trigger Source.ctl" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Trigger Source.ctl"/>
					<Item Name="KeDSO Trigger Setup.ctl" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Trigger Setup.ctl"/>
					<Item Name="KeDSO Record Aux Data.ctl" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Record Aux Data.ctl"/>
					<Item Name="KeDSO Record Sample Data.ctl" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Record Sample Data.ctl"/>
					<Item Name="KeDSO Initialize Virtual Channels.vi" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Initialize Virtual Channels.vi"/>
					<Item Name="KeDSO Setup Virtual Channels.vi" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Setup Virtual Channels.vi"/>
					<Item Name="KeDSO Initiate Digitizing Process.vi" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Initiate Digitizing Process.vi"/>
					<Item Name="KeDSO Try Fetch Data.vi" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Try Fetch Data.vi"/>
					<Item Name="KeDSO Abort Digitizing Process.vi" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Abort Digitizing Process.vi"/>
					<Item Name="KeDSO Close Virtual Channels.vi" Type="VI" URL="../drivers/Agilent DSO 90000/Virtual Digitizer/KeDSO Close Virtual Channels.vi"/>
				</Item>
				<Item Name="Agilent 90000 Series.lvlib" Type="Library" URL="../drivers/Agilent DSO 90000/Agilent 90000 Series.lvlib"/>
			</Item>
			<Item Name="cdaq" Type="Folder">
				<Item Name="low_level_old" Type="Folder">
					<Item Name="cdaq_anal_adc_capture.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_adc_capture.vi"/>
					<Item Name="cdaq_anal_adc_command.ctl" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_adc_command.ctl"/>
					<Item Name="cdaq_anal_adc_data.ctl" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_adc_data.ctl"/>
					<Item Name="cdaq_anal_adc_process.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_adc_process.vi"/>
					<Item Name="cdaq_anal_adc_process_get_status.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_adc_process_get_status.vi"/>
					<Item Name="cdaq_anal_idle_dac.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_idle_dac.vi"/>
					<Item Name="cdaq_anal_open.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_open.vi"/>
					<Item Name="cdaq_anal_session.ctl" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_session.ctl"/>
					<Item Name="cdaq_anal_write_dac_loop.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_anal_write_dac_loop.vi"/>
					<Item Name="cdaq_test.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_test.vi"/>
					<Item Name="read_me.txt" Type="Document" URL="../drivers/cdaq/low_level_old/read_me.txt"/>
					<Item Name="cdaq_dds_test.vi" Type="VI" URL="../drivers/cdaq/low_level_old/cdaq_dds_test.vi"/>
				</Item>
				<Item Name="cDAQ Session.ctl" Type="VI" URL="../drivers/cdaq/cDAQ Session.ctl"/>
				<Item Name="cDAQ Master Clock Mode.ctl" Type="VI" URL="../drivers/cdaq/cDAQ Master Clock Mode.ctl"/>
				<Item Name="cDAQ Virtual Channel.ctl" Type="VI" URL="../drivers/cdaq/cDAQ Virtual Channel.ctl"/>
				<Item Name="cDAQ Record Sample Data.ctl" Type="VI" URL="../drivers/cdaq/cDAQ Record Sample Data.ctl"/>
				<Item Name="cDAQ Record Aux Data.ctl" Type="VI" URL="../drivers/cdaq/cDAQ Record Aux Data.ctl"/>
				<Item Name="cDAQ Status.ctl" Type="VI" URL="../drivers/cdaq/cDAQ Status.ctl"/>
				<Item Name="ADC Status.ctl" Type="VI" URL="../adc/ADC Status.ctl"/>
				<Item Name="cDAQ Open ADC.vi" Type="VI" URL="../drivers/cdaq/cDAQ Open ADC.vi"/>
				<Item Name="cDAQ Digitizing Process.vi" Type="VI" URL="../drivers/cdaq/cDAQ Digitizing Process.vi"/>
				<Item Name="cDAQ Digitize.vi" Type="VI" URL="../drivers/cdaq/cDAQ Digitize.vi"/>
				<Item Name="cDAQ Abort Digitize.vi" Type="VI" URL="../drivers/cdaq/cDAQ Abort Digitize.vi"/>
				<Item Name="cDAQ Wait Digitize.vi" Type="VI" URL="../drivers/cdaq/cDAQ Wait Digitize.vi"/>
				<Item Name="cDAQ Kill Digitizing Process.vi" Type="VI" URL="../drivers/cdaq/cDAQ Kill Digitizing Process.vi"/>
				<Item Name="cDAQ Get Info.vi" Type="VI" URL="../drivers/cdaq/cDAQ Get Info.vi"/>
				<Item Name="cDAQ Get Digitizing Process Status.vi" Type="VI" URL="../drivers/cdaq/cDAQ Get Digitizing Process Status.vi"/>
			</Item>
			<Item Name="Fluke 8588A" Type="Folder">
				<Item Name="Top Level" Type="Folder">
					<Item Name="F8588A Initialize Digitizing Mode.vi" Type="VI" URL="../drivers/Fluke 8588A/top level/F8588A Initialize Digitizing Mode.vi"/>
					<Item Name="F8588A Configure Sampling.vi" Type="VI" URL="../drivers/Fluke 8588A/top level/F8588A Configure Sampling.vi"/>
					<Item Name="F8588A Soft Close.vi" Type="VI" URL="../drivers/Fluke 8588A/top level/F8588A Soft Close.vi"/>
					<Item Name="F8588A Digitizing Process.vi" Type="VI" URL="../drivers/Fluke 8588A/top level/F8588A Digitizing Process.vi"/>
					<Item Name="F8588A Read Stream.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Read Stream.vi"/>
					<Item Name="F8588A Async Start Digitizing Process.vi" Type="VI" URL="../drivers/Fluke 8588A/top level/F8588A Async Start Digitizing Process.vi"/>
					<Item Name="F8588A Test.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Test.vi"/>
					<Item Name="F8588A Test2.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Test2.vi"/>
				</Item>
				<Item Name="F8588A Low Pass Filter.ctl" Type="VI" URL="../drivers/Fluke 8588A/F8588A Low Pass Filter.ctl"/>
				<Item Name="F8588A Phase Lock.ctl" Type="VI" URL="../drivers/Fluke 8588A/F8588A Phase Lock.ctl"/>
				<Item Name="F8588A Coupling.ctl" Type="VI" URL="../drivers/Fluke 8588A/F8588A Coupling.ctl"/>
				<Item Name="F8588A Initialize.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Initialize.vi"/>
				<Item Name="F8588A Close.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Close.vi"/>
				<Item Name="F8588A Default Instrument Setup.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Default Instrument Setup.vi"/>
				<Item Name="F8588A Error Query.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Error Query.vi"/>
				<Item Name="F8588A Reset.vi" Type="VI" URL="../drivers/Fluke 8588A/F8588A Reset.vi"/>
			</Item>
			<Item Name="niScope Virtual Digitizer.lvlib" Type="Library" URL="../drivers/niScope/niScope Virtual Digitizer.lvlib"/>
			<Item Name="AWG.lvlib" Type="Library" URL="../drivers/AWG/AWG.lvlib"/>
			<Item Name="Counter.lvlib" Type="Library" URL="../drivers/Counter/Counter.lvlib"/>
			<Item Name="3458A Virtual Digitizer.lvlib" Type="Library" URL="../drivers/DMM/3458A Virtual Digitizer.lvlib"/>
		</Item>
		<Item Name="octave" Type="Folder">
			<Item Name="mat" Type="Folder">
				<Item Name="MAT Determine Data Type Fixed.vi" Type="VI" URL="../octave/mat/MAT Determine Data Type Fixed.vi"/>
				<Item Name="MAT Determine Data Type.vi" Type="VI" URL="../octave/mat/MAT Determine Data Type.vi"/>
				<Item Name="MAT Type Representation.ctl" Type="VI" URL="../octave/mat/MAT Type Representation.ctl"/>
				<Item Name="MAT read fixed test.vi" Type="VI" URL="../octave/mat/MAT read fixed test.vi"/>
				<Item Name="MAT Search Matrix.vi" Type="VI" URL="../octave/mat/MAT Search Matrix.vi"/>
				<Item Name="MAT Read Matrix.vi" Type="VI" URL="../octave/mat/MAT Read Matrix.vi"/>
				<Item Name="MAT Read Matrix Header.vi" Type="VI" URL="../octave/mat/MAT Read Matrix Header.vi"/>
				<Item Name="MAT Save Matrix.vi" Type="VI" URL="../octave/mat/MAT Save Matrix.vi"/>
				<Item Name="MAT Save Matrix Header.vi" Type="VI" URL="../octave/mat/MAT Save Matrix Header.vi"/>
				<Item Name="MAT Stream Write Alloc Empty Data.vi" Type="VI" URL="../octave/mat/MAT Stream Write Alloc Empty Data.vi"/>
				<Item Name="MAT Stream Writer Allign Streamed Data.vi" Type="VI" URL="../octave/mat/MAT Stream Writer Allign Streamed Data.vi"/>
			</Item>
			<Item Name="infolib" Type="Folder">
				<Item Name="infolib.lvlibp" Type="LVLibp" URL="../octave/infolib.lvlibp">
					<Item Name="Private" Type="Folder">
						<Item Name="Add key polymorph parts" Type="Folder">
							<Item Name="Boolean.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add key polymorph parts/Boolean.vi"/>
							<Item Name="CXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add key polymorph parts/CXT.vi"/>
							<Item Name="EXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add key polymorph parts/EXT.vi"/>
							<Item Name="I64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add key polymorph parts/I64.vi"/>
							<Item Name="String.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add key polymorph parts/String.vi"/>
							<Item Name="Time Stamp.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add key polymorph parts/Time Stamp.vi"/>
							<Item Name="U64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add key polymorph parts/U64.vi"/>
						</Item>
						<Item Name="Add matrix polymorph parts" Type="Folder">
							<Item Name="1D CXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/1D CXT.vi"/>
							<Item Name="1D EXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/1D EXT.vi"/>
							<Item Name="1D I64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/1D I64.vi"/>
							<Item Name="1D String.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/1D String.vi"/>
							<Item Name="1D Time Stamp.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/1D Time Stamp.vi"/>
							<Item Name="1D U64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/1D U64.vi"/>
							<Item Name="2D CXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/2D CXT.vi"/>
							<Item Name="2D EXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/2D EXT.vi"/>
							<Item Name="2D I64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/2D I64.vi"/>
							<Item Name="2D String.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/2D String.vi"/>
							<Item Name="2D Time Stamp.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/2D Time Stamp.vi"/>
							<Item Name="2D U64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Add matrix polymorph parts/2D U64.vi"/>
						</Item>
						<Item Name="Get key polymorph parts" Type="Folder">
							<Item Name="GetBoolean.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get key polymorph parts/GetBoolean.vi"/>
							<Item Name="GetCXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get key polymorph parts/GetCXT.vi"/>
							<Item Name="GetEXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get key polymorph parts/GetEXT.vi"/>
							<Item Name="GetI64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get key polymorph parts/GetI64.vi"/>
							<Item Name="GetString.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get key polymorph parts/GetString.vi"/>
							<Item Name="GetTime Stamp.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get key polymorph parts/GetTime Stamp.vi"/>
							<Item Name="GetU64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get key polymorph parts/GetU64.vi"/>
						</Item>
						<Item Name="Get matrix polymorph parts" Type="Folder">
							<Item Name="Get 1D CXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 1D CXT.vi"/>
							<Item Name="Get 1D EXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 1D EXT.vi"/>
							<Item Name="Get 1D I64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 1D I64.vi"/>
							<Item Name="Get 1D String.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 1D String.vi"/>
							<Item Name="Get 1D Time Stamp.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 1D Time Stamp.vi"/>
							<Item Name="Get 1D U64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 1D U64.vi"/>
							<Item Name="Get 2D CXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 2D CXT.vi"/>
							<Item Name="Get 2D EXT.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 2D EXT.vi"/>
							<Item Name="Get 2D I64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 2D I64.vi"/>
							<Item Name="Get 2D U64.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 2D U64.vi"/>
							<Item Name="Get 2D String.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 2D String.vi"/>
							<Item Name="Get 2D Time Stamp.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Get matrix polymorph parts/Get 2D Time Stamp.vi"/>
						</Item>
						<Item Name="Testing" Type="Folder">
							<Item Name="test library.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Testing/test library.vi"/>
							<Item Name="test simple.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Testing/test simple.vi"/>
						</Item>
						<Item Name="Utilities" Type="Folder">
							<Item Name="Add spaces.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Add spaces.vi"/>
							<Item Name="Assure Newline at End.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Assure Newline at End.vi"/>
							<Item Name="Convert String to Time Stamp.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Convert String to Time Stamp.vi"/>
							<Item Name="Create 1D Table.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Create 1D Table.vi"/>
							<Item Name="Create 2D Table.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Create 2D Table.vi"/>
							<Item Name="Create key line.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Create key line.vi"/>
							<Item Name="Create Sections Headings.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Create Sections Headings.vi"/>
							<Item Name="Create Table Heading.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Create Table Heading.vi"/>
							<Item Name="EOL.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/EOL.vi"/>
							<Item Name="Exist Section.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Exist Section.vi"/>
							<Item Name="Flatten to CSV Record.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Flatten to CSV Record.vi"/>
							<Item Name="Get Key Line.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Get Key Line.vi"/>
							<Item Name="Get Matrix String.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Get Matrix String.vi"/>
							<Item Name="Get Section Indentation Length.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Get Section Indentation Length.vi"/>
							<Item Name="Indent Size.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Indent Size.vi"/>
							<Item Name="Insert.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Insert.vi"/>
							<Item Name="Parse CSV String.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Parse CSV String.vi"/>
							<Item Name="RegExpTranslate.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/RegExpTranslate.vi"/>
							<Item Name="Remove all sections.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Remove all sections.vi"/>
						</Item>
					</Item>
					<Item Name="Public" Type="Folder">
						<Item Name="Add Key Or Table.vi" Type="VI" URL="../octave/infolib.lvlibp/Public/Add Key Or Table.vi"/>
						<Item Name="Get Key Or Table.vi" Type="VI" URL="../octave/infolib.lvlibp/Public/Get Key Or Table.vi"/>
						<Item Name="Get Section.vi" Type="VI" URL="../octave/infolib.lvlibp/Private/Utilities/Get Section.vi"/>
						<Item Name="Insert Info Data.vi" Type="VI" URL="../octave/infolib.lvlibp/Public/Insert Info Data.vi"/>
						<Item Name="Load Info.vi" Type="VI" URL="../octave/infolib.lvlibp/Public/Load Info.vi"/>
						<Item Name="Save Info.vi" Type="VI" URL="../octave/infolib.lvlibp/Public/Save Info.vi"/>
					</Item>
					<Item Name="Bit-array To Byte-array.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/picture/pictutil.llb/Bit-array To Byte-array.vi"/>
					<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
					<Item Name="Check Path.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/picture/jpeg.llb/Check Path.vi"/>
					<Item Name="Clear Errors.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Clear Errors.vi"/>
					<Item Name="Create Mask By Alpha.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/picture/picture.llb/Create Mask By Alpha.vi"/>
					<Item Name="Directory of Top Level VI.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/picture/jpeg.llb/Directory of Top Level VI.vi"/>
					<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Error Cluster From Error Code.vi"/>
					<Item Name="imagedata.ctl" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/picture/picture.llb/imagedata.ctl"/>
					<Item Name="LVDateTimeRec.ctl" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/miscctls.llb/LVDateTimeRec.ctl"/>
					<Item Name="NI_FileType.lvlib" Type="Library" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/lvfile.llb/NI_FileType.lvlib"/>
					<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
					<Item Name="Read PNG File.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/picture/png.llb/Read PNG File.vi"/>
					<Item Name="Space Constant.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/dlg_ctls.llb/Space Constant.vi"/>
					<Item Name="Trim Whitespace.vi" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Trim Whitespace.vi"/>
					<Item Name="whitespace.ctl" Type="VI" URL="../octave/infolib.lvlibp/1abvi3w/vi.lib/Utility/error.llb/whitespace.ctl"/>
				</Item>
				<Item Name="Info Insert Row to 2D Reals Array.vi" Type="VI" URL="../octave/info/Info Insert Row to 2D Reals Array.vi"/>
				<Item Name="Info Insert Row to 2D Int64 Array.vi" Type="VI" URL="../octave/info/Info Insert Row to 2D Int64 Array.vi"/>
				<Item Name="Info Insert Row to 2D String Array.vi" Type="VI" URL="../octave/info/Info Insert Row to 2D String Array.vi"/>
				<Item Name="Info Insert Row to 1D TimeStamps Array.vi" Type="VI" URL="../octave/info/Info Insert Row to 1D TimeStamps Array.vi"/>
				<Item Name="Info Insert Row to 1D String Array.vi" Type="VI" URL="../octave/info/Info Insert Row to 1D String Array.vi"/>
				<Item Name="Info Replace Scalar.vi" Type="VI" URL="../octave/info/Info Replace Scalar.vi"/>
				<Item Name="Info Replace Matrix.vi" Type="VI" URL="../octave/info/Info Replace Matrix.vi"/>
			</Item>
			<Item Name="golpi" Type="Folder">
				<Item Name="GOLPI Multi Process" Type="Folder">
					<Item Name="GUI &amp; Stuff" Type="Folder">
						<Item Name="GOLPI Initialize.vi" Type="VI" URL="../octave/golpi/mpc/GUI/GOLPI Initialize.vi"/>
						<Item Name="GOLPI Rebuild Start and Stop Commands.vi" Type="VI" URL="../octave/golpi/mpc/GUI/GOLPI Rebuild Start and Stop Commands.vi"/>
						<Item Name="GOLPI Config Panel.vi" Type="VI" URL="../octave/golpi/mpc/GOLPI Config Panel.vi"/>
						<Item Name="GOLPI Package Assistant Panel.vi" Type="VI" URL="../octave/golpi/mpc/GUI/GOLPI Package Assistant Panel.vi"/>
						<Item Name="GOLPI Package Assistant Actions" Type="VI" URL="../octave/golpi/mpc/GUI/GOLPI Package Assistant Actions"/>
					</Item>
					<Item Name="GOLPI Multi Process.lvlib" Type="Library" URL="../octave/golpi/mpc/GOLPI Multi Process.lvlib"/>
					<Item Name="golpi_mpc_demo.vi" Type="VI" URL="../octave/golpi/mpc/golpi_mpc_demo.vi"/>
				</Item>
				<Item Name="GOLPI Library.lvlibp" Type="LVLibp" URL="../octave/golpi/GOLPI Library.lvlibp">
					<Item Name="Private" Type="Folder">
						<Item Name="Bitstream" Type="Folder">
							<Item Name="Bitstream Decode.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Bitstream/Bitstream Decode.vi"/>
							<Item Name="Bitstream to Bytes.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Bitstream/Bitstream to Bytes.vi"/>
						</Item>
						<Item Name="Get Variable - auxiliary" Type="Folder">
							<Item Name="Struct" Type="Folder">
								<Item Name="Struct Fill Cluster By Items Record.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - auxiliary/Struct/Struct Fill Cluster By Items Record.vi"/>
								<Item Name="Struct Parse Binary.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - auxiliary/Struct/Struct Parse Binary.vi"/>
								<Item Name="Struct Parse Variable Type.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - auxiliary/Struct/Struct Parse Variable Type.vi"/>
							</Item>
							<Item Name="Check and Get Sizes.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - auxiliary/Check and Get Sizes.vi"/>
							<Item Name="Get Matrix - bitstream.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - auxiliary/Get Matrix - bitstream.vi"/>
							<Item Name="Get Matrix - file.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - auxiliary/Get Matrix - file.vi"/>
							<Item Name="Get Matrix - stdout.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - auxiliary/Get Matrix - stdout.vi"/>
						</Item>
						<Item Name="Get Variable - polymorph parts" Type="Folder">
							<Item Name="Get Struct.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get Struct.vi"/>
							<Item Name="Get String.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get String.vi"/>
							<Item Name="Get Double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get Double.vi"/>
							<Item Name="Get Double Complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get Double Complex.vi"/>
							<Item Name="Get 1D Array String.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get 1D Array String.vi"/>
							<Item Name="Get 1D Array Double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get 1D Array Double.vi"/>
							<Item Name="Get 1D Array Double Complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get 1D Array Double Complex.vi"/>
							<Item Name="Get 2D Array Double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get 2D Array Double.vi"/>
							<Item Name="Get 2D Array Double Complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Get Variable - polymorph parts/Get 2D Array Double Complex.vi"/>
						</Item>
						<Item Name="matfilerw" Type="Folder">
							<Item Name="MAT Determine Data Type.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT Determine Data Type.vi"/>
							<Item Name="MAT File Header.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT File Header.vi"/>
							<Item Name="MAT Read Matrix Header.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT Read Matrix Header.vi"/>
							<Item Name="MAT Read Matrix.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT Read Matrix.vi"/>
							<Item Name="MAT Save Matrix Header.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT Save Matrix Header.vi"/>
							<Item Name="MAT Save Matrix.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT Save Matrix.vi"/>
							<Item Name="MAT Save-Read Example.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT Save-Read Example.vi"/>
							<Item Name="MAT Type Representation.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/matfilerw/MAT Type Representation.ctl"/>
						</Item>
						<Item Name="Set Variable - auxiliary" Type="Folder">
							<Item Name="Set Matrix - file.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - auxiliary/Set Matrix - file.vi"/>
							<Item Name="Set Matrix - stdin.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - auxiliary/Set Matrix - stdin.vi"/>
						</Item>
						<Item Name="Set Variable - polymorph parts" Type="Folder">
							<Item Name="Set String.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set String.vi"/>
							<Item Name="Set Double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set Double.vi"/>
							<Item Name="Set Double Complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set Double Complex.vi"/>
							<Item Name="Set 1D Array String.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set 1D Array String.vi"/>
							<Item Name="Set 1D Array Double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set 1D Array Double.vi"/>
							<Item Name="Set 1D Array Double Complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set 1D Array Double Complex.vi"/>
							<Item Name="Set 2D Array Double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set 2D Array Double.vi"/>
							<Item Name="Set 2D Array Double Complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Set Variable - polymorph parts/Set 2D Array Double Complex.vi"/>
						</Item>
						<Item Name="testing" Type="Folder">
							<Item Name="GOLPI full test - part structure.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/testing/GOLPI full test - part structure.vi"/>
							<Item Name="GOLPI full test - part test vector complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/testing/GOLPI full test - part test vector complex.vi"/>
							<Item Name="GOLPI full test - part test vector double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/testing/GOLPI full test - part test vector double.vi"/>
							<Item Name="GOLPI full test.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/testing/GOLPI full test.vi"/>
							<Item Name="GOLPI simple testing.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/testing/GOLPI simple testing.vi"/>
							<Item Name="Test golpi Package Installation.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/testing/Test golpi Package Installation.vi"/>
						</Item>
						<Item Name="Type Definitions" Type="Folder">
							<Item Name="Bitstream Data Type.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Type Definitions/Bitstream Data Type.ctl"/>
							<Item Name="Bitstream Data.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Type Definitions/Bitstream Data.ctl"/>
							<Item Name="Custom Error Codes Enum Type Def.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Type Definitions/Custom Error Codes Enum Type Def.vi"/>
							<Item Name="Struct Data Types.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Type Definitions/Struct Data Types.ctl"/>
							<Item Name="Struct Item Record.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Type Definitions/Struct Item Record.ctl"/>
							<Item Name="Struct Item Types.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Type Definitions/Struct Item Types.ctl"/>
						</Item>
						<Item Name="Utilities" Type="Folder">
							<Item Name="Burst String to Lines.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/Burst String to Lines.vi"/>
							<Item Name="Generate Custom Error.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/Generate Custom Error.vi"/>
							<Item Name="Is Scalar Vector Matrix.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/Is Scalar Vector Matrix.vi"/>
							<Item Name="String to Complex.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/String to Complex.vi"/>
							<Item Name="String to Double.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/String to Double.vi"/>
							<Item Name="ASCII numbers to String.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/ASCII numbers to String.vi"/>
							<Item Name="Check and Generate Path to Octave Executable.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/Check and Generate Path to Octave Executable.vi"/>
							<Item Name="Is Variable Name Part of Struct.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/Is Variable Name Part of Struct.vi"/>
							<Item Name="Install Octave Package golpi.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/Install Octave Package golpi.vi"/>
							<Item Name="Check Matlab Mode Error.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Private/Utilities/Check Matlab Mode Error.vi"/>
						</Item>
					</Item>
					<Item Name="Public" Type="Folder">
						<Item Name="Data" Type="Folder">
							<Item Name="Get Variable.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Data/Get Variable.vi"/>
							<Item Name="Set Variable.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Data/Set Variable.vi"/>
						</Item>
						<Item Name="Examples" Type="Folder">
							<Item Name="Demo - Transfer Modes.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Examples/Demo - Transfer Modes.vi"/>
							<Item Name="Demo - GNU Octave Terminal.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Examples/Demo - GNU Octave Terminal.vi"/>
							<Item Name="Demo - Simple Use.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Examples/Demo - Simple Use.vi"/>
							<Item Name="Demo - Advanced Use.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Examples/Demo - Advanced Use.vi"/>
						</Item>
						<Item Name="Pipes" Type="Folder">
							<Item Name="Write Command.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Pipes/Write Command.vi"/>
							<Item Name="Read Output.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Pipes/Read Output.vi"/>
							<Item Name="Read Full Output.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Pipes/Read Full Output.vi"/>
							<Item Name="Read Output Till Settle.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Pipes/Read Output Till Settle.vi"/>
							<Item Name="Read Output Till Keyword.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Pipes/Read Output Till Keyword.vi"/>
						</Item>
						<Item Name="Utility" Type="Folder">
							<Item Name="Set Bitstream Mode.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Utility/Set Bitstream Mode.vi"/>
							<Item Name="Set Struct Transfer Mode.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Utility/Set Struct Transfer Mode.vi"/>
							<Item Name="Check Output For Octave Errors.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Utility/Check Output For Octave Errors.vi"/>
							<Item Name="Check Status.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Utility/Check Status.vi"/>
							<Item Name="Set Debug Mode.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Utility/Set Debug Mode.vi"/>
						</Item>
						<Item Name="GOLPI reference Type Def.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/GOLPI reference Type Def.ctl"/>
						<Item Name="Start GNU Octave.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Start GNU Octave.vi"/>
						<Item Name="Quit GNU Octave.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/Quit GNU Octave.vi"/>
						<Item Name="VI Tree.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/Public/VI Tree.vi"/>
					</Item>
					<Item Name="Application Directory.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/file.llb/Application Directory.vi"/>
					<Item Name="Bit-array To Byte-array.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/picture/pictutil.llb/Bit-array To Byte-array.vi"/>
					<Item Name="BuildHelpPath.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/BuildHelpPath.vi"/>
					<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
					<Item Name="Check Path.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/picture/jpeg.llb/Check Path.vi"/>
					<Item Name="Check Special Tags.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Check Special Tags.vi"/>
					<Item Name="Clear Errors.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Clear Errors.vi"/>
					<Item Name="compatCalcOffset.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/_oldvers/_oldvers.llb/compatCalcOffset.vi"/>
					<Item Name="compatFileDialog.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/_oldvers/_oldvers.llb/compatFileDialog.vi"/>
					<Item Name="compatOpenFileOperation.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/_oldvers/_oldvers.llb/compatOpenFileOperation.vi"/>
					<Item Name="Convert property node font to graphics font.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Convert property node font to graphics font.vi"/>
					<Item Name="Create Mask By Alpha.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/picture/picture.llb/Create Mask By Alpha.vi"/>
					<Item Name="Details Display Dialog.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Details Display Dialog.vi"/>
					<Item Name="DialogType.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/DialogType.ctl"/>
					<Item Name="DialogTypeEnum.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/DialogTypeEnum.ctl"/>
					<Item Name="Directory of Top Level VI.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/picture/jpeg.llb/Directory of Top Level VI.vi"/>
					<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Error Cluster From Error Code.vi"/>
					<Item Name="Error Code Database.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Error Code Database.vi"/>
					<Item Name="ErrWarn.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/ErrWarn.ctl"/>
					<Item Name="eventvkey.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/event_ctls.llb/eventvkey.ctl"/>
					<Item Name="ex_CorrectErrorChain.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/express/express shared/ex_CorrectErrorChain.vi"/>
					<Item Name="Find Tag.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Find Tag.vi"/>
					<Item Name="Format Message String.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Format Message String.vi"/>
					<Item Name="General Error Handler CORE.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/General Error Handler CORE.vi"/>
					<Item Name="General Error Handler.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/General Error Handler.vi"/>
					<Item Name="Get String Text Bounds.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Get String Text Bounds.vi"/>
					<Item Name="Get Text Rect.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/picture/picture.llb/Get Text Rect.vi"/>
					<Item Name="GetHelpDir.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/GetHelpDir.vi"/>
					<Item Name="GetRTHostConnectedProp.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/GetRTHostConnectedProp.vi"/>
					<Item Name="imagedata.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/picture/picture.llb/imagedata.ctl"/>
					<Item Name="List Directory and LLBs.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/List Directory and LLBs.vi"/>
					<Item Name="Longest Line Length in Pixels.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Longest Line Length in Pixels.vi"/>
					<Item Name="LV Process library.lvlib" Type="Library" URL="../octave/golpi/GOLPI Library.lvlibp/LV Process source distribution/LV Process library.lvlib"/>
					<Item Name="LVBoundsTypeDef.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/miscctls.llb/LVBoundsTypeDef.ctl"/>
					<Item Name="NI_FileType.lvlib" Type="Library" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/lvfile.llb/NI_FileType.lvlib"/>
					<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
					<Item Name="Not Found Dialog.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Not Found Dialog.vi"/>
					<Item Name="Open_Create_Replace File.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/_oldvers/_oldvers.llb/Open_Create_Replace File.vi"/>
					<Item Name="Read PNG File.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/picture/png.llb/Read PNG File.vi"/>
					<Item Name="Recursive File List.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/Recursive File List.vi"/>
					<Item Name="Search and Replace Pattern.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Search and Replace Pattern.vi"/>
					<Item Name="Set Bold Text.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Set Bold Text.vi"/>
					<Item Name="Set String Value.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Set String Value.vi"/>
					<Item Name="Simple Error Handler.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Simple Error Handler.vi"/>
					<Item Name="Space Constant.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/dlg_ctls.llb/Space Constant.vi"/>
					<Item Name="subFile Dialog.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/express/express input/FileDialogBlock.llb/subFile Dialog.vi"/>
					<Item Name="TagReturnType.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/TagReturnType.ctl"/>
					<Item Name="Three Button Dialog CORE.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Three Button Dialog CORE.vi"/>
					<Item Name="Three Button Dialog.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Three Button Dialog.vi"/>
					<Item Name="Trim Whitespace.vi" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Trim Whitespace.vi"/>
					<Item Name="whitespace.ctl" Type="VI" URL="../octave/golpi/GOLPI Library.lvlibp/1abvi3w/vi.lib/Utility/error.llb/whitespace.ctl"/>
				</Item>
				<Item Name="COPYING" Type="Document" URL="../octave/golpi/COPYING"/>
				<Item Name="COPYING.LESSER" Type="Document" URL="../octave/golpi/COPYING.LESSER"/>
				<Item Name="lv_proc.dll" Type="Document" URL="../lv_proc.dll"/>
				<Item Name="golpi-1.2.1.tar.gz" Type="Document" URL="../octave/golpi/golpi-1.2.1.tar.gz"/>
			</Item>
		</Item>
		<Item Name="varilib" Type="Folder">
			<Item Name="varilib.lvlib" Type="Library" URL="../varilib/varilib.lvlib"/>
			<Item Name="lvanlys.dll" Type="Document" URL="../varilib/lvanlys.dll"/>
		</Item>
		<Item Name="measure" Type="Folder">
			<Item Name="GUI" Type="Folder">
				<Item Name="GUI Waveform Info.ctl" Type="VI" URL="../measure/GUI/GUI Waveform Info.ctl"/>
				<Item Name="GUI Set Error To String.vi" Type="VI" URL="../measure/GUI/GUI Set Error To String.vi"/>
				<Item Name="GUI Set Error and Display Error Status.vi" Type="VI" URL="../measure/GUI/GUI Set Error and Display Error Status.vi"/>
				<Item Name="GUI Write Sequence Item Status.vi" Type="VI" URL="../measure/GUI/GUI Write Sequence Item Status.vi"/>
				<Item Name="GUI Write Sampling Status.vi" Type="VI" URL="../measure/GUI/GUI Write Sampling Status.vi"/>
				<Item Name="GUI Update Trigger Mode Selector.vi" Type="VI" URL="../measure/GUI/GUI Update Trigger Mode Selector.vi"/>
				<Item Name="GUI Update Range Selectors.vi" Type="VI" URL="../measure/GUI/GUI Update Range Selectors.vi"/>
				<Item Name="GUI Wavefrom Panel.vi" Type="VI" URL="../measure/GUI/GUI Wavefrom Panel.vi"/>
				<Item Name="GUI Waveform Show.vi" Type="VI" URL="../measure/GUI/GUI Waveform Show.vi"/>
				<Item Name="GUI Waveform Update.vi" Type="VI" URL="../measure/GUI/GUI Waveform Update.vi"/>
				<Item Name="GUI FFT panel 2x.vi" Type="VI" URL="../measure/GUI/GUI FFT panel 2x.vi"/>
				<Item Name="GUI FFT Show.vi" Type="VI" URL="../measure/GUI/GUI FFT Show.vi"/>
				<Item Name="GUI FFT Update.vi" Type="VI" URL="../measure/GUI/GUI FFT Update.vi"/>
				<Item Name="GUI Show Not Available Attribute Message.vi" Type="VI" URL="../measure/GUI/GUI Show Not Available Attribute Message.vi"/>
			</Item>
			<Item Name="sequence" Type="Folder">
				<Item Name="Meas Generate Sequence.vi" Type="VI" URL="../measure/sequence/Meas Generate Sequence.vi"/>
				<Item Name="Meas Check Sequence Files.vi" Type="VI" URL="../measure/sequence/Meas Check Sequence Files.vi"/>
				<Item Name="Meas Sequence Item.ctl" Type="VI" URL="../measure/Meas Sequence Item.ctl"/>
			</Item>
			<Item Name="files" Type="Folder">
				<Item Name="Meas Samples Stream.ctl" Type="VI" URL="../measure/files/Meas Samples Stream.ctl"/>
				<Item Name="Meas Create Data Folder.vi" Type="VI" URL="../measure/files/Meas Create Data Folder.vi"/>
				<Item Name="Meas Create Samples Stream MAT File.vi" Type="VI" URL="../measure/files/Meas Create Samples Stream MAT File.vi"/>
				<Item Name="Meas Write Samples Stream to MAT File.vi" Type="VI" URL="../measure/files/Meas Write Samples Stream to MAT File.vi"/>
				<Item Name="Meas Close Samples Stream MAT Variable.vi" Type="VI" URL="../measure/files/Meas Close Samples Stream MAT Variable.vi"/>
				<Item Name="Meas Add Temperature Data To Sample MAT File.vi" Type="VI" URL="../measure/files/Meas Add Temperature Data To Sample MAT File.vi"/>
				<Item Name="Meas Write Record Header File.vi" Type="VI" URL="../measure/files/Meas Write Record Header File.vi"/>
				<Item Name="Meas Write Correction Data.vi" Type="VI" URL="../measure/files/Meas Write Correction Data.vi"/>
				<Item Name="Meas Get Record Section.vi" Type="VI" URL="../measure/files/Meas Get Record Section.vi"/>
				<Item Name="Meas Get Session.vi" Type="VI" URL="../measure/files/Meas Get Session.vi"/>
				<Item Name="Meas Generate File Name.vi" Type="VI" URL="../measure/files/Meas Generate File Name.vi"/>
			</Item>
			<Item Name="processing" Type="Folder">
				<Item Name="QWTB" Type="Folder">
					<Item Name="GUI" Type="Folder">
						<Item Name="Meas Proc QWTB Plot Scale Mode.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Plot Scale Mode.ctl"/>
						<Item Name="Meas Proc QWTB Plot Legend.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Plot Legend.ctl"/>
						<Item Name="Meas Proc QWTB Plot Config.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Plot Config.ctl"/>
						<Item Name="Meas Proc QWTB Export Mode.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Export Mode.ctl"/>
						<Item Name="MEas Proc QWTB Export Sheet Name Mode.ctl" Type="VI" URL="../measure/processing/QWTB/MEas Proc QWTB Export Sheet Name Mode.ctl"/>
						<Item Name="Meas Proc QWTB Export Sheet Pos.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Export Sheet Pos.ctl"/>
						<Item Name="Meas Proc QWTB Update Result Table Variable Info.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Update Result Table Variable Info.vi"/>
						<Item Name="Meas Proc QWTB Result Plot Panel.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Result Plot Panel.vi"/>
						<Item Name="Meas Proc QWTB String to Table Writter.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB String to Table Writter.vi"/>
						<Item Name="Meas Proc QWTB Parse Table.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Parse Table.vi"/>
						<Item Name="Meas Proc QWTB Set Params Table.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Set Params Table.vi"/>
						<Item Name="Meas Proc QWTB Set Result Table Sizes.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Set Result Table Sizes.vi"/>
						<Item Name="Meas Proc QWTB Fix Result Table Selection.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Fix Result Table Selection.vi"/>
						<Item Name="Meas Proc QWTB Multicore Panel.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Multicore Panel.vi"/>
						<Item Name="Meas Proc QWTB Export Result.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Export Result.vi"/>
					</Item>
					<Item Name="Batch" Type="Folder">
						<Item Name="Meas Batch Proc QWTB Panel.vi" Type="VI" URL="../measure/processing/QWTB/Batch/Meas Batch Proc QWTB Panel.vi"/>
					</Item>
					<Item Name="Meas Proc QWTB Calculation Setup.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Calculation Setup.ctl"/>
					<Item Name="Meas Proc QWTB Setup.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Setup.ctl"/>
					<Item Name="Meas Proc QWTB Viewer Asyn Session.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Viewer Asyn Session.ctl"/>
					<Item Name="Meas Proc QWTB Algorithm Info.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Algorithm Info.ctl"/>
					<Item Name="Meas Proc QWTB Algorithm Parameter Data.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Algorithm Parameter Data.ctl"/>
					<Item Name="Meas Proc QWTB View Max Dim.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB View Max Dim.ctl"/>
					<Item Name="Meas Proc QWTB View Uncertainty Mode.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB View Uncertainty Mode.ctl"/>
					<Item Name="Meas Proc QWTB View Group Mode.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB View Group Mode.ctl"/>
					<Item Name="Meas Proc QWTB Update Flags.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Update Flags.ctl"/>
					<Item Name="Meas Proc QWTB Viewer References.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Viewer References.ctl"/>
					<Item Name="Meas Proc QWTB View Phase Mode.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB View Phase Mode.ctl"/>
					<Item Name="Meas Proc QWTB Algorithm Flags.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Algorithm Flags.ctl"/>
					<Item Name="Meas Proc QWTB Uncertainty Mode.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Uncertainty Mode.ctl"/>
					<Item Name="Meas Proc QWTB Multicore Type.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Multicore Type.ctl"/>
					<Item Name="Meas Proc QWTB Multicore Setup.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Multicore Setup.ctl"/>
					<Item Name="Meas Proc QWTB Get Results.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Get Results.vi"/>
					<Item Name="Meas Proc QWTB Initialize Result Queue.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Initialize Result Queue.vi"/>
					<Item Name="Meas Proc QWTB Close Result Queue.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Close Result Queue.vi"/>
					<Item Name="Meas Proc QWTB Notify Result Queue.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Notify Result Queue.vi"/>
					<Item Name="Meas Proc QWTB Update Result View.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Update Result View.vi"/>
					<Item Name="Meas Proc QWTB Update Result View Process.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Update Result View Process.vi"/>
					<Item Name="Meas Proc QWTB Test.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Test.vi"/>
					<Item Name="Meas Proc QWTB Load List of Algorithms.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Load List of Algorithms.vi"/>
					<Item Name="Meas Proc QWTB Get Input Parameter Info.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Get Input Parameter Info.vi"/>
					<Item Name="Meas Proc QWTB Load Algorithm.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Load Algorithm.vi"/>
					<Item Name="Meas Proc QWTB Generate Algorithm Info Section.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Generate Algorithm Info Section.vi"/>
					<Item Name="Meas Proc QWTB Write Algorithm Processing Header.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Write Algorithm Processing Header.vi"/>
					<Item Name="Meas Proc QWTB Multicore Start Servers.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Multicore Start Servers.vi"/>
					<Item Name="Meas Proc QWTB Parallel Initialize.vi" Type="VI" URL="../measure/processing/Meas Proc QWTB Parallel Initialize.vi"/>
					<Item Name="Meas Proc QWTB Parallel Check Results.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Parallel Check Results.vi"/>
					<Item Name="Meas Proc QWTB Exec Mode.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Exec Mode.ctl"/>
					<Item Name="Meas Proc QWTB Spectrum Data.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Spectrum Data.ctl"/>
					<Item Name="Meas Proc QWTB Quantity Record.ctl" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Quantity Record.ctl"/>
					<Item Name="Meas Proc QWTB Load Result Spectra.vi" Type="VI" URL="../measure/processing/QWTB/Meas Proc QWTB Load Result Spectra.vi"/>
				</Item>
				<Item Name="Meas Process Config.ctl" Type="VI" URL="../measure/processing/Meas Process Config.ctl"/>
				<Item Name="Meas Process Mode.ctl" Type="VI" URL="../measure/processing/Meas Process Mode.ctl"/>
				<Item Name="Meas Process Raw Config.ctl" Type="VI" URL="../measure/processing/Meas Process Raw Config.ctl"/>
				<Item Name="Meas Process Raw Result Mode.ctl" Type="VI" URL="../measure/processing/Meas Process Raw Result Mode.ctl"/>
				<Item Name="Meas Process Time Stamp Mode.ctl" Type="VI" URL="../measure/processing/Meas Process Time Stamp Mode.ctl"/>
				<Item Name="Meas Process Record.vi" Type="VI" URL="../measure/processing/Meas Process Record.vi"/>
				<Item Name="Meas Process Config Panel.vi" Type="VI" URL="../measure/processing/Meas Process Config Panel.vi"/>
			</Item>
			<Item Name="Corrections" Type="Folder">
				<Item Name="utilities" Type="Folder">
					<Item Name="Corr Check Relative Path.vi" Type="VI" URL="../measure/Corrections/utilities/Corr Check Relative Path.vi"/>
				</Item>
				<Item Name="Corr Setup.ctl" Type="VI" URL="../measure/Corrections/Corr Setup.ctl"/>
				<Item Name="Corr Tranducer Item.ctl" Type="VI" URL="../measure/Corrections/Corr Tranducer Item.ctl"/>
				<Item Name="Corr Tranducers Setup.ctl" Type="VI" URL="../measure/Corrections/Corr Tranducers Setup.ctl"/>
				<Item Name="Corr Tranducer ADC Channel.ctl" Type="VI" URL="../measure/Corrections/Corr Tranducer ADC Channel.ctl"/>
				<Item Name="Corr Digitizers.ctl" Type="VI" URL="../measure/Corrections/Corr Digitizers.ctl"/>
				<Item Name="Corr Digitizer Channel.ctl" Type="VI" URL="../measure/Corrections/Corr Digitizer Channel.ctl"/>
				<Item Name="Corr Panel.vi" Type="VI" URL="../measure/Corrections/Corr Panel.vi"/>
				<Item Name="Corr Transducers File Dialog.vi" Type="VI" URL="../measure/Corrections/Corr Transducers File Dialog.vi"/>
				<Item Name="Corr Transducers Reload All.vi" Type="VI" URL="../measure/Corrections/Corr Transducers Reload All.vi"/>
				<Item Name="Corr Transducers Build Meas Paths.vi" Type="VI" URL="../measure/Corrections/Corr Transducers Build Meas Paths.vi"/>
				<Item Name="Corr Transducers To Meas Folder.vi" Type="VI" URL="../measure/Corrections/Corr Transducers To Meas Folder.vi"/>
				<Item Name="Corr Transducers to Meas Header.vi" Type="VI" URL="../measure/Corrections/Corr Transducers to Meas Header.vi"/>
				<Item Name="Corr Transducers Fill ADC Channel Lists.vi" Type="VI" URL="../measure/Corrections/Corr Transducers Fill ADC Channel Lists.vi"/>
				<Item Name="Corr Digitizer Open.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer Open.vi"/>
				<Item Name="Corr Digitizer Reload.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer Reload.vi"/>
				<Item Name="Corr Digitizer Check.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer Check.vi"/>
				<Item Name="Corr Digitizer to Meas Header.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer to Meas Header.vi"/>
				<Item Name="Corr Digitizer to Meas Folder.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer to Meas Folder.vi"/>
				<Item Name="Corr CSV Editor.vi" Type="VI" URL="../measure/Corrections/Corr CSV Editor.vi"/>
				<Item Name="Corr CSV Template.ctl" Type="VI" URL="../measure/Corrections/Corr CSV Template.ctl"/>
				<Item Name="Corr Digitizer INFO parameter.ctl" Type="VI" URL="../measure/Corrections/Corr Digitizer INFO parameter.ctl"/>
				<Item Name="Corr Digitizer INFO item.ctl" Type="VI" URL="../measure/Corrections/Corr Digitizer INFO item.ctl"/>
				<Item Name="Corr Digitizer INFO.ctl" Type="VI" URL="../measure/Corrections/Corr Digitizer INFO.ctl"/>
				<Item Name="Corr Digitizer Parameter Selector.ctl" Type="VI" URL="../measure/Corrections/Corr Digitizer Parameter Selector.ctl"/>
				<Item Name="Corr Digitizer Type.ctl" Type="VI" URL="../measure/Corrections/Corr Digitizer Type.ctl"/>
				<Item Name="Corr Transducer INFO Item.ctl" Type="VI" URL="../measure/Corrections/Corr Transducer INFO Item.ctl"/>
				<Item Name="Corr Transducer INFO Record.ctl" Type="VI" URL="../measure/Corrections/Corr Transducer INFO Record.ctl"/>
				<Item Name="Corr Digitizer Edit Panel.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer Edit Panel.vi"/>
				<Item Name="Corr Digitizer Load INFO.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer Load INFO.vi"/>
				<Item Name="Corr Digitizer Save INFO.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer Save INFO.vi"/>
				<Item Name="Corr Digitizer Save INFO raw.vi" Type="VI" URL="../measure/Corrections/Corr Digitizer Save INFO raw.vi"/>
				<Item Name="Corr Transducers Edit Panel.vi" Type="VI" URL="../measure/Corrections/Corr Transducers Edit Panel.vi"/>
				<Item Name="Corr Find Relative Pth.vi" Type="VI" URL="../measure/Corrections/Corr Find Relative Pth.vi"/>
				<Item Name="Corr Transducers Load INFO.vi" Type="VI" URL="../measure/Corrections/Corr Transducers Load INFO.vi"/>
				<Item Name="Corr Transducers Save INFO.vi" Type="VI" URL="../measure/Corrections/Corr Transducers Save INFO.vi"/>
			</Item>
			<Item Name="Assist" Type="Folder">
				<Item Name="Assist Sampling Setup.ctl" Type="VI" URL="../measure/Assist/Assist Sampling Setup.ctl"/>
				<Item Name="Assist Coherent Sampling Finder Setup.ctl" Type="VI" URL="../measure/Assist/Assist Coherent Sampling Finder Setup.ctl"/>
				<Item Name="Assist Panel Setup.ctl" Type="VI" URL="../measure/Assist/Assist Panel Setup.ctl"/>
				<Item Name="Assist Sampling Setup Panel.vi" Type="VI" URL="../measure/Assist/Assist Sampling Setup Panel.vi"/>
				<Item Name="Assist Sampling Setup Calculate Coherent.vi" Type="VI" URL="../measure/Assist/Assist Sampling Setup Calculate Coherent.vi"/>
				<Item Name="Assist Sampling Measure Freq Panel.vi" Type="VI" URL="../measure/Assist/Assist Sampling Measure Freq Panel.vi"/>
			</Item>
			<Item Name="Meas Sequence Configuration.ctl" Type="VI" URL="../measure/Meas Sequence Configuration.ctl"/>
			<Item Name="Meas Session.ctl" Type="VI" URL="../measure/Meas Session.ctl"/>
			<Item Name="Meas Sampling Configuration.ctl" Type="VI" URL="../measure/Meas Sampling Configuration.ctl"/>
			<Item Name="Meas Sampling Rate Mode.ctl" Type="VI" URL="../measure/Meas Sampling Rate Mode.ctl"/>
			<Item Name="Meas Range Mode.ctl" Type="VI" URL="../measure/Meas Range Mode.ctl"/>
			<Item Name="Meas Config Panel.vi" Type="VI" URL="../measure/Meas Config Panel.vi"/>
			<Item Name="Meas Asynchronous Start.vi" Type="VI" URL="../measure/Meas Asynchronous Start.vi"/>
			<Item Name="Meas Asynchronous Wait.vi" Type="VI" URL="../measure/Meas Asynchronous Wait.vi"/>
			<Item Name="Meas Main.vi" Type="VI" URL="../measure/Meas Main.vi"/>
			<Item Name="Meas Sequence Loop.vi" Type="VI" URL="../measure/Meas Sequence Loop.vi"/>
			<Item Name="Meas Single Record.vi" Type="VI" URL="../measure/Meas Single Record.vi"/>
		</Item>
		<Item Name="other" Type="Folder">
			<Item Name="GUI Panel Control Action.ctl" Type="VI" URL="../other/GUI Panel Control Action.ctl"/>
			<Item Name="randn_approximation.vi" Type="VI" URL="../other/randn_approximation.vi"/>
			<Item Name="GUI Panel Control.vi" Type="VI" URL="../other/GUI Panel Control.vi"/>
			<Item Name="Get Root Path.vi" Type="VI" URL="../other/Get Root Path.vi"/>
			<Item Name="get_exe_path.vi" Type="VI" URL="../other/get_exe_path.vi"/>
			<Item Name="Merge Error Ex.vi" Type="VI" URL="../other/Merge Error Ex.vi"/>
			<Item Name="About Dialog.vi" Type="VI" URL="../other/About Dialog.vi"/>
			<Item Name="graph_redef_bounds.vi" Type="VI" URL="../other/graph_redef_bounds.vi"/>
			<Item Name="String Is Numeric.vi" Type="VI" URL="../other/String Is Numeric.vi"/>
			<Item Name="String Matrix Is Numeric.vi" Type="VI" URL="../other/String Matrix Is Numeric.vi"/>
			<Item Name="String Array Replace Local Decimal Separators 1D.vi" Type="VI" URL="../other/String Array Replace Local Decimal Separators 1D.vi"/>
			<Item Name="String Array Replace Local Decimal Separators 2D.vi" Type="VI" URL="../other/String Array Replace Local Decimal Separators 2D.vi"/>
			<Item Name="Table Copy To Clipboard.vi" Type="VI" URL="../other/Table Copy To Clipboard.vi"/>
			<Item Name="Table Trim Whites.vi" Type="VI" URL="../other/Table Trim Whites.vi"/>
			<Item Name="Table Paste Clipboard.vi" Type="VI" URL="../other/Table Paste Clipboard.vi"/>
			<Item Name="rowcol2xlscell.vi" Type="VI" URL="../other/rowcol2xlscell.vi"/>
			<Item Name="Text Viewer.vi" Type="VI" URL="../other/Text Viewer.vi"/>
			<Item Name="Dir Folder With Attributes.vi" Type="VI" URL="../other/Dir Folder With Attributes.vi"/>
		</Item>
		<Item Name="ini" Type="Folder">
			<Item Name="ini_auto" Type="Folder">
				<Item Name="ini_object_load.vi" Type="VI" URL="../ini/ini_auto/ini_object_load.vi"/>
				<Item Name="ini_object_load_vector.vi" Type="VI" URL="../ini/ini_auto/ini_object_load_vector.vi"/>
				<Item Name="ini_object_parse_array.vi" Type="VI" URL="../ini/ini_auto/ini_object_parse_array.vi"/>
				<Item Name="ini_object_parse_string_array.vi" Type="VI" URL="../ini/ini_auto/ini_object_parse_string_array.vi"/>
				<Item Name="ini_object_save.vi" Type="VI" URL="../ini/ini_auto/ini_object_save.vi"/>
				<Item Name="ini_object_save_vector.vi" Type="VI" URL="../ini/ini_auto/ini_object_save_vector.vi"/>
				<Item Name="ini_objects_parse.vi" Type="VI" URL="../ini/ini_auto/ini_objects_parse.vi"/>
				<Item Name="ini_parse_row.ctl" Type="VI" URL="../ini/ini_auto/ini_parse_row.ctl"/>
				<Item Name="ini_build_objects_list_recoursive.vi" Type="VI" URL="../ini/ini_auto/ini_build_objects_list_recoursive.vi"/>
				<Item Name="ini_build_objects_list.vi" Type="VI" URL="../ini/ini_auto/ini_build_objects_list.vi"/>
			</Item>
			<Item Name="ini_low_level" Type="Folder">
				<Item Name="ini_read_bool.vi" Type="VI" URL="../ini/ini_low_level/ini_read_bool.vi"/>
				<Item Name="ini_read_common.vi" Type="VI" URL="../ini/ini_low_level/ini_read_common.vi"/>
				<Item Name="ini_read_cplx_double_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_cplx_double_vector.vi"/>
				<Item Name="ini_read_cplx_extended_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_cplx_extended_vector.vi"/>
				<Item Name="ini_read_double.vi" Type="VI" URL="../ini/ini_low_level/ini_read_double.vi"/>
				<Item Name="ini_read_double_multi.vi" Type="VI" URL="../ini/ini_low_level/ini_read_double_multi.vi"/>
				<Item Name="ini_read_double_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_double_vector.vi"/>
				<Item Name="ini_read_extended_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_extended_vector.vi"/>
				<Item Name="ini_read_int32.vi" Type="VI" URL="../ini/ini_low_level/ini_read_int32.vi"/>
				<Item Name="ini_read_int32_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_int32_vector.vi"/>
				<Item Name="ini_read_int32s_multi.vi" Type="VI" URL="../ini/ini_low_level/ini_read_int32s_multi.vi"/>
				<Item Name="ini_read_int64_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_int64_vector.vi"/>
				<Item Name="ini_read_path.vi" Type="VI" URL="../ini/ini_low_level/ini_read_path.vi"/>
				<Item Name="ini_read_string.vi" Type="VI" URL="../ini/ini_low_level/ini_read_string.vi"/>
				<Item Name="ini_read_string_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_string_vector.vi"/>
				<Item Name="ini_read_strings_multi.vi" Type="VI" URL="../ini/ini_low_level/ini_read_strings_multi.vi"/>
				<Item Name="ini_read_uint32.vi" Type="VI" URL="../ini/ini_low_level/ini_read_uint32.vi"/>
				<Item Name="ini_read_uint64_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_read_uint64_vector.vi"/>
				<Item Name="ini_read_variant.vi" Type="VI" URL="../ini/ini_low_level/ini_read_variant.vi"/>
				<Item Name="ini_save_cplx_double_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_save_cplx_double_vector.vi"/>
				<Item Name="ini_save_cplx_extended_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_save_cplx_extended_vector.vi"/>
				<Item Name="ini_save_double.vi" Type="VI" URL="../ini/ini_low_level/ini_save_double.vi"/>
				<Item Name="ini_save_double_multi.vi" Type="VI" URL="../ini/ini_low_level/ini_save_double_multi.vi"/>
				<Item Name="ini_save_double_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_save_double_vector.vi"/>
				<Item Name="ini_save_extended.vi" Type="VI" URL="../ini/ini_low_level/ini_save_extended.vi"/>
				<Item Name="ini_save_extended_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_save_extended_vector.vi"/>
				<Item Name="ini_save_int32_multi.vi" Type="VI" URL="../ini/ini_low_level/ini_save_int32_multi.vi"/>
				<Item Name="ini_save_int64_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_save_int64_vector.vi"/>
				<Item Name="ini_save_string_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_save_string_vector.vi"/>
				<Item Name="ini_save_strings_multi.vi" Type="VI" URL="../ini/ini_low_level/ini_save_strings_multi.vi"/>
				<Item Name="ini_save_uint64_vector.vi" Type="VI" URL="../ini/ini_low_level/ini_save_uint64_vector.vi"/>
				<Item Name="ini_save_variant.vi" Type="VI" URL="../ini/ini_low_level/ini_save_variant.vi"/>
			</Item>
			<Item Name="ini_load.vi" Type="VI" URL="../ini/ini_load.vi"/>
			<Item Name="ini_save.vi" Type="VI" URL="../ini/ini_save.vi"/>
			<Item Name="ini_load_variables.vi" Type="VI" URL="../ini/ini_load_variables.vi"/>
			<Item Name="ini_save_variables.vi" Type="VI" URL="../ini/ini_save_variables.vi"/>
		</Item>
		<Item Name="data" Type="Folder">
			<Item Name="corrections" Type="Folder">
				<Item Name="digitizer" Type="Folder">
					<Item Name="HP3458A_session" Type="Folder">
						<Item Name="chn1" Type="Folder">
							<Item Name="csv" Type="Folder">
								<Item Name="Y_inp.csv" Type="Document" URL="../../data/corrections/digitizer/HP3458A_session/chn1/csv/Y_inp.csv"/>
							</Item>
							<Item Name="HP3458A_chn1.info" Type="Document" URL="../../data/corrections/digitizer/HP3458A_session/chn1/HP3458A_chn1.info"/>
						</Item>
						<Item Name="chn2" Type="Folder">
							<Item Name="csv" Type="Folder">
								<Item Name="Y_inp.csv" Type="Document" URL="../../data/corrections/digitizer/HP3458A_session/chn2/csv/Y_inp.csv"/>
							</Item>
							<Item Name="HP3458A_chn2.info" Type="Document" URL="../../data/corrections/digitizer/HP3458A_session/chn2/HP3458A_chn2.info"/>
						</Item>
						<Item Name="HP3458A_2x.info" Type="Document" URL="../../data/corrections/digitizer/HP3458A_session/HP3458A_2x.info"/>
						<Item Name="read_me.txt" Type="Document" URL="../../data/corrections/digitizer/HP3458A_session/read_me.txt"/>
					</Item>
					<Item Name="PXI5922_test" Type="Folder">
						<Item Name="chn1" Type="Folder">
							<Item Name="csv" Type="Folder">
								<Item Name="SFDR_5V.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn1/csv/SFDR_5V.csv"/>
								<Item Name="tfer_gain_10M.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn1/csv/tfer_gain_10M.csv"/>
								<Item Name="tfer_gain_1M.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn1/csv/tfer_gain_1M.csv"/>
								<Item Name="tfer_gain_500k.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn1/csv/tfer_gain_500k.csv"/>
								<Item Name="tfer_gain_50k.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn1/csv/tfer_gain_50k.csv"/>
								<Item Name="Y_inp.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn1/csv/Y_inp.csv"/>
							</Item>
							<Item Name="NI5922_chn1.info" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn1/NI5922_chn1.info"/>
						</Item>
						<Item Name="chn2" Type="Folder">
							<Item Name="csv" Type="Folder">
								<Item Name="SFDR_5V.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/SFDR_5V.csv"/>
								<Item Name="tfer_gain_10M.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_gain_10M.csv"/>
								<Item Name="tfer_gain_1M.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_gain_1M.csv"/>
								<Item Name="tfer_gain_500k.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_gain_500k.csv"/>
								<Item Name="tfer_gain_50k.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_gain_50k.csv"/>
								<Item Name="tfer_phi_10M.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_phi_10M.csv"/>
								<Item Name="tfer_phi_1M.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_phi_1M.csv"/>
								<Item Name="tfer_phi_500k.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_phi_500k.csv"/>
								<Item Name="tfer_phi_50k.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/tfer_phi_50k.csv"/>
								<Item Name="Y_inp.csv" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/csv/Y_inp.csv"/>
							</Item>
							<Item Name="NI5922_chn2.info" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/chn2/NI5922_chn2.info"/>
						</Item>
						<Item Name="NI5922_2x.info" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/NI5922_2x.info"/>
						<Item Name="read_me.txt" Type="Document" URL="../../data/corrections/digitizer/PXI5922_test/read_me.txt"/>
					</Item>
				</Item>
				<Item Name="transducers" Type="Folder">
					<Item Name="dummy.cs" Type="Folder">
						<Item Name="dummy.info" Type="Document" URL="../../data/corrections/transducers/dummy.cs/dummy.info"/>
					</Item>
					<Item Name="dummy.vd" Type="Folder">
						<Item Name="csv" Type="Folder">
							<Item Name="Z_low.csv" Type="Document" URL="../../data/corrections/transducers/dummy.vd/csv/Z_low.csv"/>
						</Item>
						<Item Name="dummy.info" Type="Document" URL="../../data/corrections/transducers/dummy.vd/dummy.info"/>
					</Item>
					<Item Name="shunt_1A313" Type="Folder">
						<Item Name="shunt_1A313.info" Type="Document" URL="../../data/corrections/transducers/shunt_1A313/shunt_1A313.info"/>
					</Item>
					<Item Name="shunt_100mA113" Type="Folder">
						<Item Name="csv" Type="Folder">
							<Item Name="tfer_gain.csv" Type="Document" URL="../../data/corrections/transducers/shunt_100mA113/csv/tfer_gain.csv"/>
							<Item Name="Zca.csv" Type="Document" URL="../../data/corrections/transducers/shunt_100mA113/csv/Zca.csv"/>
							<Item Name="Zcal.csv" Type="Document" URL="../../data/corrections/transducers/shunt_100mA113/csv/Zcal.csv"/>
						</Item>
						<Item Name="shunt_100mA113.info" Type="Document" URL="../../data/corrections/transducers/shunt_100mA113/shunt_100mA113.info"/>
					</Item>
					<Item Name="SP0401-4V" Type="Folder">
						<Item Name="csv" Type="Folder">
							<Item Name="Z_low.csv" Type="Document" URL="../../data/corrections/transducers/SP0401-4V/csv/Z_low.csv"/>
						</Item>
						<Item Name="SP4V.info" Type="Document" URL="../../data/corrections/transducers/SP0401-4V/SP4V.info"/>
					</Item>
					<Item Name="SP0404-56V" Type="Folder">
						<Item Name="csv" Type="Folder">
							<Item Name="Z_low.csv" Type="Document" URL="../../data/corrections/transducers/SP0404-56V/csv/Z_low.csv"/>
						</Item>
						<Item Name="SP56V.info" Type="Document" URL="../../data/corrections/transducers/SP0404-56V/SP56V.info"/>
					</Item>
				</Item>
			</Item>
			<Item Name="readme.txt" Type="Document" URL="../../data/readme.txt"/>
		</Item>
		<Item Name="server" Type="Folder">
			<Item Name="WinAPI32" Type="Folder">
				<Item Name="demo" Type="Folder">
					<Item Name="test4.vi" Type="VI" URL="../server/WinAPI32/demo/test4.vi"/>
				</Item>
				<Item Name="high level" Type="Folder">
					<Item Name="wa32 Read Till Key.vi" Type="VI" URL="../server/WinAPI32/high level/wa32 Read Till Key.vi"/>
					<Item Name="wa32 Flush Read.vi" Type="VI" URL="../server/WinAPI32/high level/wa32 Flush Read.vi"/>
				</Item>
				<Item Name="read_me.txt" Type="Document" URL="../server/WinAPI32/read_me.txt"/>
				<Item Name="wa32 CloseHandle.vi" Type="VI" URL="../server/WinAPI32/wa32 CloseHandle.vi"/>
				<Item Name="wa32 CreateFileA.vi" Type="VI" URL="../server/WinAPI32/wa32 CreateFileA.vi"/>
				<Item Name="wa32 CreateNamedPipeA.vi" Type="VI" URL="../server/WinAPI32/wa32 CreateNamedPipeA.vi"/>
				<Item Name="wa32 GetNamedPipeHandleStatus.vi" Type="VI" URL="../server/WinAPI32/wa32 GetNamedPipeHandleStatus.vi"/>
				<Item Name="wa32 WaitNamedPipeA.vi" Type="VI" URL="../server/WinAPI32/wa32 WaitNamedPipeA.vi"/>
				<Item Name="wa32 ConnectNamedPipe.vi" Type="VI" URL="../server/WinAPI32/wa32 ConnectNamedPipe.vi"/>
				<Item Name="wa32 GetLastError.vi" Type="VI" URL="../server/WinAPI32/wa32 GetLastError.vi"/>
				<Item Name="wa32 PeekNamedPipe.vi" Type="VI" URL="../server/WinAPI32/wa32 PeekNamedPipe.vi"/>
				<Item Name="wa32 ReadFile.vi" Type="VI" URL="../server/WinAPI32/wa32 ReadFile.vi"/>
				<Item Name="wa32 WriteFile.vi" Type="VI" URL="../server/WinAPI32/wa32 WriteFile.vi"/>
			</Item>
			<Item Name="TWM server" Type="Folder">
				<Item Name="Server Cmd Parser - Set Measurement.vi" Type="VI" URL="../server/TWM server/Server Cmd Parser - Set Measurement.vi"/>
				<Item Name="Server Cmd Parser - Set Corrections.vi" Type="VI" URL="../server/TWM server/Server Cmd Parser - Set Corrections.vi"/>
				<Item Name="Server Cmd Answer - Get Status.vi" Type="VI" URL="../server/TWM server/Server Cmd Answer - Get Status.vi"/>
				<Item Name="Server Cmd Answer - Get Result.vi" Type="VI" URL="../server/TWM server/Server Cmd Answer - Get Result.vi"/>
				<Item Name="Server Cmd Answer - Get Algorithm Info.vi" Type="VI" URL="../server/TWM server/Server Cmd Answer - Get Algorithm Info.vi"/>
				<Item Name="Server Cmd Answer - Identify.vi" Type="VI" URL="../server/TWM server/Server Cmd Answer - Identify.vi"/>
			</Item>
			<Item Name="TWM Client.lvlib" Type="Library" URL="../server/TWM client/TWM Client.lvlib"/>
			<Item Name="Server Event.ctl" Type="VI" URL="../server/Server Event.ctl"/>
			<Item Name="Server Client Request.ctl" Type="VI" URL="../server/Server Client Request.ctl"/>
			<Item Name="Server Event Command.ctl" Type="VI" URL="../server/Server Event Command.ctl"/>
			<Item Name="Server Event GUI command.ctl" Type="VI" URL="../server/Server Event GUI command.ctl"/>
			<Item Name="Server Event Ref.ctl" Type="VI" URL="../server/Server Event Ref.ctl"/>
			<Item Name="Server Session.ctl" Type="VI" URL="../server/Server Session.ctl"/>
			<Item Name="Server Session Reference.ctl" Type="VI" URL="../server/Server Session Reference.ctl"/>
			<Item Name="Server Event Answer Ref.ctl" Type="VI" URL="../server/Server Event Answer Ref.ctl"/>
			<Item Name="Server Create Command Event.vi" Type="VI" URL="../server/Server Create Command Event.vi"/>
			<Item Name="Server Create Response Event.vi" Type="VI" URL="../server/Server Create Response Event.vi"/>
			<Item Name="Server Generate ACK Event.vi" Type="VI" URL="../server/Server Generate ACK Event.vi"/>
			<Item Name="Server Generate Answer Event.vi" Type="VI" URL="../server/Server Generate Answer Event.vi"/>
			<Item Name="Server Generate Command Event.vi" Type="VI" URL="../server/Server Generate Command Event.vi"/>
			<Item Name="Server Parse Commands.vi" Type="VI" URL="../server/Server Parse Commands.vi"/>
			<Item Name="Server Log Stuff.vi" Type="VI" URL="../server/Server Log Stuff.vi"/>
			<Item Name="Server Log Panel.vi" Type="VI" URL="../server/Server Log Panel.vi"/>
			<Item Name="Server Panel.vi" Type="VI" URL="../server/Server Panel.vi"/>
		</Item>
		<Item Name="doc" Type="Folder" URL="../../doc">
			<Property Name="NI.DISK" Type="Bool">true</Property>
		</Item>
		<Item Name="build" Type="Folder">
			<Item Name="Post-Build Action.vi" Type="VI" URL="../build/Post-Build Action.vi"/>
			<Item Name="Set Conditional Symbols.vi" Type="VI" URL="../build/Set Conditional Symbols.vi"/>
			<Item Name="Pre-Build Action - visa,niscope,daqmx.vi" Type="VI" URL="../build/Pre-Build Action - visa,niscope,daqmx.vi"/>
			<Item Name="Pre-Build Action - visa,niscope.vi" Type="VI" URL="../build/Pre-Build Action - visa,niscope.vi"/>
			<Item Name="Pre-Build Action - visa.vi" Type="VI" URL="../build/Pre-Build Action - visa.vi"/>
			<Item Name="Copy octprog.vi" Type="VI" URL="../build/Copy octprog.vi"/>
			<Item Name="Merge Builds.vi" Type="VI" URL="../build/Merge Builds.vi"/>
		</Item>
		<Item Name="Excel" Type="Folder">
			<Item Name="AX Excel.lvlibp" Type="LVLibp" URL="../Excel/AX Excel.lvlibp">
				<Item Name="advanced" Type="Folder">
					<Item Name="axex_is_workbook_opened.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/advanced/axex_is_workbook_opened.vi"/>
					<Item Name="axex_get_list_of_workbooks.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/advanced/axex_get_list_of_workbooks.vi"/>
					<Item Name="axex_get_sheet_ref.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/advanced/axex_get_sheet_ref.vi"/>
					<Item Name="axex_get_workbook.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/advanced/axex_get_workbook.vi"/>
				</Item>
				<Item Name="other" Type="Folder">
					<Item Name="axex_cell_xy_to_name.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/other/axex_cell_xy_to_name.vi"/>
				</Item>
				<Item Name="file" Type="Folder">
					<Item Name="axex_open_file.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/file/axex_open_file.vi"/>
					<Item Name="axex_close_file.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/file/axex_close_file.vi"/>
					<Item Name="axex_close_file_office16.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/file/axex_close_file_office16.vi"/>
					<Item Name="axex_save_file.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/file/axex_save_file.vi"/>
					<Item Name="axex_save_file_office16.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/file/axex_save_file_office16.vi"/>
				</Item>
				<Item Name="sheet" Type="Folder">
					<Item Name="axex_get_sheet_names.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_get_sheet_names.vi"/>
					<Item Name="axex_get_sheet_range.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_get_sheet_range.vi"/>
					<Item Name="axex_select_sheet.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_select_sheet.vi"/>
					<Item Name="axex_sheet_exist.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_sheet_exist.vi"/>
					<Item Name="axex_create_sheet.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_create_sheet.vi"/>
					<Item Name="axex_copy_sheet.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_copy_sheet.vi"/>
					<Item Name="axex_delete_sheet.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_delete_sheet.vi"/>
					<Item Name="axex_rename_sheet.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/sheet/axex_rename_sheet.vi"/>
				</Item>
				<Item Name="data" Type="Folder">
					<Item Name="axex_read.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_read.vi"/>
					<Item Name="axex_write.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_write.vi"/>
				</Item>
				<Item Name="types" Type="Folder">
					<Item Name="axex_instance.ctl" Type="VI" URL="../Excel/AX Excel.lvlibp/axex_instance.ctl"/>
					<Item Name="axex_window_state.ctl" Type="VI" URL="../Excel/AX Excel.lvlibp/axex_window_state.ctl"/>
					<Item Name="axex_cell_xy.ctl" Type="VI" URL="../Excel/AX Excel.lvlibp/axex_cell_xy.ctl"/>
				</Item>
				<Item Name="private" Type="Folder">
					<Item Name="axex_read_cell.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_read_cell.vi"/>
					<Item Name="axex_read_cells.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_read_cells.vi"/>
					<Item Name="axex_read_cells_vector.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_read_cells_vector.vi"/>
					<Item Name="axex_write_cell.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_write_cell.vi"/>
					<Item Name="axex_write_cells.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_write_cells.vi"/>
					<Item Name="axex_write_cells_vector.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/data/axex_write_cells_vector.vi"/>
					<Item Name="axex_get_list_of_workbooks_proc.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/advanced/axex_get_list_of_workbooks_proc.vi"/>
				</Item>
				<Item Name="axex_vi_tree.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/axex_vi_tree.vi"/>
				<Item Name="axex_test.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/axex_test.vi"/>
				<Item Name="NI_FileType.lvlib" Type="Library" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/Utility/lvfile.llb/NI_FileType.lvlib"/>
				<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
				<Item Name="Clear Errors.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
				<Item Name="Search and Replace Pattern.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/Utility/error.llb/Search and Replace Pattern.vi"/>
				<Item Name="Generate Temporary File Path.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/Utility/libraryn.llb/Generate Temporary File Path.vi"/>
				<Item Name="ex_CorrectErrorChain.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/express/express shared/ex_CorrectErrorChain.vi"/>
				<Item Name="subFile Dialog.vi" Type="VI" URL="../Excel/AX Excel.lvlibp/1abvi3w/vi.lib/express/express input/FileDialogBlock.llb/subFile Dialog.vi"/>
			</Item>
			<Item Name="read_me.txt" Type="Document" URL="../Excel/read_me.txt"/>
		</Item>
		<Item Name="main.vi" Type="VI" URL="../main.vi"/>
		<Item Name="par_test.vi" Type="VI" URL="../par_test.vi"/>
		<Item Name="info_test.vi" Type="VI" URL="../info_test.vi"/>
		<Item Name="config.ini" Type="Document" URL="../config.ini"/>
		<Item Name="LICENSE.txt" Type="Document" URL="../../LICENSE.txt"/>
		<Item Name="readme.txt" Type="Document" URL="../../readme.txt"/>
		<Item Name="icon.ico" Type="Document" URL="../../ico/icon.ico"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Clear Errors.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="NI_AALBase.lvlib" Type="Library" URL="/&lt;vilib&gt;/Analysis/NI_AALBase.lvlib"/>
				<Item Name="subSigGeneratorBlock.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalBlock.llb/subSigGeneratorBlock.vi"/>
				<Item Name="Nearest Frequency for Block.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalConfig.llb/Nearest Frequency for Block.vi"/>
				<Item Name="Nearest Freq in Int Cycles.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalConfig.llb/Nearest Freq in Int Cycles.vi"/>
				<Item Name="ex_CorrectErrorChain.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/ex_CorrectErrorChain.vi"/>
				<Item Name="ex_GenAddAttribs.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalBlock.llb/ex_GenAddAttribs.vi"/>
				<Item Name="ex_WaveformAttribsPlus.ctl" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/ex_WaveformAttribsPlus.ctl"/>
				<Item Name="Waveform Array To Dynamic.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/Waveform Array To Dynamic.vi"/>
				<Item Name="ex_SetExpAttribsAndT0.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/ex_SetExpAttribsAndT0.vi"/>
				<Item Name="ex_WaveformAttribs.ctl" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/ex_WaveformAttribs.ctl"/>
				<Item Name="ex_SetAllExpressAttribs.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/ex_SetAllExpressAttribs.vi"/>
				<Item Name="Timestamp Add.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/Timestamp Add.vi"/>
				<Item Name="I128 Timestamp.ctl" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/I128 Timestamp.ctl"/>
				<Item Name="DU64_U32AddWithOverflow.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/DU64_U32AddWithOverflow.vi"/>
				<Item Name="Timestamp Subtract.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/Timestamp Subtract.vi"/>
				<Item Name="DU64_U32SubtractWithBorrow.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/DU64_U32SubtractWithBorrow.vi"/>
				<Item Name="subInternalTiming.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalBlock.llb/subInternalTiming.vi"/>
				<Item Name="NI_MABase.lvlib" Type="Library" URL="/&lt;vilib&gt;/measure/NI_MABase.lvlib"/>
				<Item Name="subShouldUseDefSigName.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalBlock.llb/subShouldUseDefSigName.vi"/>
				<Item Name="sub2ShouldUseDefSigName.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalBlock.llb/sub2ShouldUseDefSigName.vi"/>
				<Item Name="subGetSignalName.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/SimulateSignalBlock.llb/subGetSignalName.vi"/>
				<Item Name="Dynamic To Waveform Array.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/Dynamic To Waveform Array.vi"/>
				<Item Name="Simple Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Simple Error Handler.vi"/>
				<Item Name="DialogType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogType.ctl"/>
				<Item Name="General Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler.vi"/>
				<Item Name="DialogTypeEnum.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogTypeEnum.ctl"/>
				<Item Name="General Error Handler CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler CORE.vi"/>
				<Item Name="Check Special Tags.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Check Special Tags.vi"/>
				<Item Name="TagReturnType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/TagReturnType.ctl"/>
				<Item Name="Set String Value.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set String Value.vi"/>
				<Item Name="GetRTHostConnectedProp.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetRTHostConnectedProp.vi"/>
				<Item Name="Error Code Database.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Code Database.vi"/>
				<Item Name="Format Message String.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Format Message String.vi"/>
				<Item Name="Find Tag.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Find Tag.vi"/>
				<Item Name="Search and Replace Pattern.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Search and Replace Pattern.vi"/>
				<Item Name="Set Bold Text.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set Bold Text.vi"/>
				<Item Name="Details Display Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Details Display Dialog.vi"/>
				<Item Name="ErrWarn.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/ErrWarn.ctl"/>
				<Item Name="eventvkey.ctl" Type="VI" URL="/&lt;vilib&gt;/event_ctls.llb/eventvkey.ctl"/>
				<Item Name="Not Found Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Not Found Dialog.vi"/>
				<Item Name="Three Button Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog.vi"/>
				<Item Name="Three Button Dialog CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog CORE.vi"/>
				<Item Name="Longest Line Length in Pixels.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Longest Line Length in Pixels.vi"/>
				<Item Name="Convert property node font to graphics font.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Convert property node font to graphics font.vi"/>
				<Item Name="Get Text Rect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/Get Text Rect.vi"/>
				<Item Name="Get String Text Bounds.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Get String Text Bounds.vi"/>
				<Item Name="LVBoundsTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVBoundsTypeDef.ctl"/>
				<Item Name="BuildHelpPath.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/BuildHelpPath.vi"/>
				<Item Name="GetHelpDir.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetHelpDir.vi"/>
				<Item Name="Select Event Type.ctl" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/Select Event Type.ctl"/>
				<Item Name="VISA GPIB Control REN Mode.ctl" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA GPIB Control REN Mode.ctl"/>
				<Item Name="Trim Whitespace.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Trim Whitespace.vi"/>
				<Item Name="whitespace.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/whitespace.ctl"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="Open_Create_Replace File.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/Open_Create_Replace File.vi"/>
				<Item Name="compatFileDialog.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatFileDialog.vi"/>
				<Item Name="compatOpenFileOperation.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatOpenFileOperation.vi"/>
				<Item Name="compatCalcOffset.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatCalcOffset.vi"/>
				<Item Name="LVSelectionTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVSelectionTypeDef.ctl"/>
				<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
				<Item Name="NI_FileType.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/lvfile.llb/NI_FileType.lvlib"/>
				<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
				<Item Name="Write To Spreadsheet File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File.vi"/>
				<Item Name="Write To Spreadsheet File (DBL).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (DBL).vi"/>
				<Item Name="Write Spreadsheet String.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write Spreadsheet String.vi"/>
				<Item Name="Write To Spreadsheet File (I64).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (I64).vi"/>
				<Item Name="Write To Spreadsheet File (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (string).vi"/>
				<Item Name="FileVersionInfo.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/FileVersionInfo.vi"/>
				<Item Name="FileVersionInformation.ctl" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/FileVersionInformation.ctl"/>
				<Item Name="GetFileVersionInfoSize.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/GetFileVersionInfoSize.vi"/>
				<Item Name="BuildErrorSource.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/BuildErrorSource.vi"/>
				<Item Name="GetFileVersionInfo.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/GetFileVersionInfo.vi"/>
				<Item Name="VerQueryValue.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/VerQueryValue.vi"/>
				<Item Name="MoveMemory.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/MoveMemory.vi"/>
				<Item Name="FixedFileInfo_Struct.ctl" Type="VI" URL="/&lt;vilib&gt;/Platform/fileVersionInfo.llb/FixedFileInfo_Struct.ctl"/>
				<Item Name="NI_Matrix.lvlib" Type="Library" URL="/&lt;vilib&gt;/Analysis/Matrix/NI_Matrix.lvlib"/>
				<Item Name="NI_report.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Utility/NIReport.llb/NI_report.lvclass"/>
				<Item Name="NI_ReportGenerationCore.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/NIReport.llb/NI_ReportGenerationCore.lvlib"/>
				<Item Name="NI_HTML.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Utility/NIReport.llb/HTML/NI_HTML.lvclass"/>
				<Item Name="Write JPEG File.vi" Type="VI" URL="/&lt;vilib&gt;/picture/jpeg.llb/Write JPEG File.vi"/>
				<Item Name="imagedata.ctl" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/imagedata.ctl"/>
				<Item Name="Check Data Size.vi" Type="VI" URL="/&lt;vilib&gt;/picture/jpeg.llb/Check Data Size.vi"/>
				<Item Name="Check Color Table Size.vi" Type="VI" URL="/&lt;vilib&gt;/picture/jpeg.llb/Check Color Table Size.vi"/>
				<Item Name="Check Path.vi" Type="VI" URL="/&lt;vilib&gt;/picture/jpeg.llb/Check Path.vi"/>
				<Item Name="Directory of Top Level VI.vi" Type="VI" URL="/&lt;vilib&gt;/picture/jpeg.llb/Directory of Top Level VI.vi"/>
				<Item Name="Check File Permissions.vi" Type="VI" URL="/&lt;vilib&gt;/picture/jpeg.llb/Check File Permissions.vi"/>
				<Item Name="Write PNG File.vi" Type="VI" URL="/&lt;vilib&gt;/picture/png.llb/Write PNG File.vi"/>
				<Item Name="Registry RtKey.ctl" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Registry RtKey.ctl"/>
				<Item Name="Generate Temporary File Path.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Generate Temporary File Path.vi"/>
				<Item Name="Path to URL.vi" Type="VI" URL="/&lt;vilib&gt;/printing/PathToURL.llb/Path to URL.vi"/>
				<Item Name="Escape Characters for HTTP.vi" Type="VI" URL="/&lt;vilib&gt;/printing/PathToURL.llb/Escape Characters for HTTP.vi"/>
				<Item Name="Open Registry Key.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Open Registry Key.vi"/>
				<Item Name="Registry SAM.ctl" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Registry SAM.ctl"/>
				<Item Name="Registry refnum.ctl" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Registry refnum.ctl"/>
				<Item Name="Registry View.ctl" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Registry View.ctl"/>
				<Item Name="Registry WinErr-LVErr.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Registry WinErr-LVErr.vi"/>
				<Item Name="STR_ASCII-Unicode.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/STR_ASCII-Unicode.vi"/>
				<Item Name="Registry Handle Master.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Registry Handle Master.vi"/>
				<Item Name="Read Registry Value Simple.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Read Registry Value Simple.vi"/>
				<Item Name="Read Registry Value Simple STR.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Read Registry Value Simple STR.vi"/>
				<Item Name="Read Registry Value.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Read Registry Value.vi"/>
				<Item Name="Read Registry Value STR.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Read Registry Value STR.vi"/>
				<Item Name="Read Registry Value DWORD.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Read Registry Value DWORD.vi"/>
				<Item Name="Registry Simplify Data Type.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Registry Simplify Data Type.vi"/>
				<Item Name="Read Registry Value Simple U32.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Read Registry Value Simple U32.vi"/>
				<Item Name="Close Registry Key.vi" Type="VI" URL="/&lt;vilib&gt;/registry/registry.llb/Close Registry Key.vi"/>
				<Item Name="Create ActiveX Event Queue.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/ax-events.llb/Create ActiveX Event Queue.vi"/>
				<Item Name="Wait types.ctl" Type="VI" URL="/&lt;vilib&gt;/Platform/ax-events.llb/Wait types.ctl"/>
				<Item Name="Create Error Clust.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/ax-events.llb/Create Error Clust.vi"/>
				<Item Name="Wait On ActiveX Event.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/ax-events.llb/Wait On ActiveX Event.vi"/>
				<Item Name="EventData.ctl" Type="VI" URL="/&lt;vilib&gt;/Platform/ax-events.llb/EventData.ctl"/>
				<Item Name="OccFireType.ctl" Type="VI" URL="/&lt;vilib&gt;/Platform/ax-events.llb/OccFireType.ctl"/>
				<Item Name="Destroy ActiveX Event Queue.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/ax-events.llb/Destroy ActiveX Event Queue.vi"/>
				<Item Name="NI_Standard Report.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Utility/NIReport.llb/Standard Report/NI_Standard Report.lvclass"/>
				<Item Name="Read PNG File.vi" Type="VI" URL="/&lt;vilib&gt;/picture/png.llb/Read PNG File.vi"/>
				<Item Name="Create Mask By Alpha.vi" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/Create Mask By Alpha.vi"/>
				<Item Name="Bit-array To Byte-array.vi" Type="VI" URL="/&lt;vilib&gt;/picture/pictutil.llb/Bit-array To Byte-array.vi"/>
				<Item Name="Write BMP File.vi" Type="VI" URL="/&lt;vilib&gt;/picture/bmp.llb/Write BMP File.vi"/>
				<Item Name="compatOverwrite.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatOverwrite.vi"/>
				<Item Name="Write BMP Data.vi" Type="VI" URL="/&lt;vilib&gt;/picture/bmp.llb/Write BMP Data.vi"/>
				<Item Name="Write BMP Data To Buffer.vi" Type="VI" URL="/&lt;vilib&gt;/picture/bmp.llb/Write BMP Data To Buffer.vi"/>
				<Item Name="Calc Long Word Padded Width.vi" Type="VI" URL="/&lt;vilib&gt;/picture/bmp.llb/Calc Long Word Padded Width.vi"/>
				<Item Name="Flip and Pad for Picture Control.vi" Type="VI" URL="/&lt;vilib&gt;/picture/bmp.llb/Flip and Pad for Picture Control.vi"/>
				<Item Name="Color to RGB.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/colorconv.llb/Color to RGB.vi"/>
				<Item Name="Get LV Class Default Value.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/LVClass/Get LV Class Default Value.vi"/>
				<Item Name="Built App File Layout.vi" Type="VI" URL="/&lt;vilib&gt;/AppBuilder/Built App File Layout.vi"/>
				<Item Name="NI_Excel.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Utility/NIReport.llb/Excel/NI_Excel.lvclass"/>
				<Item Name="NI_ReportGenerationToolkit.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/_office/NI_ReportGenerationToolkit.lvlib"/>
				<Item Name="Get File Extension.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Get File Extension.vi"/>
				<Item Name="Read JPEG File.vi" Type="VI" URL="/&lt;vilib&gt;/picture/jpeg.llb/Read JPEG File.vi"/>
				<Item Name="Handle Open Word or Excel File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/NIReport.llb/Toolkit/Handle Open Word or Excel File.vi"/>
				<Item Name="Space Constant.vi" Type="VI" URL="/&lt;vilib&gt;/dlg_ctls.llb/Space Constant.vi"/>
				<Item Name="Get Waveform Time Array.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/Get Waveform Time Array.vi"/>
				<Item Name="WDT Get Waveform Time Array DBL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Get Waveform Time Array DBL.vi"/>
				<Item Name="Number of Waveform Samples.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/Number of Waveform Samples.vi"/>
				<Item Name="WDT Number of Waveform Samples DBL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples DBL.vi"/>
				<Item Name="WDT Number of Waveform Samples CDB.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples CDB.vi"/>
				<Item Name="WDT Number of Waveform Samples EXT.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples EXT.vi"/>
				<Item Name="WDT Number of Waveform Samples I16.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples I16.vi"/>
				<Item Name="WDT Number of Waveform Samples I32.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples I32.vi"/>
				<Item Name="WDT Number of Waveform Samples I8.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples I8.vi"/>
				<Item Name="WDT Number of Waveform Samples SGL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples SGL.vi"/>
				<Item Name="DWDT Get Waveform Time Array.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Get Waveform Time Array.vi"/>
				<Item Name="DWDT Digital Size.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Digital Size.vi"/>
				<Item Name="DTbl Digital Size.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Digital Size.vi"/>
				<Item Name="NI_LVConfig.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/config.llb/NI_LVConfig.lvlib"/>
				<Item Name="8.6CompatibleGlobalVar.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/config.llb/8.6CompatibleGlobalVar.vi"/>
				<Item Name="Application Directory.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Application Directory.vi"/>
				<Item Name="Semaphore RefNum" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Semaphore RefNum"/>
				<Item Name="Acquire Semaphore.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Acquire Semaphore.vi"/>
				<Item Name="Semaphore Refnum Core.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Semaphore Refnum Core.ctl"/>
				<Item Name="Release Semaphore Reference.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Release Semaphore Reference.vi"/>
				<Item Name="RemoveNamedSemaphorePrefix.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/RemoveNamedSemaphorePrefix.vi"/>
				<Item Name="GetNamedSemaphorePrefix.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/GetNamedSemaphorePrefix.vi"/>
				<Item Name="Release Semaphore.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Release Semaphore.vi"/>
				<Item Name="Not A Semaphore.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Not A Semaphore.vi"/>
				<Item Name="Obtain Semaphore Reference.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Obtain Semaphore Reference.vi"/>
				<Item Name="AddNamedSemaphorePrefix.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/AddNamedSemaphorePrefix.vi"/>
				<Item Name="Validate Semaphore Size.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Validate Semaphore Size.vi"/>
				<Item Name="subFile Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/FileDialogBlock.llb/subFile Dialog.vi"/>
				<Item Name="LVStringsAndValuesArrayTypeDef_U16.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVStringsAndValuesArrayTypeDef_U16.ctl"/>
				<Item Name="LVRowAndColumnTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVRowAndColumnTypeDef.ctl"/>
				<Item Name="usereventprio.ctl" Type="VI" URL="/&lt;vilib&gt;/event_ctls.llb/usereventprio.ctl"/>
				<Item Name="LVRowAndColumnUnsignedTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVRowAndColumnUnsignedTypeDef.ctl"/>
				<Item Name="Binary to Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDT.llb/Binary to Digital.vi"/>
				<Item Name="DWDT Binary U32 to Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Binary U32 to Digital.vi"/>
				<Item Name="DTbl Binary U32 to Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Binary U32 to Digital.vi"/>
				<Item Name="Compress Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDT.llb/Compress Digital.vi"/>
				<Item Name="DTbl Compress Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Compress Digital.vi"/>
				<Item Name="DWDT Compress Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Compress Digital.vi"/>
				<Item Name="DWDT Binary U16 to Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Binary U16 to Digital.vi"/>
				<Item Name="DTbl Binary U16 to Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Binary U16 to Digital.vi"/>
				<Item Name="DWDT Binary U8 to Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Binary U8 to Digital.vi"/>
				<Item Name="DTbl Binary U8 to Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Binary U8 to Digital.vi"/>
				<Item Name="TDMSAddBlankElem1d.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tdmsutil.llb/TDMSAddBlankElem1d.vi"/>
				<Item Name="ClearError.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tdmsutil.llb/ClearError.vi"/>
				<Item Name="DAQmx Read.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read.vi"/>
				<Item Name="DAQmx Read (Analog 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Fill In Error Info.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/miscellaneous.llb/DAQmx Fill In Error Info.vi"/>
				<Item Name="DAQmx Read (Analog 1D DBL 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D DBL 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 1D DBL NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D DBL NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog 2D DBL NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D DBL NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog DBL 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog DBL 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog Wfm 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D Bool 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Bool 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U32 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U32 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U8 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U8 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 2D U32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D U32 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 2D U8 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D U8 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital Bool 1Line 1Point).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital Bool 1Line 1Point).vi"/>
				<Item Name="DAQmx Read (Digital Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital Wfm 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Raw 1D I16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D I16).vi"/>
				<Item Name="DAQmx Read (Raw 1D I32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D I32).vi"/>
				<Item Name="DAQmx Read (Raw 1D I8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D I8).vi"/>
				<Item Name="DAQmx Read (Raw 1D U16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D U16).vi"/>
				<Item Name="DAQmx Read (Raw 1D U32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D U32).vi"/>
				<Item Name="DAQmx Read (Raw 1D U8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D U8).vi"/>
				<Item Name="DAQmx Read (Digital 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter 1D DBL 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D DBL 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter DBL 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter DBL 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter U32 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter U32 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter 1D U32 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D U32 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U8 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U8 NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U32 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U32 NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital U8 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital U8 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital U32 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital U32 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D Bool NChan 1Samp 1Line).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Bool NChan 1Samp 1Line).vi"/>
				<Item Name="DAQmx Read (Digital 2D Bool NChan 1Samp NLine).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D Bool NChan 1Samp NLine).vi"/>
				<Item Name="DAQmx Read (Analog 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D I16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D I16 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D I32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D I32 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D U32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D U32 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital U16 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital U16 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U16 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U16 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U16 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U16 NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D Pulse Freq 1 Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D Pulse Freq 1 Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D Pulse Ticks 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D Pulse Ticks 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D Pulse Time 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D Pulse Time 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter Pulse Freq 1 Chan 1 Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter Pulse Freq 1 Chan 1 Samp).vi"/>
				<Item Name="DAQmx Read (Counter Pulse Ticks 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter Pulse Ticks 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter Pulse Time 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter Pulse Time 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Stop Task.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/task.llb/DAQmx Stop Task.vi"/>
				<Item Name="DAQmx Write.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write.vi"/>
				<Item Name="DAQmx Write (Analog 1D DBL 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D DBL 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog 1D DBL NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D DBL NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog 2D DBL NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D DBL NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog DBL 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog DBL 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog Wfm 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 2D U32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D U32 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 2D U8 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D U8 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 1D Bool 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Bool 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U32 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U32 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U8 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U8 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital Bool 1Line 1Point).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital Bool 1Line 1Point).vi"/>
				<Item Name="DAQmx Write (Digital Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital Wfm 1Chan NSamp).vi"/>
				<Item Name="DWDT Uncompress Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Uncompress Digital.vi"/>
				<Item Name="DTbl Uncompress Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Uncompress Digital.vi"/>
				<Item Name="DAQmx Write (Raw 1D I16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D I16).vi"/>
				<Item Name="DAQmx Write (Raw 1D I32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D I32).vi"/>
				<Item Name="DAQmx Write (Raw 1D I8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D I8).vi"/>
				<Item Name="DAQmx Write (Raw 1D U16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D U16).vi"/>
				<Item Name="DAQmx Write (Raw 1D U32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D U32).vi"/>
				<Item Name="DAQmx Write (Raw 1D U8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D U8).vi"/>
				<Item Name="DAQmx Write (Digital 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital U8 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital U8 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital U32 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital U32 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U32 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U32 NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U8 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U8 NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 2D Bool NChan 1Samp NLine).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D Bool NChan 1Samp NLine).vi"/>
				<Item Name="DAQmx Write (Digital 1D Bool NChan 1Samp 1Line).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Bool NChan 1Samp 1Line).vi"/>
				<Item Name="DAQmx Write (Analog 2D I16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D I16 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter Frequency 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter Frequency 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter Ticks 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter Ticks 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter Time 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter Time 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Frequency NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Frequency NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Time NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Time NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter 1DTicks NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1DTicks NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog 2D I32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D I32 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital U16 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital U16 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U16 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U16 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U16 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U16 NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Frequency 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Frequency 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Ticks 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Ticks 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Time 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Time 1Chan NSamp).vi"/>
				<Item Name="DAQmx Timing.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing.vi"/>
				<Item Name="DAQmx Timing (Sample Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Sample Clock).vi"/>
				<Item Name="DAQmx Timing (Handshaking).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Handshaking).vi"/>
				<Item Name="DAQmx Timing (Implicit).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Implicit).vi"/>
				<Item Name="DAQmx Timing (Use Waveform).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Use Waveform).vi"/>
				<Item Name="DAQmx Timing (Change Detection).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Change Detection).vi"/>
				<Item Name="DAQmx Timing (Burst Import Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Burst Import Clock).vi"/>
				<Item Name="DAQmx Timing (Burst Export Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Burst Export Clock).vi"/>
				<Item Name="DAQmx Timing (Pipelined Sample Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Pipelined Sample Clock).vi"/>
				<Item Name="DAQmx Wait Until Done.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/task.llb/DAQmx Wait Until Done.vi"/>
				<Item Name="DAQmx Clear Task.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/task.llb/DAQmx Clear Task.vi"/>
				<Item Name="DAQmx Reset Device.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/system.llb/DAQmx Reset Device.vi"/>
				<Item Name="DAQmx Create Task.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/task.llb/DAQmx Create Task.vi"/>
				<Item Name="DAQmx Flatten Channel String.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/miscellaneous.llb/DAQmx Flatten Channel String.vi"/>
				<Item Name="DAQmx Create Virtual Channel.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Virtual Channel.vi"/>
				<Item Name="DAQmx Create Channel (AI-Voltage-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Voltage-Basic).vi"/>
				<Item Name="DAQmx Rollback Channel If Error.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Rollback Channel If Error.vi"/>
				<Item Name="DAQmx Create AI Channel (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create AI Channel (sub).vi"/>
				<Item Name="DAQmx Create Channel (AI-Voltage-Custom with Excitation).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Voltage-Custom with Excitation).vi"/>
				<Item Name="DAQmx Create Channel (AI-Resistance).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Resistance).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Thermocouple).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Thermocouple).vi"/>
				<Item Name="DAQmx Set CJC Parameters (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Set CJC Parameters (sub).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-RTD).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-RTD).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Thermistor-Iex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Thermistor-Iex).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Thermistor-Vex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Thermistor-Vex).vi"/>
				<Item Name="DAQmx Create Channel (AO-Voltage-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AO-Voltage-Basic).vi"/>
				<Item Name="DAQmx Create AO Channel (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create AO Channel (sub).vi"/>
				<Item Name="DAQmx Create Channel (AO-FuncGen).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AO-FuncGen).vi"/>
				<Item Name="DAQmx Create Channel (DI-Digital Input).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (DI-Digital Input).vi"/>
				<Item Name="DAQmx Create DI Channel (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create DI Channel (sub).vi"/>
				<Item Name="DAQmx Create Channel (DO-Digital Output).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (DO-Digital Output).vi"/>
				<Item Name="DAQmx Create DO Channel (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create DO Channel (sub).vi"/>
				<Item Name="DAQmx Create Channel (CI-Frequency).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Frequency).vi"/>
				<Item Name="DAQmx Create CI Channel (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create CI Channel (sub).vi"/>
				<Item Name="DAQmx Create Channel (CI-Period).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Period).vi"/>
				<Item Name="DAQmx Create Channel (CI-Count Edges).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Count Edges).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Width).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Width).vi"/>
				<Item Name="DAQmx Create Channel (CI-Semi Period).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Semi Period).vi"/>
				<Item Name="DAQmx Create Channel (AI-Current-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Current-Basic).vi"/>
				<Item Name="DAQmx Create Channel (AI-Strain-Strain Gage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Strain-Strain Gage).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Built-in Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Built-in Sensor).vi"/>
				<Item Name="DAQmx Create Channel (AI-Frequency-Voltage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Frequency-Voltage).vi"/>
				<Item Name="DAQmx Create Channel (CO-Pulse Generation-Frequency).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CO-Pulse Generation-Frequency).vi"/>
				<Item Name="DAQmx Create CO Channel (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create CO Channel (sub).vi"/>
				<Item Name="DAQmx Create Channel (CO-Pulse Generation-Time).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CO-Pulse Generation-Time).vi"/>
				<Item Name="DAQmx Create Channel (CO-Pulse Generation-Ticks).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CO-Pulse Generation-Ticks).vi"/>
				<Item Name="DAQmx Create Channel (AI-Position-LVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Position-LVDT).vi"/>
				<Item Name="DAQmx Create Channel (AI-Position-RVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Position-RVDT).vi"/>
				<Item Name="DAQmx Create Channel (CI-Two Edge Separation).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Two Edge Separation).vi"/>
				<Item Name="DAQmx Create Channel (AI-Acceleration-Accelerometer).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Acceleration-Accelerometer).vi"/>
				<Item Name="DAQmx Create Channel (CI-Position-Angular Encoder).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Position-Angular Encoder).vi"/>
				<Item Name="DAQmx Create Channel (CI-Position-Linear Encoder).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Position-Linear Encoder).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Acceleration-Accelerometer).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Acceleration-Accelerometer).vi"/>
				<Item Name="DAQmx Create AI Channel TEDS(sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create AI Channel TEDS(sub).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Current-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Current-Basic).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Position-LVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Position-LVDT).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Position-RVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Position-RVDT).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Resistance).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Resistance).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Strain-Strain Gage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Strain-Strain Gage).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-RTD).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-RTD).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Iex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Iex).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Vex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Vex).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Voltage-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Voltage-Basic).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Voltage-Custom with Excitation).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Voltage-Custom with Excitation).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-Thermocouple).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-Thermocouple).vi"/>
				<Item Name="DAQmx Create Channel (AI-Sound Pressure-Microphone).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Sound Pressure-Microphone).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Sound Pressure-Microphone).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Sound Pressure-Microphone).vi"/>
				<Item Name="DAQmx Create Channel (CI-GPS Timestamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-GPS Timestamp).vi"/>
				<Item Name="DAQmx Create Channel (AO-Current-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AO-Current-Basic).vi"/>
				<Item Name="DAQmx Create Channel (AI-Voltage-RMS).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Voltage-RMS).vi"/>
				<Item Name="DAQmx Create Channel (AI-Current-RMS).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Current-RMS).vi"/>
				<Item Name="DAQmx Create Channel (AI-Position-EddyCurrentProxProbe).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Position-EddyCurrentProxProbe).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Freq).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Freq).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Time).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Time).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Ticks).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Ticks).vi"/>
				<Item Name="DAQmx Create Channel (AI-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-Bridge-Polynomial).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-Bridge-Polynomial).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-Bridge-Table).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-Bridge-Table).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-Bridge-Two-Point-Linear).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-Bridge-Two-Point-Linear).vi"/>
				<Item Name="DAQmx Create Channel (AI-Pressure-Bridge-Two-Point-Linear).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Pressure-Bridge-Two-Point-Linear).vi"/>
				<Item Name="DAQmx Create Channel (AI-Pressure-Bridge-Table).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Pressure-Bridge-Table).vi"/>
				<Item Name="DAQmx Create Channel (AI-Pressure-Bridge-Polynomial).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Pressure-Bridge-Polynomial).vi"/>
				<Item Name="DAQmx Create Channel (AI-Torque-Bridge-Two-Point-Linear).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Torque-Bridge-Two-Point-Linear).vi"/>
				<Item Name="DAQmx Create Channel (AI-Torque-Bridge-Table).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Torque-Bridge-Table).vi"/>
				<Item Name="DAQmx Create Channel (AI-Torque-Bridge-Polynomial).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Torque-Bridge-Polynomial).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Force-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Force-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Pressure-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Pressure-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Torque-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Torque-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Force-IEPE Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Force-IEPE Sensor).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-IEPE Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-IEPE Sensor).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (AI-Velocity-IEPE Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Velocity-IEPE Sensor).vi"/>
				<Item Name="DAQmx Create Channel (AI-Strain-Rosette Strain Gage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Strain-Rosette Strain Gage).vi"/>
				<Item Name="DAQmx Create Strain Rosette AI Channels (sub).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Strain Rosette AI Channels (sub).vi"/>
				<Item Name="DAQmx Start Task.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/task.llb/DAQmx Start Task.vi"/>
				<Item Name="DAQmx Configure Output Buffer.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/buffer.llb/DAQmx Configure Output Buffer.vi"/>
				<Item Name="VISA Flush IO Buffer Mask.ctl" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Flush IO Buffer Mask.ctl"/>
				<Item Name="System Exec.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/system.llb/System Exec.vi"/>
			</Item>
			<Item Name="instr.lib" Type="Folder">
				<Item Name="niScope Initialize.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/niScope Initialize.vi"/>
				<Item Name="niScope Get Session Reference.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Utility/niScope Get Session Reference.vi"/>
				<Item Name="niScope LabVIEW Error.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Utility/niScope LabVIEW Error.vi"/>
				<Item Name="niScope Reset Device.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Utility/niScope Reset Device.vi"/>
				<Item Name="niScope Close.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/niScope Close.vi"/>
				<Item Name="niScope vertical coupling.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope vertical coupling.ctl"/>
				<Item Name="niScope Configure Vertical.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Vertical/niScope Configure Vertical.vi"/>
				<Item Name="niScope Configure Chan Characteristics.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Vertical/niScope Configure Chan Characteristics.vi"/>
				<Item Name="niScope Commit.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Utility/niScope Commit.vi"/>
				<Item Name="niScope Sample Rate.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Horizontal/niScope Sample Rate.vi"/>
				<Item Name="niScope Configure Horizontal Timing.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Horizontal/niScope Configure Horizontal Timing.vi"/>
				<Item Name="niTClk Fill In Error Info.vi" Type="VI" URL="/&lt;instrlib&gt;/niTClk/niTClk.llb/niTClk Fill In Error Info.vi"/>
				<Item Name="niTClk Synchronize.vi" Type="VI" URL="/&lt;instrlib&gt;/niTClk/niTClk.llb/niTClk Synchronize.vi"/>
				<Item Name="niTClk Configure For Homogeneous Triggers.vi" Type="VI" URL="/&lt;instrlib&gt;/niTClk/niTClk.llb/niTClk Configure For Homogeneous Triggers.vi"/>
				<Item Name="niScope Configure Trigger Immediate.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Trigger Immediate.vi"/>
				<Item Name="niScope trigger source.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope trigger source.ctl"/>
				<Item Name="niScope signal format.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope signal format.ctl"/>
				<Item Name="niScope trigger coupling.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope trigger coupling.ctl"/>
				<Item Name="niScope polarity.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope polarity.ctl"/>
				<Item Name="niScope tv event.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope tv event.ctl"/>
				<Item Name="niScope Configure Video Trigger.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Video Trigger.vi"/>
				<Item Name="niScope trigger window mode.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope trigger window mode.ctl"/>
				<Item Name="niScope Configure Trigger Window.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Trigger Window.vi"/>
				<Item Name="niScope Configure Trigger Software.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Trigger Software.vi"/>
				<Item Name="niScope trigger slope.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope trigger slope.ctl"/>
				<Item Name="niScope Configure Trigger Hysteresis.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Trigger Hysteresis.vi"/>
				<Item Name="niScope Configure Trigger Edge.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Trigger Edge.vi"/>
				<Item Name="niScope trigger source digital.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope trigger source digital.ctl"/>
				<Item Name="niScope Configure Trigger Digital.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Trigger Digital.vi"/>
				<Item Name="niScope Configure Trigger (poly).vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Configure Trigger (poly).vi"/>
				<Item Name="niScope Fetch Error Chain.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Error Chain.vi"/>
				<Item Name="niScope Fetch Binary 32.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Binary 32.vi"/>
				<Item Name="niScope Fetch Cluster.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Cluster.vi"/>
				<Item Name="niScope timestamp type.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope timestamp type.ctl"/>
				<Item Name="niScope Multi Fetch Complex WDT.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch Complex WDT.vi"/>
				<Item Name="niScope Fetch Complex WDT.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Complex WDT.vi"/>
				<Item Name="niScope Multi Fetch Cluster Complex Double.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch Cluster Complex Double.vi"/>
				<Item Name="niScope Fetch Cluster Complex Double.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Cluster Complex Double.vi"/>
				<Item Name="niScope Multi Fetch Complex Double.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch Complex Double.vi"/>
				<Item Name="niScope Fetch Complex Double.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Complex Double.vi"/>
				<Item Name="niScope Multi Fetch WDT.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch WDT.vi"/>
				<Item Name="niScope Fetch WDT.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch WDT.vi"/>
				<Item Name="niScope Multi Fetch.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch.vi"/>
				<Item Name="niScope Fetch.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch.vi"/>
				<Item Name="niScope Multi Fetch Cluster.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch Cluster.vi"/>
				<Item Name="niScope Multi Fetch Binary 8.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch Binary 8.vi"/>
				<Item Name="niScope Multi Fetch Binary 32.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch Binary 32.vi"/>
				<Item Name="niScope Fetch Binary 16.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Binary 16.vi"/>
				<Item Name="niScope Multi Fetch Binary 16.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Multi Fetch Binary 16.vi"/>
				<Item Name="niScope Fetch Binary 8.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch Binary 8.vi"/>
				<Item Name="niScope Fetch (poly).vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Fetch (poly).vi"/>
				<Item Name="niScope Acquisition Status.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Acquisition Status.vi"/>
				<Item Name="niTClk Initiate.vi" Type="VI" URL="/&lt;instrlib&gt;/niTClk/niTClk.llb/niTClk Initiate.vi"/>
				<Item Name="niScope Initiate Acquisition.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Initiate Acquisition.vi"/>
				<Item Name="niScope Abort.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Acquire/Fetch/niScope Abort.vi"/>
				<Item Name="niScope export destinations.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope export destinations.ctl"/>
				<Item Name="niScope exportable signals.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope exportable signals.ctl"/>
				<Item Name="niScope Export Signal.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Trigger/niScope Export Signal.vi"/>
				<Item Name="niScope which signal.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope which signal.ctl"/>
				<Item Name="niScope Actual Record Length.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Configure/Horizontal/niScope Actual Record Length.vi"/>
				<Item Name="niScope self cal option.ctl" Type="VI" URL="/&lt;instrlib&gt;/niScope/Controls/niScope self cal option.ctl"/>
				<Item Name="niScope Cal Self Calibrate.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Calibrate/niScope Cal Self Calibrate.vi"/>
				<Item Name="niScope Disable.vi" Type="VI" URL="/&lt;instrlib&gt;/niScope/Utility/niScope Disable.vi"/>
			</Item>
			<Item Name="niScope_32.dll" Type="Document" URL="niScope_32.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="niTClk.dll" Type="Document" URL="niTClk.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="lvanlys.dll" Type="Document" URL="/&lt;resource&gt;/lvanlys.dll"/>
			<Item Name="version.dll" Type="Document" URL="version.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="kernel32.dll" Type="Document" URL="kernel32.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="Advapi32.dll" Type="Document" URL="Advapi32.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="nilvaiu.dll" Type="Document" URL="nilvaiu.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="TWM - full" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{8C66452C-5A67-4A8E-B1BD-5A8F3DA5EA7B}</Property>
				<Property Name="App_INI_GUID" Type="Str">{E89658F0-ABAA-427B-890A-02F40DF16C38}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{192FE75A-65D5-45FC-B03D-2ADB5F6044BF}</Property>
				<Property Name="Bld_buildSpecDescription" Type="Str">Full version (includes all drivers).</Property>
				<Property Name="Bld_buildSpecName" Type="Str">TWM - full</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-full</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_postActionVIID" Type="Ref">/My Computer/build/Post-Build Action.vi</Property>
				<Property Name="Bld_preActionVIID" Type="Ref">/My Computer/build/Pre-Build Action - visa,niscope,daqmx.vi</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{760E6441-58E1-45EF-AC33-D56DB8BDDEEF}</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Bld_version.minor" Type="Int">7</Property>
				<Property Name="Bld_version.patch" Type="Int">3</Property>
				<Property Name="Destination[0].destName" Type="Str">TWM.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-full/NI_AB_PROJECTNAME.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-full</Property>
				<Property Name="Destination[2].destName" Type="Str">octprog</Property>
				<Property Name="Destination[2].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-full/octprog</Property>
				<Property Name="Destination[2].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[3].destName" Type="Str">doc</Property>
				<Property Name="Destination[3].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-full/doc</Property>
				<Property Name="Destination[3].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[4].destName" Type="Str">data</Property>
				<Property Name="Destination[4].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-full/data</Property>
				<Property Name="Destination[4].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="DestinationCount" Type="Int">5</Property>
				<Property Name="Exe_iconItemID" Type="Ref">/My Computer/icon.ico</Property>
				<Property Name="Source[0].itemID" Type="Str">{D061C331-8D0D-4D0F-A999-BD1B55AF040F}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/main.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].itemID" Type="Ref">/My Computer/config.ini</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[3].itemID" Type="Ref">/My Computer/drivers/dsdll/dsdll.dll</Property>
				<Property Name="Source[3].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[4].itemID" Type="Ref">/My Computer/octave/golpi/lv_proc.dll</Property>
				<Property Name="Source[4].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[5].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[5].Container.applyInclusion" Type="Bool">true</Property>
				<Property Name="Source[5].destinationIndex" Type="Int">3</Property>
				<Property Name="Source[5].itemID" Type="Ref">/My Computer/doc</Property>
				<Property Name="Source[5].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[5].type" Type="Str">Container</Property>
				<Property Name="Source[6].itemID" Type="Ref">/My Computer/LICENSE.txt</Property>
				<Property Name="Source[6].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[7].itemID" Type="Ref">/My Computer/readme.txt</Property>
				<Property Name="Source[7].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[8].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[8].Container.applyInclusion" Type="Bool">true</Property>
				<Property Name="Source[8].destinationIndex" Type="Int">4</Property>
				<Property Name="Source[8].itemID" Type="Ref">/My Computer/data</Property>
				<Property Name="Source[8].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[8].type" Type="Str">Container</Property>
				<Property Name="Source[9].itemID" Type="Ref">/My Computer/octave/golpi/golpi-1.2.1.tar.gz</Property>
				<Property Name="Source[9].sourceInclusion" Type="Str">Include</Property>
				<Property Name="SourceCount" Type="Int">10</Property>
				<Property Name="TgtF_companyName" Type="Str">Czech Metrology Institute</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Traceable Wattmeter. EMPIR project TracePQM.

V1.3.2 - most of the bugs fixed
V1.4.0 - FFT analyser added
V1.4.1 - minor fixes for server oparation
V1.4.3 - implemented AWG Tek AFG3000 series for 3458A clocking 
V1.4.4 - DMM fixed relays saved, few more improvements
V1.5.0 - conditional compile of selected drivers included
V1.6.0 - improved GUI (mainly corrections)
V1.6.1 - minor fixes in corrections editor, fixed dsdll
V1.6.2 - time multiplex support (not tested!)
V1.6.3 - minor fixes in time multiplex
V1.6.4 - basic implementation of Keysight DSO
V1.6.5 - fixed timeout problem for 3458A in sub-records mode
V1.6.6 - support for cDAQ ADC
V1.6.7 - cDAQ data scaling fixed
V1.6.8 - partial support for Fluke 8588A
V1.6.9 - support for CMI clock div, minor changes in GUI
V1.7.1 - minor fixes
V1.7.2 - adc ranges settable via server
V1.7.3 - Keysight DSO driver small range bug fix</Property>
				<Property Name="TgtF_internalName" Type="Str">TWM - visa,niscope</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2017 - 2021</Property>
				<Property Name="TgtF_productName" Type="Str">TWM - visa,niscope</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{D8F2E1E1-802E-4B60-9D7C-5E18E07A06CA}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">TWM.exe</Property>
			</Item>
			<Item Name="TWM - visa,niscope" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{89B6655C-307D-46E0-B66B-590EEDBEBBBE}</Property>
				<Property Name="App_INI_GUID" Type="Str">{3FC40814-77EF-41BB-9528-322802B01604}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{66A1928A-1BA5-40AC-BAF2-1120B8E1382E}</Property>
				<Property Name="Bld_buildSpecDescription" Type="Str">Version with VISA and niScope drivers only.</Property>
				<Property Name="Bld_buildSpecName" Type="Str">TWM - visa,niscope</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa-niscope</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_postActionVIID" Type="Ref">/My Computer/build/Post-Build Action.vi</Property>
				<Property Name="Bld_preActionVIID" Type="Ref">/My Computer/build/Pre-Build Action - visa,niscope.vi</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{18CDA2A0-4686-4CF7-A999-34E367684EE7}</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Bld_version.minor" Type="Int">7</Property>
				<Property Name="Bld_version.patch" Type="Int">3</Property>
				<Property Name="Destination[0].destName" Type="Str">TWM-visa-niScope.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa-niscope/TWM-visa-niScope.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa-niscope</Property>
				<Property Name="Destination[2].destName" Type="Str">octprog</Property>
				<Property Name="Destination[2].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa-niscope/octprog</Property>
				<Property Name="Destination[2].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[3].destName" Type="Str">doc</Property>
				<Property Name="Destination[3].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa-niscope/doc</Property>
				<Property Name="Destination[3].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[4].destName" Type="Str">data</Property>
				<Property Name="Destination[4].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa-niscope/data</Property>
				<Property Name="Destination[4].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="DestinationCount" Type="Int">5</Property>
				<Property Name="Exe_iconItemID" Type="Ref">/My Computer/icon.ico</Property>
				<Property Name="Source[0].itemID" Type="Str">{D061C331-8D0D-4D0F-A999-BD1B55AF040F}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/main.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].itemID" Type="Ref">/My Computer/config.ini</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[3].itemID" Type="Ref">/My Computer/drivers/dsdll/dsdll.dll</Property>
				<Property Name="Source[3].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[4].itemID" Type="Ref">/My Computer/octave/golpi/lv_proc.dll</Property>
				<Property Name="Source[4].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[5].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[5].Container.applyInclusion" Type="Bool">true</Property>
				<Property Name="Source[5].destinationIndex" Type="Int">3</Property>
				<Property Name="Source[5].itemID" Type="Ref">/My Computer/doc</Property>
				<Property Name="Source[5].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[5].type" Type="Str">Container</Property>
				<Property Name="Source[6].itemID" Type="Ref">/My Computer/LICENSE.txt</Property>
				<Property Name="Source[6].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[7].itemID" Type="Ref">/My Computer/readme.txt</Property>
				<Property Name="Source[7].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[8].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[8].Container.applyInclusion" Type="Bool">true</Property>
				<Property Name="Source[8].destinationIndex" Type="Int">4</Property>
				<Property Name="Source[8].itemID" Type="Ref">/My Computer/data</Property>
				<Property Name="Source[8].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[8].type" Type="Str">Container</Property>
				<Property Name="Source[9].itemID" Type="Ref">/My Computer/octave/golpi/golpi-1.2.1.tar.gz</Property>
				<Property Name="Source[9].sourceInclusion" Type="Str">Include</Property>
				<Property Name="SourceCount" Type="Int">10</Property>
				<Property Name="TgtF_companyName" Type="Str">Czech Metrology Institute</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Traceable Wattmeter. EMPIR project TracePQM.

V1.3.2 - most of the bugs fixed
V1.4.0 - FFT analyser added
V1.4.1 - minor fixes for server oparation
V1.4.3 - implemented AWG Tek AFG3000 series for 3458A clocking 
V1.4.4 - DMM fixed relays saved, few more improvements
V1.5.0 - conditional compile of selected drivers included
V1.6.0 - improved GUI (mainly corrections)
V1.6.1 - minor fixes in corrections editor, fixed dsdll
V1.6.2 - time multiplex support (not tested!)
V1.6.3 - minor fixes in time multiplex
V1.6.4 - basic implementation of Keysight DSO
V1.6.5 - fixed timeout problem for 3458A in sub-records mode
V1.6.6 - support for cDAQ ADC
V1.6.9 - support for CMI clock div, Fluke 8588, minor changes in GUI
V1.7.1 - minor fixes
V1.7.2 - adc ranges settable via server
V1.7.3 - Keysight DSO driver small range bug fix</Property>
				<Property Name="TgtF_internalName" Type="Str">TWM - visa,niscope</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2018 - 2021</Property>
				<Property Name="TgtF_productName" Type="Str">TWM - visa,niscope</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{19518978-F8E5-4558-9786-71904496379A}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">TWM-visa-niScope.exe</Property>
			</Item>
			<Item Name="TWM - visa" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{9B2CA7FA-FE95-45B7-A106-6491F44CA491}</Property>
				<Property Name="App_INI_GUID" Type="Str">{C1744958-9B06-4909-824A-009EEA52FFEB}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{C4B426E3-129E-425D-AFE7-765817772A4D}</Property>
				<Property Name="Bld_buildSpecDescription" Type="Str">TWM build with only VISA drivers.</Property>
				<Property Name="Bld_buildSpecName" Type="Str">TWM - visa</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_postActionVIID" Type="Ref">/My Computer/build/Post-Build Action.vi</Property>
				<Property Name="Bld_preActionVIID" Type="Ref">/My Computer/build/Pre-Build Action - visa.vi</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{6610392B-F2DD-4345-9565-78A1287C6779}</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Bld_version.minor" Type="Int">7</Property>
				<Property Name="Bld_version.patch" Type="Int">3</Property>
				<Property Name="Destination[0].destName" Type="Str">TWM-visa.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/TWM-visa.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa</Property>
				<Property Name="Destination[2].destName" Type="Str">octprog</Property>
				<Property Name="Destination[2].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/octprog</Property>
				<Property Name="Destination[2].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[3].destName" Type="Str">doc</Property>
				<Property Name="Destination[3].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/doc</Property>
				<Property Name="Destination[3].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[4].destName" Type="Str">data</Property>
				<Property Name="Destination[4].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/data</Property>
				<Property Name="Destination[4].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="DestinationCount" Type="Int">5</Property>
				<Property Name="Exe_iconItemID" Type="Ref">/My Computer/icon.ico</Property>
				<Property Name="Source[0].itemID" Type="Str">{D061C331-8D0D-4D0F-A999-BD1B55AF040F}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/main.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].itemID" Type="Ref">/My Computer/config.ini</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[3].itemID" Type="Ref">/My Computer/drivers/dsdll/dsdll.dll</Property>
				<Property Name="Source[3].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[4].itemID" Type="Ref">/My Computer/octave/golpi/lv_proc.dll</Property>
				<Property Name="Source[4].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[5].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[5].Container.applyInclusion" Type="Bool">true</Property>
				<Property Name="Source[5].destinationIndex" Type="Int">3</Property>
				<Property Name="Source[5].itemID" Type="Ref">/My Computer/doc</Property>
				<Property Name="Source[5].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[5].type" Type="Str">Container</Property>
				<Property Name="Source[6].itemID" Type="Ref">/My Computer/LICENSE.txt</Property>
				<Property Name="Source[6].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[7].itemID" Type="Ref">/My Computer/readme.txt</Property>
				<Property Name="Source[7].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[8].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[8].Container.applyInclusion" Type="Bool">true</Property>
				<Property Name="Source[8].destinationIndex" Type="Int">4</Property>
				<Property Name="Source[8].itemID" Type="Ref">/My Computer/data</Property>
				<Property Name="Source[8].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[8].type" Type="Str">Container</Property>
				<Property Name="Source[9].itemID" Type="Ref">/My Computer/octave/golpi/golpi-1.2.1.tar.gz</Property>
				<Property Name="Source[9].sourceInclusion" Type="Str">Include</Property>
				<Property Name="SourceCount" Type="Int">10</Property>
				<Property Name="TgtF_companyName" Type="Str">Czech Metrology Institute</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Traceable Wattmeter. EMPIR project TracePQM.

V1.3.2 - most of the bugs fixed
V1.4.0 - FFT analyser added
V1.4.1 - minor fixes for server oparation
V1.4.3 - implemented AWG Tek AFG3000 series for 3458A clocking 
V1.4.4 - DMM fixed relays saved, few more improvements
V1.4.4 - DMM fixed relays saved, few more improvements
V1.5.0 - conditional compile of selected drivers included
V1.6.0 - improved GUI (mainly corrections)
V1.6.1 - minor fixes in corrections editor, fixed dsdll
V1.7.0 - parallel QWTB processing
V1.7.1 - minor fixes
V1.7.2 - ranges settable via server
V1.7.3 - Keysight DSO driver small range bug fix</Property>
				<Property Name="TgtF_internalName" Type="Str">TWM - Full</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2018 - 2021</Property>
				<Property Name="TgtF_productName" Type="Str">TWM - Full</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{AEEC5EC9-3A7F-49CB-BB07-729F6120ABF4}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">TWM-visa.exe</Property>
			</Item>
			<Item Name="TWM client" Type="Packed Library">
				<Property Name="Bld_buildCacheID" Type="Str">{1AF98330-9B00-411A-BF40-00073A3BEFD4}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">TWM client</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../TWM-builds/builds/TWM client</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{DB64396F-7FF5-45F4-8E08-882448D7416F}</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Bld_version.minor" Type="Int">3</Property>
				<Property Name="Bld_version.patch" Type="Int">2</Property>
				<Property Name="Destination[0].destName" Type="Str">TWM client.lvlibp</Property>
				<Property Name="Destination[0].path" Type="Path">../TWM-builds/builds/TWM client/TWM client.lvlibp</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../TWM-builds/builds/TWM client</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="PackedLib_callersAdapt" Type="Bool">true</Property>
				<Property Name="Source[0].itemID" Type="Str">{B53FD108-91F0-4548-AFA2-34ADC15D4E0E}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/server/TWM Client.lvlib</Property>
				<Property Name="Source[1].Library.allowMissingMembers" Type="Bool">true</Property>
				<Property Name="Source[1].Library.atomicCopy" Type="Bool">true</Property>
				<Property Name="Source[1].Library.LVLIBPtopLevel" Type="Bool">true</Property>
				<Property Name="Source[1].preventRename" Type="Bool">true</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">Library</Property>
				<Property Name="SourceCount" Type="Int">2</Property>
				<Property Name="TgtF_enableDebugging" Type="Bool">true</Property>
				<Property Name="TgtF_fileDescription" Type="Str">TWM tool client for remote operation.</Property>
				<Property Name="TgtF_internalName" Type="Str">TWM client</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2018 - 2020</Property>
				<Property Name="TgtF_productName" Type="Str">TWM client</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{6C025CF9-40E7-49D2-B44F-F2225C8410EF}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">TWM client.lvlibp</Property>
			</Item>
			<Item Name="dummy build" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{6EB92510-8128-4E99-A4DD-250C67EB43F2}</Property>
				<Property Name="App_INI_GUID" Type="Str">{067FB65E-F083-49A9-B393-6FB3D33EE336}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{4EB63204-538F-4639-AEBB-77A6C7D16259}</Property>
				<Property Name="Bld_buildSpecDescription" Type="Str">Dummy build just for testing purposes.</Property>
				<Property Name="Bld_buildSpecName" Type="Str">dummy build</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_postActionVIID" Type="Ref">/My Computer/build/Post-Build Action.vi</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{EC92165E-980E-4BE0-ACFD-B7F482C8CFAB}</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Bld_version.minor" Type="Int">7</Property>
				<Property Name="Bld_version.patch" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">TWM.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/NI_AB_PROJECTNAME.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa</Property>
				<Property Name="Destination[2].destName" Type="Str">octprog</Property>
				<Property Name="Destination[2].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/octprog</Property>
				<Property Name="Destination[2].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[3].destName" Type="Str">doc</Property>
				<Property Name="Destination[3].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/doc</Property>
				<Property Name="Destination[3].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[4].destName" Type="Str">data</Property>
				<Property Name="Destination[4].path" Type="Path">../TWM-builds/builds/TWM-[VersionNumber]-visa/data</Property>
				<Property Name="Destination[4].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="DestinationCount" Type="Int">5</Property>
				<Property Name="Source[0].itemID" Type="Str">{6E37BBAE-F219-461D-88C6-705A83DF4ECC}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/main.vi</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[2].destinationIndex" Type="Int">2</Property>
				<Property Name="Source[2].itemID" Type="Ref"></Property>
				<Property Name="Source[2].type" Type="Str">Container</Property>
				<Property Name="Source[3].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[3].destinationIndex" Type="Int">3</Property>
				<Property Name="Source[3].itemID" Type="Ref">/My Computer/doc</Property>
				<Property Name="Source[3].type" Type="Str">Container</Property>
				<Property Name="Source[4].Container.applyDestination" Type="Bool">true</Property>
				<Property Name="Source[4].destinationIndex" Type="Int">4</Property>
				<Property Name="Source[4].itemID" Type="Ref">/My Computer/data</Property>
				<Property Name="Source[4].type" Type="Str">Container</Property>
				<Property Name="Source[5].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[5].itemID" Type="Ref">/My Computer/info_test.vi</Property>
				<Property Name="Source[5].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[5].type" Type="Str">VI</Property>
				<Property Name="SourceCount" Type="Int">6</Property>
				<Property Name="TgtF_companyName" Type="Str">Czech Metrology Institute</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Traceable Wattmeter. EMPIR project TracePQM.

V1.3.2 - most of the bugs fixed
V1.4.0 - FFT analyser added
V1.4.1 - minor fixes for server oparation
V1.4.3 - implemented AWG Tek AFG3000 series for 3458A clocking 
V1.4.4 - DMM fixed relays saved, few more improvements
V1.4.4 - DMM fixed relays saved, few more improvements
V1.5.0 - conditional compile of selected drivers included
V1.6.0 - improved GUI (mainly corrections)
V1.6.1 - minor fixes in corrections editor, fixed dsdll
V1.7.0 - parallel QWTB processing
V1.7.1 - minor fixes</Property>
				<Property Name="TgtF_internalName" Type="Str">TWM - Full</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2018 - 2020</Property>
				<Property Name="TgtF_productName" Type="Str">TWM - Full</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{C2769234-725A-4E54-B71A-C229138897BB}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">TWM.exe</Property>
			</Item>
		</Item>
	</Item>
</Project>
