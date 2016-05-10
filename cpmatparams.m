% Just copy master params to init params

% run parameters
copyfile('./src/paramsTmpl.m','initparams.m')

% set-up run dir parameters
copyfile('./src/setupParamsTmpl.m','./initSetupParams.m')

% set-up analyze dir parametes
copyfile('./src/analyzeParamsTmpl.m','./initAnalyzeParams.m')
