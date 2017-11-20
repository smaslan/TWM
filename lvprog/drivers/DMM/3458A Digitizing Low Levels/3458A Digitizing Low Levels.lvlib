<?xml version='1.0' encoding='UTF-8'?>
<Library LVVersion="13008000">
	<Property Name="Instrument Driver" Type="Str">True</Property>
	<Property Name="NI.Lib.ContainingLib" Type="Str">3458A Virtual Digitizer.lvlib</Property>
	<Property Name="NI.Lib.ContainingLibPath" Type="Str">../../3458A Virtual Digitizer.lvlib</Property>
	<Property Name="NI.Lib.Description" Type="Str">LabVIEW Plug and Play instrument driver for

Keysight 3458A multimeter for measurements of power and PQ parameters. The 3458A multimeters are synchronized with an external sampling interval generated with a generator or a PLL circuit. The generator sends a burst of pulses corresponding to the required number of samples. </Property>
	<Property Name="NI.Lib.Icon" Type="Bin">%Q#!!!!!!!)!"1!&amp;!!!-!%!!!@````]!!!!"!!%!!!*-!!!*Q(C=\&gt;1`=N.1%-@R8ZA5F,B0Q@A+?Q6@A-)(I.ELO%XJ1%03&lt;1GFKV"G@)86%8Q&amp;8]&amp;]N7]$A1*4E"G'C?2H3&lt;`X\_-H76*NL[6,H=ZN_OV'`44.*R0(;4ZIH(2=`;?[GE;L=&gt;H(KO`LH`M`K8_M'[V'0MZ_G6`&gt;8T];`)(`J@[F`D_O0``XPD\&lt;[*EX[;+EF+1%R3F7P_[5Z%G?Z%G?Z%E?Z%%?Z%%?Z%(OZ%\OZ%\OZ%ZOZ%:OZ%:OZ%:?/\H)23ZS6C7:0*EI'41:)'E-2=F8YEE]C3@R=+H%EXA34_**0$22YEE]C3@R*"[[+@%EHM34?")01Z5E;S@(EXA98I%H]!3?Q".YG&amp;+"*Q!%EQ5$"Y0!5&amp;!:H!3?Q".Y/&amp;8A#4S"*`!%(KI6?!*0Y!E]A9=ON3J2GHEHR]-Q=DS/R`%Y(M@$U()]DM@R/"\(QX2S0)\(14A4/I.$E.0*;?"=/"\(QU'/R`%Y(M@D?+CK/_3V-L.GXMHR'"\$9XA-D_&amp;B#"E?QW.Y$)`B96A:(M.D?!S0Y7%K'2\$9XA-C$%JU]M9T/BI.$)#Q]/HHB;LOR1FM&gt;L\LTE?605$K([QV!_-_E&amp;1XW$VD60@%06#KR&gt;1P4$K([T_)7KA?G,VA/K'/P*^I/QJ/]K7MK'M+3P+EL+9O`\FBM@D59@$1@P^8LP&gt;4NPN6JP.2OPV7KP63MPF5IP&amp;YPP&lt;[CX\W#Y?XUP8H.]`8,W`_8*X?`&gt;Q&gt;@PRQ[@0^V`@P*PTZSTDP@1PP"PV3K=HLXH7["MJ]#G4!!!!!!</Property>
	<Property Name="NI.Lib.SourceVersion" Type="Int">318799872</Property>
	<Property Name="NI.Lib.Version" Type="Str">1.0.0.0</Property>
	<Property Name="NI.SortType" Type="Int">3</Property>
	<Item Name="Private" Type="Folder">
		<Property Name="NI.LibItem.Scope" Type="Int">2</Property>
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Item Name="3458A Utility Output Format.vi" Type="VI" URL="../Private/3458A Utility Output Format.vi"/>
	</Item>
	<Item Name="Action-Status" Type="Folder">
		<Item Name="AutoCal Mode.ctl" Type="VI" URL="../Action-Status/AutoCal Mode.ctl"/>
		<Item Name="Wait Sampling Done.vi" Type="VI" URL="../Action-Status/Wait Sampling Done.vi"/>
		<Item Name="Initiate Sampling.vi" Type="VI" URL="../Action-Status/Initiate Sampling.vi"/>
		<Item Name="Initiate Autocal.vi" Type="VI" URL="../Action-Status/Initiate Autocal.vi"/>
		<Item Name="Check for Device Ready.vi" Type="VI" URL="../Action-Status/Check for Device Ready.vi"/>
		<Item Name="Wait for Device Ready.vi" Type="VI" URL="../Action-Status/Wait for Device Ready.vi"/>
	</Item>
	<Item Name="Configure" Type="Folder">
		<Property Name="NI.LibItem.Scope" Type="Int">1</Property>
		<Item Name="First Sample Trigger.ctl" Type="VI" URL="../Configure/First Sample Trigger.ctl"/>
		<Item Name="Sampling Mode.ctl" Type="VI" URL="../Configure/Sampling Mode.ctl"/>
		<Item Name="Level Setup.ctl" Type="VI" URL="../Configure/Level Setup.ctl"/>
		<Item Name="EXT OUT mode.ctl" Type="VI" URL="../Configure/EXT OUT mode.ctl"/>
		<Item Name="Configure Sampling.vi" Type="VI" URL="../Configure/Configure Sampling.vi"/>
	</Item>
	<Item Name="Data" Type="Folder">
		<Property Name="NI.LibItem.Scope" Type="Int">1</Property>
		<Item Name="Low Level" Type="Folder">
			<Item Name="3458A Read Stream.vi" Type="VI" URL="../Data/Low Level/3458A Read Stream.vi"/>
			<Item Name="3458A Read Digital Sample Memory.vi" Type="VI" URL="../Data/Low Level/3458A Read Digital Sample Memory.vi"/>
		</Item>
		<Item Name="Read data.vi" Type="VI" URL="../Data/Read data.vi"/>
	</Item>
	<Item Name="Utility" Type="Folder">
		<Item Name="Get Serial Number.vi" Type="VI" URL="../../3458A Basic Driver/Public/Utility/Get Serial Number.vi"/>
	</Item>
	<Item Name="Close 3458A.vi" Type="VI" URL="../Close 3458A.vi"/>
	<Item Name="Initialize 3458A.vi" Type="VI" URL="../Initialize 3458A.vi"/>
</Library>
