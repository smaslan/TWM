function INL = ProcessHistogramTest(dsc,display_settings,varargin)
% @fn ProcessHistogramtest
% @brief Processes measurement descriptor using histogram test with
%        sinusoidal excitation signal
% @param dsc The measurement descriptor to process
% @param display_settings A struct sets the options for each window to
%                           appear or not
%            warning_dialog : Warning_dialog box
%            results_win: Results window
%            summary_win: summary window            
% @param varargin Additional paramemetrs to be passed:
%            varargin{1} = estimate_ratio: the ratio of histogram bins not used to
%               estimate the amplitude and the DC component
%            varargin{2} = edge_cut: the INL values near the peak values
%               of the sine wave may be inaccurate accirding to the noise of
%               the measurement. These INL values will not be estimated.
%               edge_cutoff determines the ratio of INL values not to be
%               estimated
%            
% @return none
% @author Tam�s Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu

% ProcessHistogramTest (dsc,display_settings,estimate_ratio,edge_cut);

if (nargin == 3) %estimate_ratio is passed
    ESTIMATE_RATIO = varargin{1};
    EDGE_CUT = 0.08;
elseif (nargin == 4) %edge_cut is passed
    ESTIMATE_RATIO = varargin{1};
    EDGE_CUT = varargin{2};
else %no addtional parameters passed, or incorrect call of ProcessHistogramtest()
    ESTIMATE_RATIO = 0.08;
    EDGE_CUT = 0.08;    
end
screensize = get(0,'ScreenSize');

%Pre-processing time domain data:
%ADC codes must be positive integers to perform PosIntHist
if (min(dsc.data) < 0)
   dsc.data = dsc.data + (0 - min(dsc.data)) ;
   warndlg('ADC codes are not nonnegative integers. Added %d to each code to process histogram test')%, (0 - min(dsc.data)));
end

if ((min(dsc.data) < 0) || (max(dsc.data) > 2^dsc.NoB - 1))
    warndlg('Mismatch between number of bits provided and ADC codes in the measurement record');
end
%Adding code offset +1 to process PosintHist in histogram test
dsc.data = dsc.data + 1;

h = PosIntHist(dsc.data);
nh = h/sum(h); %Normalized histogram;
nch = zeros(2^dsc.NoB,1);
acc = 0;
for k = 1:length(nh)
    acc = acc + nh(k);
    nch(k) = acc;
end
%End of the normalized cumulative histogram shall be filled with ones:
nch(length(nh)+1:end) = ones(length(nch) - length(nh),1);

ideal_trans_levels = linspace(0,1,(2^dsc.NoB-1)).';
%Finding transition levels assumed to be correct:
[val,ind_low] = min(abs(nch - ESTIMATE_RATIO));
[val,ind_high] = min(abs(nch - (1 - ESTIMATE_RATIO)));
if (ind_low < 1)
    ind_low = 1;
end
if (ind_high > 2^dsc.NoB - 1)
    ind_high = 2^dsc.NoB -1;
end
%Transition levels between T[m] and T[l] are used to estimate A and Mu
%Finding the optimal solution of these equations in least squares sense:
D = zeros(ind_high-ind_low+1,2);
D(:,1) = ones(ind_high-ind_low+1,1);
for k = ind_low:ind_high
    D(k-ind_low+1,2) = -cos(pi*nch(k));
