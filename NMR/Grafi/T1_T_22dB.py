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
    optimizedParameters, pcov = opt.curve_fit(funkcija, unp.nominal_values(x), unp.nominal_values(y), sigma=unp.std_devs(y), absolute_sigma=True)
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

### T = 295 K

Podatki1 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-1-56p14MHz.csv", delimiter=";")
Podatki2 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-2-56p14MHz.csv", delimiter=";")
Podatki3 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-1-56p144MHz.csv", delimiter=";")
Podatki4 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-3-left.csv", delimiter=";")#
Podatki5 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-4-left.csv", delimiter=";")#
Podatki6 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-5-left.csv", delimiter=";")#
Podatki7 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-6-left.csv", delimiter=";")
Podatki8 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-8-left.csv", delimiter=";")#
Podatki9 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-9-left.csv", delimiter=";")
Podatki10 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-23dB-Yb2Be2GeO7-9Be-10-left.csv", delimiter=";")
Podatki11 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-23dB-Yb2Be2GeO7-9Be-11-left.csv", delimiter=";")

Podatki_Vsi = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-1-left.csv", delimiter=";")
# Podatki5 = np.genfromtxt(r"NMR\NMR obdelava 20230810\data\YbBeGeO\csv\T1\T1-22dB-Yb2Be2GeO7-9Be-3-56p144MHz.csv", delimiter=";")


T_1 = Podatki1[1:].T[0]
T1_1 = Podatki1[1:].T[1]
T1_1_err = Podatki1[1:].T[6]
r_1 = Podatki1[1:].T[3]
s_1 = Podatki1[1:].T[5]
D1_1 = Podatki1[1:].T[17]

T_2 = Podatki2[1:].T[0]
T1_2 = Podatki2[1:].T[1]
T1_2_err = Podatki2[1:].T[6]
r_2 = Podatki2[1:].T[3]
s_2 = Podatki2[1:].T[5]
D1_2 = Podatki2[1:].T[17]

T_3 = Podatki3[1:].T[0]
T1_3 = Podatki3[1:].T[1]
T1_3_err = Podatki3[1:].T[6]
r_3 = Podatki3[1:].T[3]
s_3 = Podatki3[1:].T[5]
D1_3 = Podatki3[1:].T[17]

T_4 = Podatki4[1:].T[0]
T1_4 = Podatki4[1:].T[1]
T1_4_err = Podatki4[1:].T[6]

T_5 = Podatki5[1:].T[0]
T1_5 = Podatki5[1:].T[1]
T1_5_err = Podatki5[1:].T[6]

T_6 = Podatki6[1:].T[0]
T1_6 = Podatki6[1:].T[1]
T1_6_err = Podatki6[1:].T[6]

T_7 = Podatki7[1:].T[0]
T1_7 = Podatki7[1:].T[1]
T1_7_err = Podatki7[1:].T[6]

T_8 = Podatki8[1:].T[0]
T1_8 = Podatki8[1:].T[1]
T1_8_err = Podatki8[1:].T[6]

T_9 = Podatki9[1:].T[0]
T1_9 = Podatki9[1:].T[1]
T1_9_err = Podatki9[1:].T[6]

T_10 = Podatki10[1:].T[0]
T1_10 = Podatki10[1:].T[1]
T1_10_err = Podatki10[1:].T[6]

T_11 = Podatki11[1:].T[0]
T1_11 = Podatki11[1:].T[1]
T1_11_err = Podatki11[1:].T[6]

T_Vsi = Podatki_Vsi[1:].T[0]
T1_Vsi = Podatki_Vsi[1:].T[1]
T1_Vsi_err = Podatki_Vsi[1:].T[6]

# T_5 = Podatki5[1:].T[0]
# T1_5 = Podatki5[1:].T[1]
# T1_5_err = Podatki5[1:].T[6]


T = np.concatenate((T_1, T_2, T_3, T_4))
T1 = np.concatenate((T1_1, T1_2, T1_3, T1_4))
T1_err = np.concatenate((T1_1_err, T1_2_err, T1_3_err, T1_4_err))
r = np.concatenate((r_1, r_2, r_3))
s = np.concatenate((s_1, s_2, s_3))
D1 = np.concatenate((D1_1, D1_2, D1_3))

