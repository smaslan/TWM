function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm TWM-RATWFFT.
%
% See also qwtb

    alginfo.id = 'TWM-RATWFFT';
    alginfo.name = 'Vector ratio by windowed FFT.';
    alginfo.desc = 'It calculates complex voltage ratio of U/I channels using TWM-WFFT algorithm. It should work even for non-coherent sampling when non-rectangular window is used. ';
    alginfo.citation = '';
    alginfo.remarks = 'Note properly tested!';
    alginfo.license = 'MIT';
    
    
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
    alginfo.inputs(pid).desc = 'Sampled signal A';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'u_lo';
    alginfo.inputs(pid).desc = 'Sampled signal U low-side';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
           
    alginfo.inputs(pid).name = 'u_time_shift_lo';
    alginfo.inputs(pid).desc = 'Low-side channel timeshift for U';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'i';
    alginfo.inputs(pid).desc = 'Sampled signal U';
    alginfo.inputs(pid).alternative = 0;       
    alginfo.inputs(pid).optional = 0;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'i_lo';
    alginfo.inputs(pid).desc = 'Sampled signal I low-side';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;    
    
    alginfo.inputs(pid).name = 'i_time_shift_lo';
    alginfo.inputs(pid).desc = 'Low-side channel timeshift for I';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    alginfo.inputs(pid).name = 'time_shift';
    alginfo.inputs(pid).desc = 'u/i channel timeshift';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    
    % --- configuration:
    % nominal frequency to analyse
    alginfo.inputs(pid).name = 'f_nom';
    alginfo.inputs(pid).desc = 'Nominal frequency [Hz]';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    
    % relative harmonic frequencies (f_nom.*h_num)
    alginfo.inputs(pid).name = 'h_num';
    alginfo.inputs(pid).desc = 'Relative harmonic frequencies';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    
    % window type
    alginfo.inputs(pid).name = 'window';
    alginfo.inputs(pid).desc = 'Name of window function';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 1;
    pid = pid + 1;
    
    % invert phase function:
    alginfo.inputs(pid).name = 'invert';
    alginfo.inputs(pid).desc = 'Set when one of the channels has inversed polarity';
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
    
    alginfo.inputs(pid).name = 'support_multi_inputs';
    alginfo.inputs(pid).desc = 'Algorithm supports processing of a multiple waveforms at once';
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
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
        
    alginfo.inputs(pid).name = 'adc_nrng';
    alginfo.inputs(pid).desc = 'ADC nominal range';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
        
    alginfo.inputs(pid).name = 'adc_lsb';
    alginfo.inputs(pid).desc = 'ADC LSB voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    % ADC jitter:
    alginfo.inputs(pid).name = 'adc_jitter';
    alginfo.inputs(pid).desc = 'ADC rms jitter';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    % ADC apperture effect correction:
    % this set to non-zero value will enable auto correction of the aperture effect by algorithm
    alginfo.inputs(pid).name = 'adc_aper_corr';
    alginfo.inputs(pid).desc = 'ADC aperture effect correction switch';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
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
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    % ADC offset [V]:
    alginfo.inputs(pid).name = 'adc_offset';
    alginfo.inputs(pid).desc = 'ADC offset voltage';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
          
    
    % ADC gain calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_gain_f';
    alginfo.inputs(pid).desc = 'ADC gain transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_gain_a';
    alginfo.inputs(pid).desc = 'ADC gain transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_gain';
    alginfo.inputs(pid).desc = 'ADC gain transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);     
    
    % ADC phase calibration matrix (2D dependence, rows: freqs., columns: harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_phi_f';
    alginfo.inputs(pid).desc = 'ADC phase transfer: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_phi_a';
    alginfo.inputs(pid).desc = 'ADC phase transfer: voltage axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_phi';
    alginfo.inputs(pid).desc = 'ADC phase transfer: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    % ADC SFDR (2D dependence, rows: fund. freqs., columns: fund. harmonic amplitudes)
    alginfo.inputs(pid).name = 'adc_sfdr_f';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_sfdr_a';
    alginfo.inputs(pid).desc = 'ADC SFDR: fundamental harmonic amplitude';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_sfdr';
    alginfo.inputs(pid).desc = 'ADC SFDR: 2D data';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    % ADC input admittance matrices (1D dependences, rows: freqs.)
    alginfo.inputs(pid).name = 'adc_Yin_f';
    alginfo.inputs(pid).desc = 'ADC input admittance: frequency axis';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_Yin_Cp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel capacitance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    alginfo.inputs(pid).name = 'adc_Yin_Gp';
    alginfo.inputs(pid).desc = 'ADC input admittance: parallel conductance';
    alginfo.inputs(pid).alternative = 0;
    alginfo.inputs(pid).optional = 1;
    alginfo.inputs(pid).parameter = 0;
    pid = pid + 1;
    [alginfo,pid] = add_diff_par(alginfo,pid,'lo_','low ');
    [alginfo,pid] = add_ui_pair(alginfo,pid,1);
    
    
    
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
    alginfo.outputs(pid).desc = 'Selected DFT bin frequencies';
    pid = pid + 1;    
    
    alginfo.outputs(pid).name = 'U';
    alginfo.outputs(pid).desc = 'U channel amplitude(s)';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'I';
    alginfo.outputs(pid).desc = 'I channel amplitude(s)';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Udc';
    alginfo.outputs(pid).desc = 'DC component of U channel';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'Idc';
    alginfo.outputs(pid).desc = 'DC component of I channel';
    pid = pid + 1;
        
    alginfo.outputs(pid).name = 'r';
    alginfo.outputs(pid).desc = 'U/I amplitude ratio [rad]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'dph';
    alginfo.outputs(pid).desc = 'U-I phase difference';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'dT';
    alginfo.outputs(pid).desc = 'U-I time shift [s]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 're';
    alginfo.outputs(pid).desc = 'U/I ratio real part [V/V]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'im';
    alginfo.outputs(pid).desc = 'U/I ratio imaginary part [V/V]';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'spec_f';
    alginfo.outputs(pid).desc = 'Full spectrum frequency';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'spec_U';
    alginfo.outputs(pid).desc = 'Full spectrum U-amplitudes';
    pid = pid + 1;
    
    alginfo.outputs(pid).name = 'spec_I';
    alginfo.outputs(pid).desc = 'Full spectrum I-amplitudes';
    pid = pid + 1;
        
    
    alginfo.providesGUF = 1;
    alginfo.providesMCM = 0;    

end


% create a differential complement of the last input parameter in the list 'par'
function [par,pid] = add_diff_par(par,pid,prefix,name_prefix)
    par.inputs(pid) = par.inputs(pid - 1);
    par.inputs(pid).name = [prefix par.inputs(pid).name];
    par.inputs(pid).desc = [name_prefix par.inputs(pid).desc];
    pid = pid + 1;    
end

% creates pair of voltage/current inputs from last quantity in the list 'par'
function [par,pid] = add_ui_pair(par,pid,has_lo)
    
    
    if has_lo
        ref_hi = par.inputs(pid-2);
        ref_lo = par.inputs(pid-1);      
        par.inputs(pid-2) = ref_hi;
        par.inputs(pid-2).name = ['u_' ref_hi.name];
        par.inputs(pid-2).desc = ['Voltage ' ref_hi.desc];                
        par.inputs(pid-1) = ref_lo;
        par.inputs(pid-1).name = ['u_' ref_lo.name];
        par.inputs(pid-1).desc = ['Voltage ' ref_lo.desc];    
        par.inputs(pid) = ref_hi;
        par.inputs(pid).name = ['i_' ref_hi.name];
        par.inputs(pid).desc = ['Current ' ref_hi.desc];
        pid = pid + 1;
        par.inputs(pid) = ref_lo;
        par.inputs(pid).name = ['i_' ref_lo.name];
        par.inputs(pid).desc = ['Current ' ref_lo.desc];
        pid = pid + 1;        
    else
        ref_hi = par.inputs(pid-1);                        
        par.inputs(pid-1) = ref_hi;
        par.inputs(pid-1).name = ['u_' ref_hi.name];
        par.inputs(pid-1).desc = ['Voltage ' ref_hi.desc];                
        par.inputs(pid) = ref_hi;
        par.inputs(pid).name = ['i_' ref_hi.name];
        par.inputs(pid).desc = ['Current ' ref_hi.desc];
        pid = pid + 1;
    end    
    
    
end