end
p = inv(D.'*D)*D.'*ideal_trans_levels(ind_low:ind_high); %p = [mu;A] = inv(D.'*D)*D.'*T(ind_low:ind_high);

trans_levels = zeros(2^dsc.NoB-1,1);
small = 0.1/sum(h); %Effect of "0.1 sample" in the normalized histogram
for k = 1:length(trans_levels)
    if (abs((nch(k)) - 0) < small) % there are no code bins tested below this transition level
        trans_levels(k) = NaN;
    elseif (abs(nch(k) - 1) < small) %thereare no code bins tested above this transition level
        trans_levels(k) = NaN;
    else trans_levels(k) = p(1) - p(2)*cos(pi*nch(k));
    end
end

q = 1/(2^dsc.NoB - 2);
INL = (trans_levels - ideal_trans_levels)/q;

%Discarding uncertain values of INL near the edge of the sine wave
for k = 1:length(INL)
    if ((nch(k) < EDGE_CUT) || (nch(k)) > (1 - EDGE_CUT))
        INL(k) = NaN;
    end
end

%Calibrating INL values to the lowest and highest transition level estimated.
lowest_estimated = find(~isnan(INL),1,'first');
highest_estimated = find(~isnan(INL),1,'last');
INL_calib = [zeros(lowest_estimated-1,1);linspace(INL(lowest_estimated),INL(highest_estimated),highest_estimated-lowest_estimated+1).';zeros(length(INL)-highest_estimated,1)];
INL = INL - INL_calib;
DNL = diff(INL);

%RESULTS WINDOW
%Displaying histogram test results
if (display_settings.results_win)
    histogram_results_window = figure('Visible','on',...
        'Position', [screensize(3)*0.1 screensize(4)*0.1 screensize(3)*0.8 screensize(4)*0.8]',...
        'Name','Histogram Test Results',...
        'NumberTitle','off');
    hAxesINL = axes('Position',[0.1 0.6 0.8 0.3]);
    hAxesDNL = axes('Position',[0.1 0.1 0.8 0.3]);

    set(histogram_results_window,'CurrentAxes',hAxesINL);
    plot(1:length(INL),INL);
    xlabel('Transition levels');
    ylabel('INL[k]');
    title('Integral nonlinearity');
    axis([0 length(INL)+1 min(INL) max(INL)]);
    %
    set(histogram_results_window,'CurrentAxes',hAxesDNL);
    plot((1:length(DNL)),DNL);
    xlabel('Code bins');
    ylabel('DNL[k]');
    title('Differential nonlinearity');
    axis([0 length(DNL)+1 min(DNL) max(DNL)]);
end

%SUMMARY WINDOW
%Displaying necessary information about the quality of estimation:
if (display_settings.summary_win)
    histogram_summary_window = figure('Visible','on',...
        'Position', [screensize(3)*0.25 screensize(4)*0.25 screensize(3)*0.5 screensize(4)*0.5]',...
        'Name','Histogram Test Summary',...
        'NumberTitle','off');

    hTextTitle = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.3 0.85 0.4 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Quantitative traits of histogram test',...
        'FontWeight','bold',...
        'FontSize',9,...
        'HorizontalAlignment','center');

    hTextNumOfSamples = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.7 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Number of samples: ',...
        'HorizontalAlignment','left');

    hTextNumOfSamplesValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.35 0.7 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hTextAvgSamplePerCodeBin = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.6 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Average number of samples in a code bin: ',...
        'HorizontalAlignment','left');

    hTextAvgSamplePerCodeBinValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.35 0.6 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hTextLowestTransLevelEst = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.5 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Lowest transition level estimated: ',...
        'HorizontalAlignment','left');

    hTextLowestTransLevelEstValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.35 0.5 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hTextHighestTransLevelEst = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.05 0.4 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Highest transition level estimated: ',...
        'HorizontalAlignment','left');

    hTextHighestTransLevelEstValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.35 0.4 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hTextNumOfPeriods = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.55 0.7 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Number of periods: ',...
        'HorizontalAlignment','left');

    hTextNumOfPeriodsValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.85 0.7 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hTextFractPeriodRatio = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.55 0.6 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Ratio of samples in fractional periods: ',...
        'HorizontalAlignment','left');

    hTextFractPeriodRatioValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.85 0.6 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hTextLowestNumOfSamples = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.55 0.5 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Lowest number of samples in a code bin: ',...
        'HorizontalAlignment','left');

    hTextLowestNumOfSamplesValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.85 0.5 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hTextHighestNumOfSamples = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.55 0.4 0.3 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','Highest number of samples in a code bin: ',...
        'HorizontalAlignment','left');

    hTextHighestNumOfSamplesValue = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.85 0.4 0.1 0.08],...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','NaN',...
        'HorizontalAlignment','right');

    hPushButtonOk = uicontrol ('Style', 'pushbutton',...
        'Units','normalized',...
        'Position', [0.43 0.1 0.14 0.1],...
        'String','OK',...
        'Callback',@OK_callback);

    %Calculating data for Histogram Summary:
    avg_sample_per_code_bin = length(dsc.data)/(2^dsc.NoB);
    est_freq = EstimateFreqBH3Ipfft(dsc.data);
    num_of_periods = est_freq*length(dsc.data);
    fractional_ratio = min(... %fractional part or missing fractional part
        (num_of_periods - floor(num_of_periods))/num_of_periods,...
        (ceil(num_of_periods) - num_of_periods)/num_of_periods);
    lowest_density = min(h); %Maximal value of histogram
    highest_density = max(h); %Minimal value of histogram

    %Filling fields with information:
    set (hTextNumOfSamplesValue,'String',sprintf('%d',length(dsc.data)));
    set (hTextAvgSamplePerCodeBinValue,'String',sprintf('%3.2f',avg_sample_per_code_bin));
    set (hTextLowestTransLevelEstValue,'String',sprintf('%d',lowest_estimated));
    set (hTextHighestTransLevelEstValue,'String',sprintf('%d',highest_estimated));
    set (hTextNumOfPeriodsValue,'String',sprintf('%3.5f',num_of_periods));
    set (hTextFractPeriodRatioValue,'String',sprintf('%1.3e',fractional_ratio));
    set (hTextLowestNumOfSamplesValue,'String',sprintf('%d',lowest_density));
    set (hTextHighestNumOfSamplesValue,'String',sprintf('%d',highest_density));
