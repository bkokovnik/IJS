import scipy
from scipy import integrate
import scipy.optimize as opt
from scipy import stats
import numpy as np
from numpy import exp
import matplotlib.pyplot as plt
import scipy.constants as const
import uncertainties as unc
import uncertainties.unumpy as unp
import uncertainties.umath as umath
import math
import pandas as pd
from scipy.odr import *
from scipy.optimize import curve_fit
from scipy.signal import savgol_filter, find_peaks
from scipy.interpolate import interp1d
from typing import Callable


plt.rcParams.update({
    "text.usetex": True,
    "font.family": "Computer Modern Serif",
    "font.size": 18
})

#####################################################################################################################################################

def obtezeno_povprecje(uarray):
    '''Izračuna obteženo povprečje unumpy arraya'''

    vrednosti = unp.nominal_values(uarray)
    negotovosti = unp.std_devs(uarray)

    obtezitev = 1/(negotovosti**2)
    obtezeno_povprecje = np.sum(vrednosti * obtezitev) / np.sum(obtezitev)

    obtezena_negotovost = np.sqrt(np.sum(negotovosti**2 * obtezitev**2) / (np.sum(obtezitev)**2))

    return unc.ufloat(obtezeno_povprecje, obtezena_negotovost)

def fit_fun(B, x):
    a = 1.1 / (8.617 * 10 ** (-5))
    return (1 - 15 / (np.pi) ** 4 * (-(a / x) ** 3 * np.log(1 - np.e ** ( - (a / x))) + (6 + 6 * (a / x) + 3 * (a / x) ** 2) * np.e ** (- (a / x)))) * B[0]

def fit_fun1(b, x):
    a = 1.1 / (8.617 * 10 ** (-5))
    return (1 - 15 / (np.pi) ** 4 * (-(a / x) ** 3 * np.log(1 - np.e ** ( - (a / x))) + (6 + 6 * (a / x) + 3 * (a / x) ** 2) * np.e ** (- (a / x)))) * b

def lin_fun(x, a, b):
    return a * x + b

def lin_fun2(B, x):
    '''Linearna funkcija y = m*x + b'''
    # B is a vector of the parameters.
    # x is an array of the current x values.
    # x is in the same format as the x passed to Data or RealData.
    #
    # Return an array in the same format as y passed to Data or RealData.
    return B[0]*x + B[1]

def exp_fun(B, x):
    """Eksponentna funkcija y = A exp(Bx)"""
    return B[0] * np.exp(B[1] * x**B[2])

def tok_fun(B,x):
    return B[0] * x**B[1] * np.exp( - B[2] / x)

def fit_napake(x: unp.uarray, y: unp.uarray, funkcija=lin_fun2, print=0) -> np.ndarray:

    '''Sprejme 2 unumpy arraya skupaj z funkcijo in izračuna fit, upoštevajoč x in y napake'''
    # Podatki
    x_mik = unp.nominal_values(x)
    y_mik = unp.nominal_values(y)

    x_err_mik = unp.std_devs(x)
    y_err_mik = unp.std_devs(y)

    # Create a model for fitting.
    lin_model_mik = Model(funkcija)

    # Create a RealData object using our initiated data from above.
    data_mik = RealData(x_mik, y_mik, sx=x_err_mik, sy=y_err_mik)

    # Set up ODR with the model and data.
    odr_mik = ODR(data_mik, lin_model_mik, beta0=[0., 3., 1.], maxit=100000)

    # odr_mik.set_job(maxit=10000)

    # Run the regression.
    out_mik = odr_mik.run()

    if print == 1:
        out_mik.pprint()
    
    return out_mik

def fit_napake_x(x: unp.uarray, y: unp.uarray, funkcija=lin_fun2, print=0) -> tuple:
    '''Sprejme 2 unumpy arraya skupaj z funkcijo in izračuna fit, upoštevajoč y napake'''
    optimizedParameters, pcov = opt.curve_fit(funkcija, unp.nominal_values(x), unp.nominal_values(y))#, sigma=unp.std_devs(y), absolute_sigma=True)
    return (optimizedParameters, pcov)

def graf_errorbar(x: unp.uarray, y: unp.uarray, podatki_label="Izmerjeno"):
    '''Sprejme 2 unumpy arraya, fitane parametre in nariše errorbar prikaz podatkov'''
    # Podatki
    x_mik = unp.nominal_values(x)
    y_mik = unp.nominal_values(y)

    x_err_mik = unp.std_devs(x)
    y_err_mik = unp.std_devs(y)

    plt.errorbar(x_mik, y_mik, xerr=x_err_mik, yerr=y_err_mik, linestyle='None', marker='.', capsize=3, label=podatki_label)

def graf_fit_tuple(x: unp.uarray, y: unp.uarray, fit: tuple, fit_label="Fit"):
    '''Sprejme 2 unumpy arraya, fitane parametre in nariše črtkan fit'''
    # Podatki
    x_mik = unp.nominal_values(x)
    y_mik = unp.nominal_values(y)

    x_fit_mik = np.linspace(x_mik[0] - 2 * x_mik[0], x_mik[-1] + x_mik[-1], 1000)

    # y_fit_mik = lin_fun(*(fit[0]), x_fit_mik)
    plt.plot(x_fit_mik, lin_fun(x_fit_mik, *(fit[0])),
          "--", label=fit_label, color="#5e5e5e", linewidth=1)

