# TWM - TracePQM Wattmeter

TWM is developed in scope of [EMPIR](https://msu.euramet.org/calls.html) project [TracePQM](http://tracepqm.cmi.cz/).

TWM is application designed for traceable measurement of electric power and power quality (PQ) parameters. It is composed of two components:
- User interface and instrument control in [LabVIEW](http://www.ni.com/labview/),
- [GNU Octave](https://www.gnu.org/software/octave/) or [Matlab](https://uk.mathworks.com/products/matlab.html) calculation scripts for data processing.

Both components are connected together into single interactive application using [GOLPI](https://github.com/KaeroDot/GOLPI) interface. Note the current version does not support Matlab yet. Only GNU Octave is supported.

The TWM concept is modular, so it can be simply extended by various digitizer drivers while the rest of the application stays unchanged. In the current version the TWM supports:
- [niScope](http://sine.ni.com/nips/cds/view/p/lang/cs/nid/12638) drivers for control of NI's PXI-5922 digitizer,
- Synchronized [HP/Agilent/Keysight 3458A](https://www.keysight.com/en/pd-1000001297%3Aepsg%3Apro-pn-3458A/digital-multimeter-8-digit?cc=US&lc=eng) sampling multimeters,
- [DirectSound](http://www.elektronika.kvalitne.cz/SW/dsdll/dsdll_eng.html) driver for ordinary soundcard,
- Simulated digitizer for debug purposes.

Modularity of the power and PQ calculation algorithms used by the TWM is ensured by the [QWTB](https://qwtb.github.io/qwtb/) toolbox.

## License
The TWM is distributed under [MIT license](./LICENSE.txt). Note the algorithms in the QWTB toolbox may have different licenses. 
  
  