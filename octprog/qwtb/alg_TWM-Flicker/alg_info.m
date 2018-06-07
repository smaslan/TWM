function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm TWM-Flicker.
%
% See also qwtb

    alginfo.id = 'TWM-Flicker';
    alginfo.name = 'TWM tool wrapper: Flicker algorithm';
    alginfo.desc = 'Calculates instantaneous flicker sensation Pinst and short-term flicker severity Pst.';
    alginfo.citation = 'Implemented according: IEC 61000-4-15, Electromagnetic compatibility (EMC), Testing and measurement techniques, Flickermeter, Edition 2.0, 2010-08; Wilhelm Mombauer: "Messung von Spannungsschwankungen und Flickern mit dem IEC-Flickermeter", ISBN 3-8007-2525-8, VDE-Verlag; Solcept Open Source Flicker Measurement-Simulator https://www.solcept.ch/en/tools/flickersim/; NPL Reference Flickermeter Design http://www.npl.co.uk/electromagnetics/electrical-measurement/products-and-services/npl-reference-flickermeter-design';
alginfo.remarks = 'If sampling frequency |fs| is not supplied, wrapper will calculate |fs| from sampling time |Ts| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|. Sampling frequency has to be higher than 7 kHz. If sampling f. is higher than 23 kHz, signal will be down sampled by algorithm. More than 600 s of signal is required. Requires either Signal Processing Toolbox when run in MATLAB or signal package when run in GNU Octave. Frequency of line (carrier frequency) |f_line| can be only 50 or 60 Hz';  
    alginfo.license = 'Boost Software License';

    
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
    
    alginfo.inputs(pid).name = 'y';
    alginfo.inputs(pid).desc = 'Sampled values';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'y_lo';
    alginfo.inputs(pid).desc = 'Sampled values - low-side';
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
    
    
    
    % --- parameters:
    alginfo.inputs(pid).name = 'f_line';
    alginfo.inputs(pid).desc = 'Line frequency';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    
    
    % --- flags {support_multi_inputs, support_diff}:
    % note: presence of these parameters signalizes caller capabilities of the algorithm
     
%     alginfo.inputs(pid).name = 'support_diff';
%     alginfo.inputs(pid).desc = 'TWM control flag: supports differential input data';
%     alginfo.inputs(pid).alternative = 0;
%     alginfo.inputs(pid).optional = 1;
%     alginfo.inputs(pid).parameter = 0;
%     pid = pid + 1;
    
    
    
    % --- correction data:
        
    % ADC setup:
    alginfo.inputs(pid).name = 'adc_bits';
    alginfo.inputs(pid).desc = 'ADC resolution';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_nrng';
    alginfo.inputs(pid).desc = 'ADC nominal range';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_lsb';
    alginfo.inputs(pid).desc = 'ADC LSB voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC jitter:
    alginfo.inputs(pid).name = 'adc_jitter';
    alginfo.inputs(pid).desc = 'ADC rms jitter';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC offset [V]:
    alginfo.inputs(pid).name = 'adc_offset';
    alginfo.inputs(pid).desc = 'ADC offset voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    
    % ADC apperture effect correction:
    % this set to non-zero value will enable auto correction of the aperture effect by algorithm
    alginfo.inputs(pid).name = 'adc_aper_corr';
    alginfo.inputs(pid).desc = 'ADC aperture effect correction switch';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    % apperture value must be passed if the 'adc_aper_corr' is non-zero:
    alginfo.inputs(pid).name = 'adc_aper';
    alginfo.inputs(pid).desc = 'ADC aperture value';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;       
    
    % ADC gain calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes):
    alginfo.inputs(pid).name = 'adc_gain_f';
    alginfo.inputs(pid).desc = 'ADC gain transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_gain_a';
    alginfo.inputs(pid).desc = 'ADC gain transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_gain';
    alginfo.inputs(pid).desc = 'ADC gain transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC phase calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_phi_f';
    alginfo.inputs(pid).desc = 'ADC phase transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_phi_a';
    alginfo.inputs(pid).desc = 'ADC phase transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_phi';
    alginfo.inputs(pid).desc = 'ADC phase transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC SFDR (2D dependence, rows: fund. freqs., columns: fund. harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_sfdr_f';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_sfdr_a';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental harmonic amplitude';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_sfdr';
    alginfo.inputs(pid).desc = 'ADC SFDR: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC input admittance matrices (1D dependences, rows: freqs.)
    alginfo.inputs(pid).name = 'adc_Yin_f';
    alginfo.inputs(pid).desc = 'ADC input admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_Yin_Cp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    alginfo.inputs(pid).name = 'adc_Yin_Gp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel conductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    %[alginfo,pid] = add_diff_par(alginfo,pid,'lo_','Low ');
    
    % ADC timebase frequency correction:
    alginfo.inputs(pid).name = 'adc_freq';
    alginfo.inputs(pid).desc = 'ADC timebase freq. correction';
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
    
    % Transducer output terminals series impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Zcal_f';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance (low side): frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Zcal_Ls';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance (low side): series inductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Zcal_Rs';
    alginfo.inputs(pid).desc = 'Transducer terminals series impedance (low side): series resistance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % Transducer output terminals mutual impedance matrix (1D dependence, rows: freqs.)
    alginfo.inputs(pid).name = 'tr_Zcam_f';
    alginfo.inputs(pid).desc = 'Transducer terminals mutual inductance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'tr_Zcam';
    alginfo.inputs(pid).desc = 'Transducer terminals mutual inductance';
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
    
    alginfo.outputs(pid).name = 'Pst';
    alginfo.outputs(pid).desc = 'Short-term flicker severity';
    pid = pid + 1;

    alginfo.outputs(pid).name = 'Pinst';
    alginfo.outputs(pid).desc = 'Instantaneous flicker sensation';
    pid = pid + 1;
    
    alginfo.providesGUF = 1;
    alginfo.providesMCM = 0;

end


% create a differential complement of the last input parameter
function [par,pid] = add_diff_par(par,pid,prefix,name_prefix)
    par.inputs(pid) = par.inputs(pid - 1);
    par.inputs(pid).name = [prefix par.inputs(pid).name];
    par.inputs(pid).desc = [name_prefix par.inputs(pid).desc];
    pid = pid + 1;    
end