end

%WARNING DIALOGS (if necessary)
if (display_settings.warning_dialog)
    if ((lowest_estimated ~= 1) || (highest_estimated ~= 2^dsc.NoB - 1))
        warndlg({'The device is not overdriven enough';...
            sprintf('Transition levels under %d and over %d cannot be estimated',lowest_estimated,highest_estimated);...
            'At least 120% full scale overdive is recommended';...
            'Non estimated INL values vill be assumed to be 0';...
            'Results of histogram test may be less accurate than desired'},...
            'Histogram test warning');
    end
    if (avg_sample_per_code_bin < 10)
        warndlg({sprintf('Average sample per code bin is few (%1.2f)',avg_sample_per_code_bin);...
            'Results of histogram test may be less accurate than desired'},...
            'Histogram test warning');
    end
    if (fractional_ratio > 1e-2)
        warndlg({'Ratio of samples in fractional period is too high';...
            sprintf('%1.3e',fractional_ratio);
            'Results of histogram test may be less accurate than desired'},...
            'Histogram test warning')
    end
end

%%%%%%%%%Adding evaluation result to results cell array:
try
    testresults = evalin('base','adctest_process_results');
    res_len = size(testresults,1);
    %Search for existing results block
    existings_index = 0;
    for k = 1:res_len        
        if strcmpi(dsc.model,testresults{k,1}.DUT.model) ...
                && strcmpi(dsc.serial,testresults{k,1}.DUT.serial)...
                && (dsc.channel == testresults{k,1}.DUT.channel)...
                && (dsc.NoB == testresults{k,1}.DUT.NoB)
            existings_index = k;                    
        end
    end    
    if (existings_index ~= 0) %existing result struct
        %Adding new results:
        testresults{existings_index,1}.INL.max = max(INL);
        testresults{existings_index,1}.INL.min = min(INL);                
        testresults{existings_index,1}.DNL.max = max(DNL);
        testresults{existings_index,1}.DNL.min = min(DNL);                        
    else %new result struct shall be added
        testresults{res_len + 1,1}.DUT.model = dsc.model;
        testresults{res_len + 1,1}.DUT.serial = dsc.serial;
        testresults{res_len + 1,1}.DUT.channel = dsc.channel;
        testresults{res_len + 1,1}.DUT.NoB = dsc.NoB;
        %Adding new results:
        testresults{res_len + 1,1}.INL.max = max(INL);
        testresults{res_len + 1,1}.INL.min = min(INL);        
        testresults{res_len + 1,1}.DNL.max = max(DNL);
        testresults{res_len + 1,1}.DNL.min = min(DNL);                                
    end
    %updating adctest_process_results
    assignin ('base','adctest_process_results',testresults);
        
catch
    %If testresults global variable does not exist:
    testresults = cell(1,1); %creating new cell array for testresults
    testresults{1,1}.DUT.model = dsc.model;
    testresults{1,1}.DUT.serial = dsc.serial;
    testresults{1,1}.DUT.channel = dsc.channel;
    testresults{1,1}.DUT.NoB = dsc.NoB;
    %Adding new results:
    testresults{1,1}.INL.max = max(INL);
    testresults{1,1}.INL.min = min(INL);
    testresults{1,1}.DNL.max = max(DNL);
    testresults{1,1}.DNL.min = min(DNL);    
    assignin ('base','adctest_process_results',testresults);
end
%%%%%%End of adding evaluatin results to cell array%%%%%%%%%%

%Callbacks: (for histogram_summary_window)
    function OK_callback(source,eventdata)
        close(histogram_summary_window);
    end

end
