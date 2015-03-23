/*
 * MATLAB Compiler: 3.0
 * Date: Wed Oct 13 18:57:39 2004
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "LoadSE_SON" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#ifndef __sonchanlist_h
#define __sonchanlist_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_sonchanlist(void);
extern void TerminateModule_sonchanlist(void);
extern _mexLocalFunctionTable _local_function_table_sonchanlist;

extern mxArray * mlfSonchanlist(mxArray * fid);
extern void mlxSonchanlist(int nlhs,
                           mxArray * plhs[],
                           int nrhs,
                           mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
