function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm TWM-LowZ.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018-2021, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
% See also qwtb

    alginfo.id = 'TWM-LowZ';
    alginfo.name = 'TWM tool wrapper: Low impedance measurement algorithm';
    alginfo.desc = 'An algorithm for measurement of low impedances using TWM-WFFT, TWM-FPNLSF or TWM-PSFE.';
    alginfo.citation = 'no';
    alginfo.remarks = 'Can measure low-Z in 4T, 4TP or 2x4T definition. Use current transducer for ref. imepedance and dummy voltage transducer for DUT voltage sensing.';
    alginfo.license = 'MIT License';

    
    
    pid = 1;
    % sample data
    alginfo.inputs(pid).name = 'fs';
    alginfo.inputs(pid).desc = 'Sampling frequency';
    alginfo.inputs(pid).alternative = 1;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'Ts';
    alginfo.inputs(pid).desc = 'Sampling time';
    alginfo.inputs(pid).alternative = 1;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 't';
    alginfo.inputs(pid).desc = 'Time series';
    alginfo.inputs(pid).alternative = 1;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'u';
    alginfo.inputs(pid).desc = 'DUT voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'u_lo';
    alginfo.inputs(pid).desc = 'DUT voltage (low side)';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'u_time_shift_lo';
    alginfo.inputs(pid).desc = 'Low-side channel timeshift for DUT channel';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'i';
    alginfo.inputs(pid).desc = 'REF current';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'time_shift';
    alginfo.inputs(pid).desc = 'u/i channel timeshift';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % --- configuration:
    % initial frequency estimate
    alginfo.inputs(pid).name = 'f_est';
    alginfo.inputs(pid).desc = 'Initial frequency estimate';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % harmonic estimation mode
    alginfo.inputs(pid).name = 'mode';
    alginfo.inputs(pid).desc = 'Harmonic estimation mode (PSFE, FPNLSF, WFFT)';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % equivalent circuit mode:
    alginfo.inputs(pid).name = 'equ';
    alginfo.inputs(pid).desc = 'Equivalent circuit of DUT (CpD, LsRs, etc.)';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % window function:
    alginfo.inputs(pid).name = 'window';
    alginfo.inputs(pid).desc = 'Window function name for FFT mode';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % invert phase function:
    alginfo.inputs(pid).name = 'invert';
    alginfo.inputs(pid).desc = 'Set when one of the impedances has inversed polarity';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % 4TP mode:
    alginfo.inputs(pid).name = 'mode_4TP';
    alginfo.inputs(pid).desc = '4TP impedance measurement wiring (4TP, 2x4T)';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    
    
    % --- flags:
    % note: presence of these parameters signalizes caller capabilities of the algoirthm
    alginfo.inputs(pid).name = 'support_diff';
    alginfo.inputs(pid).desc = 'Algorithm supports differential input data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % only for WFFT
    alginfo.inputs(pid).name = 'support_multi_records';
    alginfo.inputs(pid).desc = 'Algorithm supports processing of a multiple records at once';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    
    % --- parameters:
    
    % ADC setup
    alginfo.inputs(pid).name = 'adc_bits';
    alginfo.inputs(pid).desc = 'ADC resolution';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
        
    alginfo.inputs(pid).name = 'adc_nrng';
    alginfo.inputs(pid).desc = 'ADC nominal range';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
        
    alginfo.inputs(pid).name = 'adc_lsb';
    alginfo.inputs(pid).desc = 'ADC LSB voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % ADC jitter:
    alginfo.inputs(pid).name = 'adc_jitter';
    alginfo.inputs(pid).desc = 'ADC rms jitter';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % ADC apperture effect correction:
    % this set to non-zero value will enable auto correction of the aperture effect by algorithm
    alginfo.inputs(pid).name = 'adc_aper_corr';
    alginfo.inputs(pid).desc = 'ADC aperture effect correction switch';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    % apperture value must be passed if the 'adc_aper_corr' is non-zero:
    alginfo.inputs(pid).name = 'adc_aper';
    alginfo.inputs(pid).desc = 'ADC aperture value';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;     
    % ADC jitter [s]:
    alginfo.inputs(pid).name = 'adc_jitter';
    alginfo.inputs(pid).desc = 'ADC jitter value';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    % ADC offset [V]:
    alginfo.inputs(pid).name = 'adc_offset';
    alginfo.inputs(pid).desc = 'ADC offset voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
          
    
    % ADC gain calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_gain_f';
    alginfo.inputs(pid).desc = 'ADC gain transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_gain_a';
    alginfo.inputs(pid).desc = 'ADC gain transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_gain';
    alginfo.inputs(pid).desc = 'ADC gain transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);     
    
    % ADC phase calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_phi_f';
    alginfo.inputs(pid).desc = 'ADC phase transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_phi_a';
    alginfo.inputs(pid).desc = 'ADC phase transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_phi';
    alginfo.inputs(pid).desc = 'ADC phase transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % ADC SFDR (2D dependence, rows: fund. freqs., columns: fund. harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_sfdr_f';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_sfdr_a';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental harmonic amplitude';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_sfdr';
    alginfo.inputs(pid).desc = 'ADC SFDR: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % ADC input admittance matrices (1D dependences, rows: freqs.)
    alginfo.inputs(pid).name = 'adc_Yin_f';
    alginfo.inputs(pid).desc = 'ADC input admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_Yin_Cp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'adc_Yin_Gp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel conductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    
    
    % Transducer phase calibration matrix (2D dependence, rows: freqs., columns: input rms levels)
    alginfo.inputs(pid).name = 'tr_gain_f';
    alginfo.inputs(pid).desc = 'Transducer gain: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_gain_a';
    alginfo.inputs(pid).desc = 'Transducer gain: rms level axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_gain';
    alginfo.inputs(pid).desc = 'Transducer gain: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % Transducer phase calibration matrix (2D dependence, rows: freqs., columns: input rms levels)
    alginfo.inputs(pid).name = 'tr_phi_f';
    alginfo.inputs(pid).desc = 'Transducer phase transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_phi_a';
    alginfo.inputs(pid).desc = 'Transducer phase transfer: rms level axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_phi';
    alginfo.inputs(pid).desc = 'Transducer phase transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % RVD low-side impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Zlo_f';
    alginfo.inputs(pid).desc = 'RVD low-side impedance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_Zlo_Rp';
    alginfo.inputs(pid).desc = 'RVD low-side impedance: parallel resistance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_Zlo_Cp';
    alginfo.inputs(pid).desc = 'RVD low-side impedance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % Transducer output terminals series impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Zca_f';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_Zca_Ls';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance: series inductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_Zca_Rs';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance: series resistance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % Transducer output terminals shunting admittance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Yca_f';
    alginfo.inputs(pid).desc = 'Transducer terminals shunting admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_Yca_Cp';
    alginfo.inputs(pid).desc = 'Transducer terminals shunting admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'tr_Yca_D';
    alginfo.inputs(pid).desc = 'Transducer terminals shunting admittance: loss tangent';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % Cable(s) series impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'Zcb_f';
    alginfo.inputs(pid).desc = 'Cables series impedance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'Zcb_Ls';
    alginfo.inputs(pid).desc = 'Cables series impedance: series inductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'Zcb_Rs';
    alginfo.inputs(pid).desc = 'Cables series impedance: series resistance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    % Cable(s) shunting admittance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'Ycb_f';
    alginfo.inputs(pid).desc = 'Cables shunting admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'Ycb_Cp';
    alginfo.inputs(pid).desc = 'Cables shunting admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    alginfo.inputs(pid).name = 'Ycb_D';
    alginfo.inputs(pid).desc = 'Cables series impedance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_ui_pair(alginfo,pid,0);
    
    
    
    
    pid = 1;
    % outputs       
    alginfo.outputs(pid).name = 'f';
    alginfo.outputs(pid).desc = 'Fundamental frequency [Hz]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Iref';
    alginfo.outputs(pid).desc = 'Reference RMS current [A]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Idc';
    alginfo.outputs(pid).desc = 'DC current [A]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Udut';
    alginfo.outputs(pid).desc = 'DUT RMS voltage [V]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Pref';
    alginfo.outputs(pid).desc = 'Reference active power [W]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Pdut';
    alginfo.outputs(pid).desc = 'DUT active power [W]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Udc';
    alginfo.outputs(pid).desc = 'DUT dc voltage [V]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Udc_hi';
    alginfo.outputs(pid).desc = 'DUT dc voltage (high-side) [V]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Udc_lo';
    alginfo.outputs(pid).desc = 'DUT dc voltage (low-side) [V]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Udc_ref';
    alginfo.outputs(pid).desc = 'REF dc voltage [V]';
    pid = pid + 1;
        
    alginfo.outputs(pid).name = 'Z_mod';
    alginfo.outputs(pid).desc = 'DUT impedance modulus [Ohm]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Z_phi';
    alginfo.outputs(pid).desc = 'DUT impedance phase angle [rad]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Z_mod_sh';
    alginfo.outputs(pid).desc = 'DUT shield impedance modulus [Ohm]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Z_phi_sh';
    alginfo.outputs(pid).desc = 'DUT shield impedance phase angle [rad]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'mjr';
    alginfo.outputs(pid).desc = 'Major component of DUT impedance';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'mnr';
    alginfo.outputs(pid).desc = 'Minor component of DUT impedance';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'mjr_sh';
    alginfo.outputs(pid).desc = 'Major component of DUT shield impedance';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'mnr_sh';
    alginfo.outputs(pid).desc = 'Minor component of DUT shield impedance';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'mnr_name';
    alginfo.outputs(pid).desc = 'Name of minor component of DUT impedance';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'mjr_name';
    alginfo.outputs(pid).desc = 'Name of major component of DUT impedance';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'spec_f';
    alginfo.outputs(pid).desc = 'Frequency axis of spectrum';
    pid = pid + 1;
    alginfo.outputs(pid).name = 'spec_U';
    alginfo.outputs(pid).desc = 'DUT voltage spectrum';
    pid = pid + 1;
    alginfo.outputs(pid).name = 'spec_I';
    alginfo.outputs(pid).desc = 'REF current spectrum';
    pid = pid + 1;
        
    alginfo.providesGUF = 1;
    alginfo.providesMCM = 1;

end


% creates pair of voltage/current inputs from last quantity in the list 'par'
function [par,pid] = add_ui_pair(par,pid,has_lo)
    in_ref = par.inputs(pid-1);    
    par.inputs(pid) = in_ref;
    par.inputs(pid).name = ['i_' in_ref.name];
    par.inputs(pid).desc = ['Current ' in_ref.desc];
    pid = pid + 1;
    par.inputs(pid) = in_ref;
    par.inputs(pid).name = ['u_' in_ref.name];
    par.inputs(pid).desc = ['Voltage ' in_ref.desc];
    pid = pid + 1;
end


