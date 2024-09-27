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
Podatki = np.genfromtxt("MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Vsi_Parametri_2.csv", delimiter=",")

# print(Podatki[1:].T[0])

### CF2_0
Temp = Podatki[1:].T[0]
CF2_0 = Podatki[1:].T[1]
CF2_0_err_min = np.abs(Podatki[1:].T[2] - CF2_0)
CF2_0_err_max = np.abs(Podatki[1:].T[3] - CF2_0)

CF2_0_err = unp.uarray(CF2_0, (CF2_0_err_max + CF2_0_err_min) / (2 * 1.96))

plt.errorbar(Temp, CF2_0, (CF2_0_err_min, CF2_0_err_max), linestyle='None', marker='.', capsize=3)

graf_oblika(r"$B_2^0$ v odvisnosti od temperature", r"$T$ [K]", r"$B_2^0$ [MHz]", legenda=0)
plt.autoscale(False)
plt.plot([0, 60], [obtezeno_povprecje(CF2_0_err).nominal_value, obtezeno_povprecje(CF2_0_err).nominal_value], "--", label="Povprečje", color="#5e5e5e", linewidth=1)

plt.legend()

plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\CF2_0.png", bbox_inches='tight', pad_inches=0.1)
plt.show()

######################################################


###CF4_4
CF4_4 = Podatki[1:].T[4]
CF4_4_err_min = np.abs(Podatki[1:].T[5] - CF4_4)
CF4_4_err_max = np.abs(Podatki[1:].T[6] - CF4_4)

CF4_4_err = unp.uarray(CF4_4, (CF4_4_err_min + CF4_4_err_max) / (2 * 1.96))

plt.errorbar(Temp, CF4_4, (CF4_4_err_min, CF4_4_err_max), linestyle='None', marker='.', capsize=3)

graf_oblika(r"$B_4^4$ v odvisnosti od temperature", r"$T$ [K]", r"$B_4^4$ [MHz]", legenda=0)

plt.autoscale(False)
plt.plot([0, 60], [obtezeno_povprecje(CF4_4_err).nominal_value, obtezeno_povprecje(CF4_4_err).nominal_value], "--", label="Povprečje", color="#5e5e5e", linewidth=1)
plt.legend()

plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\CF4_4.png", bbox_inches='tight', pad_inches=0.1)
plt.show()

######################################################


###CF4_0
CF4_0 = Podatki[1:].T[7]
CF4_0_err_min = np.abs(Podatki[1:].T[8] - CF4_0)
CF4_0_err_max = np.abs(Podatki[1:].T[9] - CF4_0)

CF4_0_err = unp.uarray(CF4_0, (CF4_0_err_min + CF4_0_err_max) / (2 * 1.96))

plt.errorbar(Temp, CF4_0, (CF4_0_err_min, CF4_0_err_max), linestyle='None', marker='.', capsize=3)
x_limits = plt.xlim()
y_limits = plt.ylim()

graf_oblika(r"$B_4^0$ v odvisnosti od temperature", r"$T$ [K]", r"$B_4^0$ [MHz]", legenda=1)
plt.autoscale(False)
plt.plot([0, 60], [obtezeno_povprecje(CF4_0_err).nominal_value, obtezeno_povprecje(CF4_0_err).nominal_value], "--", label="Povprečje", color="#5e5e5e", linewidth=1)
plt.legend()
plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\CF4_0.png", bbox_inches='tight', pad_inches=0.1)
plt.show()

######################################################


###CF6_4
CF6_4 = Podatki[1:].T[10]
CF6_4_err_min = np.abs(Podatki[1:].T[11] - CF6_4)
CF6_4_err_max = np.abs(Podatki[1:].T[12] - CF6_4)

CF6_4_err = unp.uarray(CF6_4, (CF6_4_err_min + CF6_4_err_max) / (2 * 1.96))

plt.errorbar(Temp, CF6_4, (CF6_4_err_min, CF6_4_err_max), linestyle='None', marker='.', capsize=3)

graf_oblika(r"$B_6^4$ v odvisnosti od temperature", r"$T$ [K]", r"$B_6^4$ [MHz]", legenda=0)

plt.autoscale(False)
plt.plot([0, 60], [obtezeno_povprecje(CF6_4_err).nominal_value, obtezeno_povprecje(CF6_4_err).nominal_value], "--", label="Povprečje", color="#5e5e5e", linewidth=1)
plt.legend()

plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\CF6_4.png", bbox_inches='tight', pad_inches=0.1)
plt.show()

######################################################


