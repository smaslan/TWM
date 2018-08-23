function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm FFT.
%
% See also qwtb

    alginfo.id = 'TWM-TEST';
    alginfo.name = 'Test/demonstration algorithm for the TWM tool';
    alginfo.desc = 'It contains all input quantities defined in the algorithms data exchange model.';
    alginfo.citation = '';
    alginfo.remarks = '';
    alginfo.license = '';
    
    
    pid = 1;
    
    % --- user parameters:
    % DFT bin to extract:
    alginfo.inputs(pid).name = 'bin';
    alginfo.inputs(pid).desc = 'DFT bin id to extract from the spectrum';
    alginfo.inputs(pid).alternative = 2;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % DFT bin by freq. selection:
    alginfo.inputs(pid).name = 'freq';
    alginfo.inputs(pid).desc = 'Frequency DFT bin to extract from the spectrum';
    alginfo.inputs(pid).alternative = 2;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    % compesate timestamp phase shift:
    alginfo.inputs(pid).name = 'comp_timestamp';
    alginfo.inputs(pid).desc = 'Enable compensation of phase by timestamp (default off)';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;

    
    % ADC setup
    alginfo.inputs(pid).name = 'adc_bits';
    alginfo.inputs(pid).desc = 'ADC resolution';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
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
    
    alginfo.inputs(pid).name = 'y';
    alginfo.inputs(pid).desc = 'Sampled values';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'y_lo';
    alginfo.inputs(pid).desc = 'Sampled values';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'time_shift_lo';
    alginfo.inputs(pid).desc = 'Low-side channel timeshift';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % relative time stamp of reference channel ('y'):
    alginfo.inputs(pid).name = 'time_stamp';
    alginfo.inputs(pid).desc = 'Relative time-stamp of ''y''';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % --- flags:
    % note: presence of these parameters signalizes caller capabilities of the algoirthm
     
    alginfo.inputs(pid).name = 'support_diff';
    alginfo.inputs(pid).desc = 'Algorithm supports differential input data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    %alginfo.inputs(pid).name = 'support_multi_inputs';
    %alginfo.inputs(pid).desc = 'Algorithm supports processing of a multiple waveforms at once';
    %alginfo.inputs(pid).alternative = 0;
    %alginfo.inputs(pid).optional = 1;
    %alginfo.inputs(pid).parameter = 0;
    %pid = pid + 1;
    
    
    % --- parameters:
    
    % ADC setup
    alginfo.inputs(pid).name = 'adc_bits';
    alginfo.inputs(pid).desc = 'ADC resolution';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_nrng';
    alginfo.inputs(pid).desc = 'ADC nominal range';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_lsb';
    alginfo.inputs(pid).desc = 'ADC LSB voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');  
    
    
    % ADC gain calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_gain_f';
    alginfo.inputs(pid).desc = 'ADC gain transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_gain_a';
    alginfo.inputs(pid).desc = 'ADC gain transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_gain';
    alginfo.inputs(pid).desc = 'ADC gain transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC phase calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_phi_f';
    alginfo.inputs(pid).desc = 'ADC phase transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_phi_a';
    alginfo.inputs(pid).desc = 'ADC phase transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_phi';
    alginfo.inputs(pid).desc = 'ADC phase transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC SFDR (2D dependence, rows: fund. freqs., columns: fund. harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_sfdr_f';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_sfdr_a';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental harmonic amplitude';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_sfdr';
    alginfo.inputs(pid).desc = 'ADC SFDR: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC input admittance matrices (1D dependences, rows: freqs.)
    alginfo.inputs(pid).name = 'adc_Yin_f';
    alginfo.inputs(pid).desc = 'ADC input admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_Yin_Cp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_Yin_Gp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel conductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % Transducer type string (empty: no tran. correction; 'shunt': current shunt; 'rvd': resistive voltage divider)
    alginfo.inputs(pid).name = 'tr_type';
    alginfo.inputs(pid).desc = 'Transducer type string';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;    
    
    % Transducer phase calibration matrix (2D dependence, rows: freqs., columns: input rms levels)
    alginfo.inputs(pid).name = 'tr_gain_f';
    alginfo.inputs(pid).desc = 'Transducer gain: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_gain_a';
    alginfo.inputs(pid).desc = 'Transducer gain: rms level axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_gain';
    alginfo.inputs(pid).desc = 'Transducer gain: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % Transducer phase calibration matrix (2D dependence, rows: freqs., columns: input rms levels)
    alginfo.inputs(pid).name = 'tr_phi_f';
    alginfo.inputs(pid).desc = 'Transducer phase transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_phi_a';
    alginfo.inputs(pid).desc = 'Transducer phase transfer: rms level axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_phi';
    alginfo.inputs(pid).desc = 'Transducer phase transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % RVD low-side impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Zlo_f';
    alginfo.inputs(pid).desc = 'RVD low-side impedance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Zlo_Rp';
    alginfo.inputs(pid).desc = 'RVD low-side impedance: parallel resistance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Zlo_Cp';
    alginfo.inputs(pid).desc = 'RVD low-side impedance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % Transducer output terminals series impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Zca_f';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Zca_Ls';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance: series inductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Zca_Rs';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance: series resistance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % Transducer output terminals shunting admittance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Yca_f';
    alginfo.inputs(pid).desc = 'Transducer terminals shunting admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Yca_Cp';
    alginfo.inputs(pid).desc = 'Transducer terminals shunting admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Yca_D';
    alginfo.inputs(pid).desc = 'Transducer terminals shunting admittance: loss tangent';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % Cable(s) series impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'Zcb_f';
    alginfo.inputs(pid).desc = 'Cables series impedance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'Zcb_Ls';
    alginfo.inputs(pid).desc = 'Cables series impedance: series inductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'Zcb_Rs';
    alginfo.inputs(pid).desc = 'Cables series impedance: series resistance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % Cable(s) shunting admittance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'Ycb_f';
    alginfo.inputs(pid).desc = 'Cables shunting admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'Ycb_Cp';
    alginfo.inputs(pid).desc = 'Cables shunting admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'Ycb_D';
    alginfo.inputs(pid).desc = 'Cables series impedance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    
    
    
    
    
    pid = 1;
    % outputs
    alginfo.outputs(pid).name = 'rms';
    alginfo.outputs(pid).desc = 'RMS value';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'f';
    alginfo.outputs(pid).desc = 'spectrum frequency axis';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'amp';
    alginfo.outputs(pid).desc = 'spectrum amplitdue';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'phi';
    alginfo.outputs(pid).desc = 'spectrum phase [rad]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'bin_f';
    alginfo.outputs(pid).desc = 'Frequency of extracted DFT bin';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'bin_A';
    alginfo.outputs(pid).desc = 'Amplitude of extracted DFT bin';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'bin_phi';
    alginfo.outputs(pid).desc = 'Phase of extracted DFT bin';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'bin_thd';
    alginfo.outputs(pid).desc = 'THD [%] related to the component ''bin_f''';
    pid = pid + 1;
    
    
    alginfo.providesGUF = 0;
    alginfo.providesMCM = 0;

end


% create a differential complement of the last input parameter
function [par,pid] = add_diff_par(par,pid,prefix,name_prefix)
    par.inputs(pid) = par.inputs(pid - 1);
    par.inputs(pid).name = [prefix par.inputs(pid).name];
    par.inputs(pid).desc = [name_prefix par.inputs(pid).desc];
    pid = pid + 1;    
end



