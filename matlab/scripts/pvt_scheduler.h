//
// MATLAB Compiler: 6.6 (R2018a)
// Date: Tue Jul 26 09:21:41 2022
// Arguments:
// "-B""macro_default""-W""cpplib:pvt_scheduler""-T""link:lib""pvt_scheduler.m""
// -C"
//

#ifndef __pvt_scheduler_h
#define __pvt_scheduler_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_pvt_scheduler_C_API 
#define LIB_pvt_scheduler_C_API /* No special import/export declaration */
#endif

/* GENERAL LIBRARY FUNCTIONS -- START */

extern LIB_pvt_scheduler_C_API 
bool MW_CALL_CONV pvt_schedulerInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_pvt_scheduler_C_API 
bool MW_CALL_CONV pvt_schedulerInitialize(void);

extern LIB_pvt_scheduler_C_API 
void MW_CALL_CONV pvt_schedulerTerminate(void);

extern LIB_pvt_scheduler_C_API 
void MW_CALL_CONV pvt_schedulerPrintStackTrace(void);

/* GENERAL LIBRARY FUNCTIONS -- END */

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

extern LIB_pvt_scheduler_C_API 
bool MW_CALL_CONV mlxPvt_scheduler(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */

#ifdef __cplusplus
}
#endif


/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__MINGW64__)

#ifdef EXPORTING_pvt_scheduler
#define PUBLIC_pvt_scheduler_CPP_API __declspec(dllexport)
#else
#define PUBLIC_pvt_scheduler_CPP_API __declspec(dllimport)
#endif

#define LIB_pvt_scheduler_CPP_API PUBLIC_pvt_scheduler_CPP_API

#else

#if !defined(LIB_pvt_scheduler_CPP_API)
#if defined(LIB_pvt_scheduler_C_API)
#define LIB_pvt_scheduler_CPP_API LIB_pvt_scheduler_C_API
#else
#define LIB_pvt_scheduler_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_pvt_scheduler_CPP_API void MW_CALL_CONV pvt_scheduler(int nargout, mwArray& v, mwArray& a, mwArray& c, const mwArray& p, const mwArray& t, const mwArray& a_max, const mwArray& v_max, const mwArray& is_c1_smooth);

/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */
#endif

#endif
