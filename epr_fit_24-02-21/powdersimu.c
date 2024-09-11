#include <math.h>
//#include <stdio.h>
#include "mex.h"

/*
 * powdersimu.c - simulation of the powder average for g- and dH anisotropies
 *
 * multiplies an input scalar times an input matrix and outputs a
 * matrix 
 *
 * This is a MEX-file for MATLAB.
 * Copyright 13.03.2010 - 24.03.2014   Anton Potocnik @ IJS F5  
 */

/* $Revision: 3.0 $ */

struct PowderResonance {
    double Hc;
    double dH;
    double f;
};

struct PowderResonance calcPowderResonance(unsigned int i, unsigned int Npowd, unsigned int Npsi, double freq, double gx, double gy, double gz, double dHx, double dHy, double dHz)
{
    struct PowderResonance result;
    
    unsigned int k;
    double fi, costh, sinth, cosfi, sinfi, g;
    double fscale, ux, uy, uz, ax, ay, az, bx, by, bz, nx, ny, nz, tmp, psi, sinpsi, cospsi, vx, vy, vz, tmpx, tmpy, tmpz;
    
    fscale = (gx*gx + gy*gy + gz*gz)/3;
    /*
    fi = 6.283185*i/N; //fi = 6.283185*i/(N-1);
    cosfi = cos(fi);
    sinfi = sin(fi);
    costh = 2.0*(j+0.5)/N - 1.0; //costh = 2.0*j/(N-1) - 1;
    sinth = sin(acos(costh));
    */
    costh = 2.0*(i+0.5)/Npowd - 1.0;
    sinth = sqrt(1.0 - costh*costh);       
    fi = 6.283185*i/2.71828; // fi = ii*2*pi/e
    cosfi = cos(fi);
    sinfi = sin(fi);

//         Hc = sqrt(0.0714477287*freq/gx*sinth*cosfi*0.0714477287*freq/gx*sinth*cosfi + 0.0714477287*freq/gy*sinth*sinfi*0.0714477287*freq/gy*sinth*sinfi + 0.0714477287*freq/gz*costh*0.0714477287*freq/gz*costh);
    result.dH = sqrt(dHx*sinth*cosfi*dHx*sinth*cosfi + dHy*sinth*sinfi*dHy*sinth*sinfi + dHz*costh*dHz*costh);
    g = sqrt(gx*sinth*cosfi*gx*sinth*cosfi + gy*sinth*sinfi*gy*sinth*sinfi + gz*costh*gz*costh);
    result.Hc = 0.0714477287*freq/g;

    // Intensity weighing by the (perpendicular component of the microwave field)^2
    // --- START ---
    /*
    u = [sinth*cosfi, sinth*sinfi, costh]';
    a = [costh*cosfi, costh*sinfi, -sinth]';
    b = cross(a, u);
    n = diag(gx, gy, gz)*u;
    n = n/norm(n);
    fN = 31;
    f = 0;
    for i=1:fN
      psi = ((i-1)/fN)*(2*pi);
      v = cos(psi)*a + sin(psi)*b;
      w = diag(gx, gy, gz)*v;
      f = f + norm(cross(n, w))^2;
    f = f/fN;
    f = f / (norm([gx, gy, gz])^2 / 3); // Normalization
    */

    // u = [sinth*cosfi, sinth*sinfi, costh]';
    ux = sinth*cosfi;
    uy = sinth*sinfi;
    uz = costh; // 1 // theta = fi = 0
    // a = [costh*cosfi, costh*sinfi, -sinth]';
    ax = costh*cosfi; // 1
    ay = costh*sinfi;
    az = -sinth;
    // b = cross(a, u);
    /*
    bx = ay*uz - az*uy;
    by = az*ux - ax*uz; // -1
    bz = ax*uy - ay*ux;
     */
    bx = sinfi;
    by = -cosfi;
    bz = 0;
    // n = diag(gx, gy, gz)*u;
    nx = gx*ux;
    ny = gy*uy;
    nz = gz*uz; // 2 = gz = gy = gx
    // n = n/norm(n);
    tmp = sqrt(nx*nx + ny*ny + nz*nz); // 2
    nx = nx/tmp;
    ny = ny/tmp;
    nz = nz/tmp; // 1
    // f = 0;
    result.f = 0;
    // for i=1:fN
    for (k=0; k<Npsi; k++) {
        // psi = ((i-1)/fN)*(2*pi);
        psi = 6.283185*k/Npsi;
        // v = cos(psi)*a + sin(psi)*b;
        cospsi = cos(psi);
        sinpsi = sin(psi);
        vx = cospsi*ax + sinpsi*bx; // cospsi
        vy = cospsi*ay + sinpsi*by; // -sinpsi
        vz = cospsi*az + sinpsi*bz;
        // w = diag(gx, gy, gz)*v; // Rename w to v
        vx = gx*vx; // 2*cospsi
        vy = gy*vy; // -2*sinpsi
        vz = gz*vz;
        // f = f + norm(cross(n, w))^2;        
        tmpx = ny*vz - nz*vy; // 2*sinpsi
        tmpy = nz*vx - nx*vz; // 2*cospsi
        tmpz = nx*vy - ny*vx;
        tmp = tmpx*tmpx + tmpy*tmpy + tmpz*tmpz; // 4*sinpsi^2 + 4*cospsi^2 = 4
        result.f += tmp;
    }
    // f = f/fN;
    result.f = result.f / Npsi; // 4
    // f = f / (norm([gx, gy, gz])^2 / 3); // Normalization
    result.f = result.f / fscale; // 1 ?
    // result.f = result.f*result.f; ////
    result.f = result.f * result.Hc; // why???