def graf_fit(x: unp.uarray, y: unp.uarray, fit: np.ndarray, fit_label="Fit"):
    '''Sprejme 2 unumpy arraya, fitane parametre in nariše črtkan fit'''
    # Podatki
    x_mik = unp.nominal_values(x)
    y_mik = unp.nominal_values(y)

    x_fit_mik = np.linspace(np.min(x_mik) - np.abs(np.min(x_mik)) / 2, np.max(x_mik) + np.abs(np.max(x_mik)), 5000)

    if type(fit) is tuple:
        y_fit_mik = lin_fun(fit[0][0], fit[0][1], x_fit_mik)
        plt.plot(x_fit_mik, y_fit_mik, "--", label=fit_label, color="#5e5e5e", linewidth=1)

    else:
        y_fit_mik = lin_fun2(fit.beta, x_fit_mik)
        plt.plot(x_fit_mik, y_fit_mik, "--", label=fit_label, color="#5e5e5e", linewidth=1)

def graf_oblika(Naslov: str, x_os: str, y_os: str, legenda=1):
    x_limits = plt.xlim()
    y_limits = plt.ylim()

    x_ticks_major = plt.gca().get_xticks()
    y_ticks_major = plt.gca().get_yticks()

    x_ticks_minor = np.concatenate([np.arange(start, stop, (stop - start) / 5)[1:] for start, stop in zip(x_ticks_major[:-1], x_ticks_major[1:])])
    y_ticks_minor = np.concatenate([np.arange(start, stop, (stop - start) / 5)[1:] for start, stop in zip(y_ticks_major[:-1], y_ticks_major[1:])])

    plt.xticks(x_ticks_major)
    plt.xticks(x_ticks_minor, minor=True)

    plt.yticks(y_ticks_major)
    plt.yticks(y_ticks_minor, minor=True)

    plt.grid(which='minor', alpha=0.2)
    plt.grid(which='major', alpha=0.5)

    if legenda == 1:
        plt.legend()

    plt.xlabel(x_os)
    plt.ylabel(y_os)
    plt.title(Naslov, y=1.02)

#####################################################################################################################################################

skala = 70

### T = 295 K

Podatki_295 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-20dB-Yb2Be2GeO7-9Be-1-295K.csv", delimiter=";")

f_295 = Podatki_295[1:].T[0]
y_295 = Podatki_295[1:].T[1]

plt.plot(f_295, y_295/np.max(y_295) * skala + 295, label=r"$T = 295$ K")
plt.fill_between(f_295, 295, y_295/np.max(y_295) * skala + 295, alpha=0.7)



### T = 250 K

Podatki_250 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-24dB-Yb2Be2GeO7-9Be-3-250K.csv", delimiter=";")

f_250 = Podatki_250[1:].T[0]
y_250 = Podatki_250[1:].T[1]

plt.plot(f_250, y_250/np.max(y_250) * skala + 250, label=r"$T = 250$ K")
plt.fill_between(f_250, 250, y_250/np.max(y_250) * skala + 250, alpha=0.7)



### T = 200 K

Podatki_200 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-21dB-Yb2Be2GeO7-9Be-2-200K.csv", delimiter=";")

f_200 = Podatki_200[1:].T[0]
y_200 = Podatki_200[1:].T[1]

plt.plot(f_200, y_200/np.max(y_200) * skala + 200, label=r"$T = 200$ K")
plt.fill_between(f_200, 200, y_200/np.max(y_200) * skala + 200, alpha=0.7)



### T = 155 K

Podatki_155 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-20dB-Yb2Be2GeO7-9Be-2-155K.csv", delimiter=";")

f_155 = Podatki_155[1:].T[0]
y_155 = Podatki_155[1:].T[1]

plt.plot(f_155, y_155/np.max(y_155) * skala + 155, label=r"$T = 155$ K")
plt.fill_between(f_155, 155, y_155/np.max(y_155) * skala + 155, alpha=0.7)



### T = 80 K

Podatki_80 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-24dB-Yb2Be2GeO7-9Be-3-80K.csv", delimiter=";")

f_80 = Podatki_80[1:].T[0]
y_80 = Podatki_80[1:].T[1]

plt.plot(f_80, y_80/np.max(y_80) * skala + 80, label=r"$T = 80$ K")
plt.fill_between(f_80, 80, y_80/np.max(y_80) * skala + 80, alpha=0.7)



### T = 70 K

Podatki_70 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-23dB-Yb2Be2GeO7-9Be-10-70K.csv", delimiter=";")

f_70 = Podatki_70[1:].T[0]
y_70 = Podatki_70[1:].T[1]

plt.plot(f_70, y_70/np.max(y_70) * skala + 70, label=r"$T = 70$ K")
plt.fill_between(f_70, 70, y_70/np.max(y_70) * skala + 70, alpha=0.7)



### T = 50 K

Podatki_50 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-23dB-Yb2Be2GeO7-9Be-10-50K.csv", delimiter=";")

f_50 = Podatki_50[1:].T[0]
y_50 = Podatki_50[1:].T[1]

plt.plot(f_50, y_50/np.max(y_50) * skala + 50, label=r"$T = 50$ K")
plt.fill_between(f_50, 50, y_50/np.max(y_50) * skala + 50, alpha=0.7)



### T = 35 K

Podatki_35 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\glue_spc\spc-23dB-Yb2Be2GeO7-9Be-10-35K.csv", delimiter=";")

f_35 = Podatki_35[1:].T[0]
y_35 = Podatki_35[1:].T[1]

plt.plot(f_35, y_35/np.max(y_35) * skala + 35, label=r"$T = 35$ K")
plt.fill_between(f_35, 35, y_35/np.max(y_35) * skala + 35, alpha=0.7)


graf_oblika("Spektri pri različnih temperaturah", r"$f$ [MHz]", r"$T$ [K]", 0)


plt.savefig(r"NMR\Grafi\Spektri_Temp_1.png", bbox_inches='tight', pad_inches=0.1)
plt.show()