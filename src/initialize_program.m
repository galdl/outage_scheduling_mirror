function [jobArgs,params,dirs,config] = ...
initialize_program(relativePath,prefix_num,caseName,program_name,run_mode)
% initializes the program. Defines the needed paths, runs the configuration
% and parameters scripts, and builds the required program directories.

%% initialize program
%some functions are shared
%between NN and outageSechduling, so remove the path of the opposite program
if(strcmp(program_name,'outage_scheduling'))
    addpath([relativePath,'/src/outage_scheduling']);
    rmpath([relativePath,'/src/uc_nn']); 
else 
    addpath([relativePath,'/src/uc_nn']);
    rmpath([relativePath,'/src/outage_scheduling']); 
end
config = configuration(program_name,run_mode);
%% server cluster job configuration
jobArgs = set_job_args(prefix_num,config);
%% set test case params
params = get_testCase_params(caseName,config);
%% build directory structure
[dirs,config] = build_dirs(prefix_num,config,caseName);