    // result.f = 1; // Turn off all weighing //
    // --- END ---
    
    return result;
}


void powdersimudL(double *Y, double *X, mwSize N, unsigned int Npsi, double freq, double gx, double gy, double gz, double dHx, double dHy, double dHz, double phase, mwSize m)
{
  unsigned int i,j,k;
  double cosph, sinph, maxi=-100000, temp, temp1; 
  // Intensity weighing by the (perpendicular component of the microwave field)^2  
  // --- START ---
  struct PowderResonance sample;
  double NN, ii;
  // --- END ---
  
  cosph = cos(phase);
  sinph = sin(phase);
	
  NN = N*N;
  ii = 0;
  for (i=0; i<N; i++) {   /* fi */
	for (j=0; j<N; j++) {   /* th */
		sample = calcPowderResonance(ii, NN, Npsi, freq, gx, gy, gz, dHx, dHy, dHz);
        ii += 1;
        
        for (k=0; k<m; k++)
			//*(Y+k) += 0.6366198*(dH*cosph - 2*(*(X+k)-Hc)*sinph)/(4*(*(X+k)-Hc)*(*(X+k)-Hc) + dH*dH);
            *(Y+k) += sample.f*0.6366198*(sample.dH*cosph - 2*(*(X+k)-sample.Hc)*sinph)/(4*(*(X+k)-sample.Hc)*(*(X+k)-sample.Hc) + sample.dH*sample.dH); // Intensity weighing by the (perpendicular component of the microwave field)^2
    }
  }
  /* DERIVATION */
  temp = *(Y+0);
  for (k=1; k<m; k++) {
      *(Y+k-1) = (*(Y+k) - temp)/(*(X+k) - *(X+k-1)); /* n(k-1) = n(k) - n(k-1)*/
      if (*(X+k) - *(X+k-1) > 3*temp1) {
          *(Y+k-1) = *(Y+k-2);           /*!!! A possible source of error, but very unlikely !!!*/
      }
      temp = *(Y+k);
      temp1 = *(X+k) - *(X+k-1);
  }
  *(Y+k-1)=*(Y+k-2); /* last value is the same as one before last */
  
  for (k=0; k<m; k++) *(Y+k) /= N*N;
}



void powdersimuL(double *Y, double *X, mwSize N, unsigned int Npsi, double freq, double gx, double gy, double gz, double dHx, double dHy, double dHz, double phase, mwSize m)
{
  unsigned int i,j,k;
  double cosph, sinph, maxi=-100000, temp, temp1;
  // Intensity weighing by the (perpendicular component of the microwave field)^2  
  // --- START ---
  struct PowderResonance sample;
  double NN, ii;
  // --- END ---
  
  cosph = cos(phase);
  sinph = sin(phase);
	
  NN = N*N;
  ii = 0;
  for (i=0; i<N; i++) {   /* fi */
	for (j=0; j<N; j++) {   /* th */
		sample = calcPowderResonance(ii, NN, Npsi, freq, gx, gy, gz, dHx, dHy, dHz);
        ii += 1;
        
        for (k=0; k<m; k++)
			*(Y+k) += sample.f*0.6366198*(sample.dH*cosph - 2*(*(X+k)-sample.Hc)*sinph)/(4*(*(X+k)-sample.Hc)*(*(X+k)-sample.Hc) + sample.dH*sample.dH);
    }
  }

  
  for (k=0; k<m; k++) *(Y+k) /= N*N;
}





