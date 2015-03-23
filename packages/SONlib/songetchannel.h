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

#ifndef __songetchannel_h
#define __songetchannel_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_songetchannel(void);
extern void TerminateModule_songetchannel(void);
extern _mexLocalFunctionTable _local_function_table_songetchannel;

extern mxArray * mlfSongetchannel(mxArray * * header,
                                  mxArray * fid,
                                  mxArray * chan,
                                  mxArray * timeunits);
extern void mlxSongetchannel(int nlhs,
                             mxArray * plhs[],
                             int nrhs,
                             mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
