#!/bin/bash
#
# Just copy master params to init params

# run parameters
cp ./src/paramsTmpl.m ./initparams.m

# set-up run dir parameters
cp ./src/setupParamsTmpl.m ./initSetupParams.m

# set-up analyze dir parametes
cp ./src/analyzeParamsTmpl.m ./initAnalyzeParams.m


