function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm CCC
%
% See also qwtb

alginfo.id = 'CCC';
alginfo.name = 'Calibration Curves Computing';
alginfo.desc = 'Calibration Curves Computing is a software for the evaluation of instrument calibration curves and developed at Istituto Nazionale di Ricerca Metrologica (INRIM). The software may be applied to pairs of measurement values of independent/explanatory variable and dependent/explained variable. If uncertainties associated with the data are available, they can be provided as inputs to the software. The regression models which can be addressed by the software are (fractional) polynomial curves. The software can perform the following kind of regression procedures: Ordinary least-squares regression (OLS), Weighted least-squares regression (WLS), Weighted total least-squares regression (WTLS).';
alginfo.citation = 'A. Malengo and F. Pennecchi, A weighted total least-squares algorithm for any fitting model with correlated variables, Metrologia (2013), 50, 654.';
alginfo.remarks = 'If |x| and |y| are matrices: wrapper suppose the measured data are a set of groups organized in such that every row of |x| and |y| is one set of measurement, uncertainties in |x| and |y| are neglected and Model 2b is selected. If you want Model 1b or Model 3b, it must be set in quantitiy |model|. If |x| and |y| are vectors: if uncertainties of |x| are zero and uncertainties of |y| contains all the same numbers, Model 1b is selected; if uncertainties of |x| are zero and uncertainties of |y| contains various numbers, Model 2b is selected; if uncertainties of |x| are nonzero Model 3b is selected. In every case the value of |model| overloads automatic determination of the model.';
alginfo.license = 'Dedicated license';

alginfo.inputs(1).name = 'x';
alginfo.inputs(1).desc = 'Independent/explanatory variable';
alginfo.inputs(1).alternative = 0;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'y';
alginfo.inputs(2).desc = 'Dependent/explained variable';
alginfo.inputs(2).alternative = 0;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 'exponents';
alginfo.inputs(3).desc = 'Exponents of polynomial used to fit, from -5 to 5 including 0, -0.5, 0.5';
alginfo.inputs(3).alternative = 0;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 1;

alginfo.inputs(4).name = 'model';
alginfo.inputs(4).desc = 'Identification of the model. 1a, 2a, 3a, 1b, 2b, 3b.';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 1;
alginfo.inputs(4).parameter = 1;

alginfo.outputs(1).name = 'coefs';
alginfo.outputs(1).desc = 'Fitted coefficients';

alginfo.outputs(2).name = 'exponents';
alginfo.outputs(2).desc = 'Exponents of polynomial used to fit, from -5 to 5 including 0, -0.5, 0.5';

alginfo.outputs(3).name = 'yhat';
alginfo.outputs(3).desc = 'Fitted values y';

alginfo.outputs(4).name = 'func';
alginfo.outputs(4).desc = 'Inline function constructed for exponents with parameters `x` and `coefs.v`';

alginfo.outputs(4).name = 'model';
alginfo.outputs(4).desc = 'Model used for calculation.';

alginfo.providesGUF = 1;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
