# How to implement SFDR from ADCTest_Toolbox

Unofrtunately because of mixed GUI and calculation code and extensive use of global variables
implementation of this algorithm is not easy to do without changing source code.
Therefore:
- function definition was changed from:
        function ProcessFFTTest(dsc)
  to:
        function testresults = ProcessFFTTest(dsc)
- following lines were commented:
  3 - 229
  236
  281 - 307
  321 - 351
  361 - 362

- line 273 was changed from:
        if (get(hPopupMenuWindowing,'Value')==1) %rectangular window is used
  to:
        if 2==1 %% if (get(hPopupMenuWindowing,'Value')==1) %rectangular window is used

last change of line cause the blackman window is always sellected (menuval == 3).