###CF6_0
CF6_0 = Podatki[1:].T[13]
CF6_0_err_min = np.abs(Podatki[1:].T[14] - CF6_0)
CF6_0_err_max = np.abs(Podatki[1:].T[15] - CF6_0)

CF6_0_err = unp.uarray(CF6_0, (CF6_0_err_min + CF6_0_err_max) / (2 * 1.96))

plt.errorbar(Temp, CF6_0, (CF6_0_err_min, CF6_0_err_max), linestyle='None', marker='.', capsize=3)

graf_oblika(r"$B_6^0$ v odvisnosti od temperature", r"$T$ [K]", r"$B_6^0$ [MHz]", legenda=0)

plt.autoscale(False)
plt.plot([0, 60], [obtezeno_povprecje(CF6_0_err).nominal_value, obtezeno_povprecje(CF6_0_err).nominal_value], "--", label="Povprečje", color="#5e5e5e", linewidth=1)
plt.legend()

plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\CF6_0.png", bbox_inches='tight', pad_inches=0.1)
plt.show()

######################################################


###HStr1
HStr1 = Podatki[1:].T[16]
HStr1_err_min = np.abs(Podatki[1:].T[17] - HStr1)
HStr1_err_max = np.abs(Podatki[1:].T[18] - HStr1)

HStr1_err = unp.uarray(HStr1, (HStr1_err_min + HStr1_err_max) / (2 * 1.96))

plt.errorbar(Temp, HStr1, (HStr1_err_min, HStr1_err_max), linestyle='None', marker='.', capsize=3)

graf_oblika(r"$HStrain_1$ v odvisnosti od temperature", r"$T$ [K]", r"$HStrain_1$ [MHz]", legenda=0)

plt.autoscale(False)
plt.plot([0, 60], [obtezeno_povprecje(HStr1_err).nominal_value, obtezeno_povprecje(HStr1_err).nominal_value], "--", label="Povprečje", color="#5e5e5e", linewidth=1)
plt.legend()

plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\HStr_1.png", bbox_inches='tight', pad_inches=0.1)
plt.show()

######################################################


###HStr2
HStr2 = Podatki[1:].T[19]
HStr2_err_min = np.abs(Podatki[1:].T[20] - HStr2)
HStr2_err_max = np.abs(Podatki[1:].T[21] - HStr2)

HStr2_err = unp.uarray(HStr2, (HStr2_err_min + HStr2_err_max) / (2 * 1.96))

plt.errorbar(Temp, HStr2, (HStr2_err_min, HStr2_err_max), linestyle='None', marker='.', capsize=3)

graf_oblika(r"$HStrain_2$ v odvisnosti od temperature", r"$T$ [K]", r"$HStrain_2$ [MHz]", legenda=0)

plt.autoscale(False)
plt.plot([0, 60], [np.average(HStr2[2:]), np.average(HStr2[2:])], "--", label="Povprečje", color="#5e5e5e", linewidth=1)
plt.legend()

plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\HStr_2.png", bbox_inches='tight', pad_inches=0.1)
plt.show()

######################################################


###HStr3
HStr3 = Podatki[1:].T[22]
HStr3_err_min = np.abs(Podatki[1:].T[23] - HStr3)
HStr3_err_max = np.abs(Podatki[1:].T[24] - HStr3)

HStr3_err = unp.uarray(HStr3, (HStr3_err_min + HStr3_err_max) / (2 * 1.96))

plt.errorbar(Temp, HStr3, (HStr3_err_min, HStr3_err_max), linestyle='None', marker='.', capsize=3)

graf_oblika(r"$HStrain_3$ v odvisnosti od temperature", r"$T$ [K]", r"$HStrain_3$ [MHz]", legenda=0)

plt.autoscale(False)
plt.plot([0, 60], [obtezeno_povprecje(HStr3_err).nominal_value, obtezeno_povprecje(HStr3_err).nominal_value], "--", label="Povprečje", color="#5e5e5e", linewidth=1)
plt.legend()

plt.savefig(r"MatLab\easyspin-6.0.5\Sistemi\Fit_Parametri\Grafi\HStr_3.png", bbox_inches='tight', pad_inches=0.1)
plt.show()


print("CF2_0: ", obtezeno_povprecje(CF2_0_err))
print("CF4_4: ", obtezeno_povprecje(CF4_4_err))
print("CF4_0: ", obtezeno_povprecje(CF4_0_err))
print("CF6_4: ", obtezeno_povprecje(CF6_4_err))
print("CF6_0: ", obtezeno_povprecje(CF6_0_err))
print("HStr1: ", obtezeno_povprecje(HStr1_err))
print("HStr2: ", np.average(HStr2[2:]))
print("HStr3: ", obtezeno_povprecje(HStr3_err))