void powdersimudG(double *Y, double *X, mwSize N, unsigned int Npsi, double freq, double gx, double gy, double gz, double dHx, double dHy, double dHz, double phase, mwSize m)
{
  unsigned int i,j,k;
  double cosph, sinph, maxi=-100000, temp, temp1;
  // Intensity weighing by the (perpendicular component of the microwave field)^2  
  // --- START ---
  struct PowderResonance sample;
  double NN, ii;
  // --- END ---
  
  //FILE *fp;
  
  double *Yhil; //,*Xtab,*Ytab;
  Yhil = mxMalloc(m*sizeof(double)+1);
  
  /*fp=fopen("GaussDispersion.dat", "r");
  if(fp==NULL) 
    mexErrMsgTxt("GaussDispersion.dat not found!");
  
  fscanf(fp,"%d\n",&A);
  fscanf(fp,"%d\n",&B);
  
  Ytab = mxMalloc(A*sizeof(double)+1);
  Xtab = mxMalloc(A*sizeof(double)+1);
  
  for (k=0; k<A; k++) {
      *(Xtab+k) = B*(-0.5+k/(A-1));
      fscanf(fp,"%f\n",(Ytab+k));
      printf("%f\t%f\n",*(Xtab+k),*(Ytab+k));
  }
  
  fclose(fp);*/
  
  for (k=0; k<m; k++) { // set all Yhil to zero
      *(Y+k)=0;
      *(Yhil+k)=0;
  }
  
  cosph = cos(phase);
  sinph = sin(phase);
	
  NN = N*N;
  ii = 0;
  for (i=0; i<N; i++) {   /* fi */
	for (j=0; j<N; j++) {   /* th */
		sample = calcPowderResonance(ii, NN, Npsi, freq, gx, gy, gz, dHx, dHy, dHz);
        ii += 1;
        
        for (k=0; k<m; k++) {
            *(Y+k) += sample.f*0.3989423/sample.dH*exp(-(*(X+k)-sample.Hc)*(*(X+k)-sample.Hc)/sample.dH/sample.dH/2);
            //*(Y+k) += 0.3989423/dH*exp(-(*(X+k)-Hc)*(*(X+k)-Hc)/dH/dH/2);
        }
    }
  }
  
  /* DERIVATION */
  temp = *(Y+0);
  for (k=1; k<m-1; k++) {
      temp1 = *(Y+k);
      *(Y+k) = (*(Y+k+1) - temp)/(*(X+k+1) - *(X+k-1)); // n(k) = n(k+1) - n(k-1)/
      //if (*(X+k+1) - *(X+k-1) > 6*temp1) {
      //    *(Y+k) = *(Y+k-1);           //!!! A possible source of error, but very unlikely !!!
      //}
      temp = temp1;
      //temp1 = *(X+k) - *(X+k-1);
  }
  *(Y+k-1)=*(Y+k-2); // last value is the same as one before 
  *(Y+0)=*(Y+1); // first value is the same as one after 
  
  
  /* HILBERT TRANSFORM */   
  for (i=0; i<m; i++) { // For every element
      temp=0;
      for (k=1; k<m; k++) { // Integration
          if (i==k) continue;
            temp -= *(Y+k)/(*(X+k)-*(X+i))*(*(X+k) - *(X+k-1));
      }
      *(Yhil+i) = temp/3.1415926536;
  }
  
  /* MIX DISPERSION AND ABSORPTION */
  for (k=0; k<m; k++)  
      *(Y+k) = (cosph*(*(Y+k)) - sinph*(*(Yhil+k)));

  /* NORMALIZE */
  for (k=0; k<m; k++) 
      *(Y+k) /= N*N;
  
  mxFree(Yhil);
}



