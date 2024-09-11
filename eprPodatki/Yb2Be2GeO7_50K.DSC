#DESC	1.2 * DESCRIPTOR INFORMATION ***********************
*
*	Dataset Type and Format:
*
DSRC	EXP
BSEQ	BIG
IKKF	REAL
XTYP	IDX
YTYP	NODATA
ZTYP	NODATA
*
*	Item Formats:
*
IRFMT	D
*
*	Data Ranges and Resolutions:
*
XPTS	2048
XMIN	50.000000
XWID	11900.000000
*
*	Documentational Text:
*
TITL	'Yb2Be2GeO7_40K'
IRNAM	'1st Harm  0deg Abs'
XNAM	'Field'
IRUNI	''
XUNI	'G'
*
************************************************************
*
#SPL	1.2 * STANDARD PARAMETER LAYER
*
OPER    xuser
DATE    08/27/24
TIME    14:56:18
CMNT    
SAMP    
SFOR    
STAG    C
EXPT    CW
OXS1    IADC
AXS1    B0VL
AXS2    NONE
AXS3    
A1CT    0.6
A1SW    1.19
MWFQ    9.694897e+09
MWPW    0.001003
AVGS    1
SPTP    0.042
RCAG    60
RCHM    1
B0MA    0.0001
B0MF    100000
RCPH    0.0
RCOF    0.0
A1RS    2048
RCTC    0
*
************************************************************
*
#DSL	1.0 * DEVICE SPECIFIC LAYER
*

.DVC     acqStart, 1.0


.DVC     fieldCtrl, 1.0

AllegroMode        True
CenterField        6000.00 G
Delay              0.0 s
FieldFlyback       On
FieldWait          Wait LED off
GFactor            2.000000
MeasuringHall      False
SetToSampleG       False
StaticFieldMon     50.000 G
SweepDirection     Up
SweepWidth         11900.0 G
WidthTM            200.0 G

.DVC     fieldSweep, 1.0


.DVC     freqCounter, 1.0

FrequencyMon       9.694897 GHz
QMonitBridge       On

.DVC     mwBridge, 1.0

AcqFineTuning      Never
AcqScanFTuning     Off
AcqSliceFTuning    Off
BridgeCalib        100.0
Power              1.003 mW
PowerAtten         23 dB
QValue             200

.DVC     recorder, 1.0

BaselineCorr       Off
NbScansAcc         1
NbScansDone        1
NbScansToDo        1
ReplaceMode        Off
SmoothMode         Manual
SmoothPoints       1

.DVC     scanEnd, 1.0


.DVC     signalChannel, 1.0

AFCTrap            True
AllegroMode        True
AllowShortCt       False
Calibrated         True
ConvFact           1
ConvTime           42.00 ms
DModDetectSCT      First
DoubleModAcc       1
DoubleModFreq      5.000 kHz
DoubleMode         False
DualDetect         OFF
EliDelay           1.0 us
Enable1stHarm      True
Enable1stHarm90    False
Enable2ndHarm      False
Enable2ndHarm90    False
Enable3rdHarm      False
Enable3rdHarm90    False
Enable4thHarm      False
Enable4thHarm90    False
Enable5thHarm      False
Enable5thHarm90    False
EnableDisp         False
EnableImag         Disable
ExtLockIn          False
ExtTrigger         False
Gain               60 dB
GainB              60 dB
Harmonic           1
HighPass           True
InputPlugA         AC3
InputPlugB         AC3
Integrator         False
IsCalibExp         False
ModAmp             1.000 G
ModFreq            100.00 kHz
ModPhase           0.0
Offset             0.0 %
PolyCof            {2;3,9;0} 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
QuadMode           False
ResCenter          62.5 mm
ResLength          20 mm
Resolution         2048
Resonator          1
SctNorm            True
SctRevision        Allegro
SetAllOrd          False
SetOrdDef          False
SpuExtension       True
SpuRevision        MultiHarmonic
SweepTime          86.01600 s
TimeConst          0
TimeExp            False
TuneCaps           34
dModSW             True

*
************************************************************