# # plt.errorbar(T[10:], T1[10:], yerr=T1_err[10:], linestyle='None', marker='.', capsize=3)
# plt.errorbar(T_4[2:], T1_4[2:], yerr=T1_4_err[2:], linestyle='None', marker='.', capsize=3)
# plt.errorbar(T_5[2:], T1_5[2:], yerr=T1_5_err[2:], linestyle='None', marker='.', capsize=3)
# plt.errorbar(T_6[:-1], T1_6[:-1], yerr=T1_6_err[:-1], linestyle='None', marker='.', capsize=3)
# # plt.errorbar(T_7, T1_7, yerr=T1_7_err, linestyle='None', marker='.', capsize=3)
# plt.errorbar(T_8, T1_8, yerr=T1_8_err, linestyle='None', marker='.', capsize=3)
# # plt.errorbar(T_9, T1_9, yerr=T1_9_err, linestyle='None', marker='.', capsize=3)
# # plt.errorbar(T_5, T1_5, yerr=T1_5_err, linestyle='None', marker='.', capsize=3, label="Spremenjen D9, 56.144 MHz")

# graf_oblika(r"$T_1$ v odvisnosti od temperature", r"$T$ [K]", r"$T_1$ [s]", legenda=0)

# # plt.savefig(r"NMR\Grafi\T1_Temperatura.png", bbox_inches='tight', pad_inches=0.1, dpi=300)
# plt.show()


T1_vsi_Neg = unp.uarray(T1_Vsi, T1_Vsi_err)

fit1, pcov1 = opt.curve_fit(lin_fun, unp.nominal_values(T_Vsi)[:12], unp.nominal_values(T1_vsi_Neg)[:12], sigma=unp.std_devs(T1_vsi_Neg)[:12], absolute_sigma=True)
fit2, pcov2 = opt.curve_fit(lin_fun, unp.nominal_values(T_Vsi)[13:], unp.nominal_values(T1_vsi_Neg)[13:], sigma=unp.std_devs(T1_vsi_Neg)[13:], absolute_sigma=True)
# fit1 = fit_napake_x(T_Vsi[:12], T1_vsi_Neg[:12])
# print(fit1)

plt.plot(T_Vsi, lin_fun(T_Vsi, *fit1))
plt.plot(T_Vsi, lin_fun(T_Vsi, *fit2))
# graf_fit_tuple(T_Vsi[:12], T1_vsi_Neg[:12], fit1)


plt.errorbar(T_Vsi, T1_Vsi, yerr=T1_Vsi_err, linestyle='None', marker='.', capsize=3)
plt.errorbar(T_10, T1_10, yerr=T1_10_err, linestyle='None', marker='.', capsize=3)
plt.errorbar(T_11, T1_11, yerr=T1_11_err, linestyle='None', marker='.', capsize=3)
graf_oblika(r"$T_1$ v odvisnosti od temperature", r"$T$ [K]", r"$T_1$ [s]", legenda=0)

ena_z_T1_vsi_Neg = 1 / T1_vsi_Neg

plt.savefig(r"NMR\Grafi\T1_Temperatura_1.png", bbox_inches='tight', pad_inches=0.1, dpi=300)
plt.show()

# plt.errorbar(T_Vsi, unp.nominal_values(ena_z_T1_vsi_Neg), yerr=unp.std_devs(ena_z_T1_vsi_Neg), linestyle='None', marker='.', capsize=3)
# graf_oblika(r"$1 / T_1$ v odvisnosti od temperature", r"$T$ [K]", r"$1 / T_1$ [s$^{-1}$]", legenda=0)


# plt.savefig(r"NMR\Grafi\1sT1_Temperatura.png", bbox_inches='tight', pad_inches=0.1, dpi=300)
# plt.show()
# plt.plot(T_Vsi, 1/T1_Vsi)


# plt.plot(T, r, "o", label=r"$T = 295$ K")

# graf_oblika(r"$r$ v odvisnosti od temperature", r"$T$ [K]", r"$r$")

# # plt.savefig(r"NMR\Grafi\Spektri_Temp.png", bbox_inches='tight', pad_inches=0.1)
# plt.show()



# fig, ax1 = plt.subplots()
# ax2 = ax1.twinx()

# ax1.plot(T[0:19], s, "o", color="Blue", label=r"$s$")
# ax2.plot(T[0:19], D1, "o", color="Red", label=r"$D_1$")

# ax1.set_ylabel(r"$s$ [a. u.]")
# ax2.set_ylabel(r"$D_1$ [us]")
# ax1.set_xlabel(r"$T$ [K]")
# ax1.grid()

# # ax2.set_yticks(np.linspace(ax2.get_yticks()[0], ax2.get_yticks()[-1], len(ax1.get_yticks())))

# fig.legend()

# plt.plot(T[0:19], s, "o", label=r"$T = 295$ K")

# graf_oblika(r"$s$ v odvisnosti od temperature", r"$T$ [K]", r"$s$")

# plt.savefig(r"NMR\Grafi\Spektri_Temp.png", bbox_inches='tight', pad_inches=0.1)
# plt.show()