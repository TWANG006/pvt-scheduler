//
// MATLAB Compiler: 6.6 (R2018a)
// Date: Tue Jul 26 09:21:41 2022
// Arguments:
// "-B""macro_default""-W""cpplib:pvt_scheduler""-T""link:lib""pvt_scheduler.m""
// -C"
//

#include <stdio.h>
#define EXPORTING_pvt_scheduler 1
#include "pvt_scheduler.h"

static HMCRINSTANCE _mcr_inst = NULL;

#if defined( _MSC_VER) || defined(__LCC__) || defined(__MINGW64__)
#ifdef __LCC__
#undef EXTERN_C
#endif
#include <windows.h>

static char path_to_dll[_MAX_PATH];

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, void *pv)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        if (GetModuleFileName(hInstance, path_to_dll, _MAX_PATH) == 0)
            return FALSE;
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {
    }
    return TRUE;
}
#endif
#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
    return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
    int written = 0;
    size_t len = 0;
    len = strlen(s);
    written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
    if (len > 0 && s[ len-1 ] != '\n')
        written += mclWrite(2 /* stderr */, "\n", sizeof(char));
    return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_pvt_scheduler_C_API
#define LIB_pvt_scheduler_C_API /* No special import/export declaration */
#endif

LIB_pvt_scheduler_C_API 
bool MW_CALL_CONV pvt_schedulerInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
    if (_mcr_inst != NULL)
        return true;
    if (!mclmcrInitialize())
        return false;
    if (!GetModuleFileName(GetModuleHandle("pvt_scheduler"), path_to_dll, _MAX_PATH))
        return false;
    bResult = mclInitializeComponentInstanceNonEmbeddedStandalone(&_mcr_inst,
                                                                  path_to_dll,
                                                                  "pvt_scheduler",
                                                                  LibTarget,
                                                                  error_handler, 
                                                                  print_handler);
    if (!bResult)
    return false;
    return true;
}

LIB_pvt_scheduler_C_API 
bool MW_CALL_CONV pvt_schedulerInitialize(void)
{
    return pvt_schedulerInitializeWithHandlers(mclDefaultErrorHandler, 
                                             mclDefaultPrintHandler);
}

LIB_pvt_scheduler_C_API 
void MW_CALL_CONV pvt_schedulerTerminate(void)
{
    if (_mcr_inst != NULL)
        mclTerminateInstance(&_mcr_inst);
}

LIB_pvt_scheduler_C_API 
void MW_CALL_CONV pvt_schedulerPrintStackTrace(void) 
{
    char** stackTrace;
    int stackDepth = mclGetStackTrace(&stackTrace);
    int i;
    for(i=0; i<stackDepth; i++)
    {
        mclWrite(2 /* stderr */, stackTrace[i], sizeof(char)*strlen(stackTrace[i]));
        mclWrite(2 /* stderr */, "\n", sizeof(char)*strlen("\n"));
    }
    mclFreeStackTrace(&stackTrace, stackDepth);
}


LIB_pvt_scheduler_C_API 
bool MW_CALL_CONV mlxPvt_scheduler(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
    return mclFeval(_mcr_inst, "pvt_scheduler", nlhs, plhs, nrhs, prhs);
}

LIB_pvt_scheduler_CPP_API 
void MW_CALL_CONV pvt_scheduler(int nargout, mwArray& v, mwArray& a, mwArray& c, const 
                                mwArray& p, const mwArray& t, const mwArray& a_max, const 
                                mwArray& v_max, const mwArray& is_c1_smooth)
{
    mclcppMlfFeval(_mcr_inst, "pvt_scheduler", nargout, 3, 5, &v, &a, &c, &p, &t, &a_max, &v_max, &is_c1_smooth);
}