void powdersimuG(double *Y, double *X, mwSize N, unsigned int Npsi, double freq, double gx, double gy, double gz, double dHx, double dHy, double dHz, double phase, mwSize m)
{
  unsigned int i,j,k;
  double cosph, sinph, maxi=-100000, temp, temp1;
  // Intensity weighing by the (perpendicular component of the microwave field)^2  
  // --- START ---
  struct PowderResonance sample;
  double NN, ii;
  // --- END ---
  //FILE *fp;
  
  double *Yhil; //,*Xtab,*Ytab;
  Yhil = mxMalloc(m*sizeof(double)+1);
  
  
  for (k=0; k<m; k++) { // set all Yhil to zero
      *(Y+k)=0;
      *(Yhil+k)=0;
  }
  
  cosph = cos(phase);
  sinph = sin(phase);
	
  NN = N*N;
  ii = 0;
  for (i=0; i<N; i++) {   /* fi */
	for (j=0; j<N; j++) {   /* th */
		sample = calcPowderResonance(ii, NN, Npsi, freq, gx, gy, gz, dHx, dHy, dHz);
        ii += 1;
        
        for (k=0; k<m; k++) {
            *(Y+k) += sample.f*0.3989423/sample.dH*exp(-(*(X+k)-sample.Hc)*(*(X+k)-sample.Hc)/sample.dH/sample.dH/2);
            //*(Y+k) += 0.3989423/dH*exp(-(*(X+k)-Hc)*(*(X+k)-Hc)/dH/dH/2);
        }
    }
  }
  
  
  /* HILBERT TRANSFORM */   
  for (i=0; i<m; i++) { // For every element
      temp=0;
      for (k=1; k<m; k++) { // Integration
          if (i==k) continue;
            temp -= *(Y+k)/(*(X+k)-*(X+i))*(*(X+k) - *(X+k-1));
      }
      *(Yhil+i) = temp/3.1415926536;
  }
  
  /* MIX DISPERSION AND ABSORPTION */
  for (k=0; k<m; k++)  
      *(Y+k) = (cosph*(*(Y+k)) - sinph*(*(Yhil+k)));

  /* NORMALIZE */
  for (k=0; k<m; k++) 
      *(Y+k) /= N*N;
  
  mxFree(Yhil);
}



/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double *Y,*X;
  double freq, gx, gy, gz, dHx, dHy, dHz, phase;
  int N, Npsi, type;
  mwSize mrows, ncols, m, k;
  
  /*  check for proper number of arguments */
  /* NOTE: You do not need an else statement when using mexErrMsgTxt
     within an if statement, because it will never get to the else
     statement if mexErrMsgTxt is executed. (mexErrMsgTxt breaks you out of
     the MEX-file) */
  if(nrhs!=12) 
    mexErrMsgTxt("Twelve inputs required.");
  if(nlhs!=1) 
    mexErrMsgTxt("One output required.");
  
  /* check to make sure the first input argument is a vector */
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      mxGetN(prhs[0])*mxGetM(prhs[0])==1 ) {
    mexErrMsgTxt("Input x must be a vector.");
  }

  /*  create a pointer to the input matrix X */
  X = mxGetPr(prhs[0]);
  /*  get the dimensions of the matrix input X */
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  
  if (mrows>=ncols) 
	m = mrows;
  else
	m = ncols;
	
  /*  get the scalars */
  N = mxGetScalar(prhs[1]); 
  Npsi = mxGetScalar(prhs[2]);
  freq = mxGetScalar(prhs[3]);
  gx = mxGetScalar(prhs[4]);
  gy = mxGetScalar(prhs[5]);
  gz = mxGetScalar(prhs[6]);
  dHx = mxGetScalar(prhs[7]);
  dHy = mxGetScalar(prhs[8]);
  dHz = mxGetScalar(prhs[9]);
  phase = mxGetScalar(prhs[10]);
  type = (int)mxGetScalar(prhs[11]);

  /*  set the output pointer to the output matrix */
  plhs[0] = mxCreateDoubleMatrix(mrows,ncols, mxREAL);  
  /*  create a C pointer to a copy of the output matrix */
  Y = mxGetPr(plhs[0]);
  
  /*  call the C subroutine 1 - Lorentz, 2- Gauss*/ 
  switch(type) {
      case 1:
          powdersimudL(Y, X, N, Npsi, freq, gx, gy, gz, dHx, dHy, dHz, phase, m);
          break;
          
      case 2:
          powdersimudG(Y, X, N, Npsi, freq, gx, gy, gz, dHx, dHy, dHz, phase, m);
          break;
    
      case 3:
          powdersimuL(Y, X, N, Npsi, freq, gx, gy, gz, dHx, dHy, dHz, phase, m);
          break;
           
      case 4:
          powdersimuG(Y, X, N, Npsi, freq, gx, gy, gz, dHx, dHy, dHz, phase, m);
          break;
          
      default:
          printf("Wrong type! Choose 1 for dLor, 2 for dGauss, 3 for Lor, and 4 for Gauss");
          return;
  }                      
                       
}
