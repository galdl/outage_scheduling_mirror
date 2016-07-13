function [] = createTempPythonFile(matlabJobLocalFilePath,commonLogDir,matlabCommand,MATLAB_PATH,jobArgs)
%% job arguments - struct
ncpusStr=num2str(jobArgs.ncpus);
memStr=num2str(jobArgs.memory);
queue=jobArgs.queue;
jobName=jobArgs.jobName;
%  node=jobArgs.node;
fid = fopen(matlabJobLocalFilePath, 'w');
%% prepare python content
initialization=['#!/usr/bin/python\n',... 
'from popen2 import popen2\n',...
'import time\n',...
'import sys\n',...
'from itertools import count\n',...
'output, input = popen2(''qsub'')\n'];

args=['job_name = "',jobName,'"\n',...
    'commonLogDir = "',commonLogDir,'"\n',...
    'outDir=commonLogDir+"/output"\n',...
    'errDir=commonLogDir+"/error"\n'];
% '#PBS -l nodes=',node,'\n',...

% '#PBS -q ',queue,'\n',...
% '#PBS -l select=1:ncpus=',ncpusStr,':mem=',memStr,'gb\n',...

qsubCmd=['job_string = """#!/bin/bash\n',...
'#PBS -N %%s\n',...
'#PBS -q ',queue,'\n',...
'#PBS -l select=1:ncpus=',ncpusStr,':mem=',memStr,'gb\n',...
'#PBS -o %%s/%%s.out\n',...
'#PBS -e %%s/%%s.err\n',...
'PBS_O_WORKDIR=$HOME/PSCC16_continuation/current_version/src\n',...
'cd $PBS_O_WORKDIR\n',...
MATLAB_PATH,' -nodisplay  -r',matlabCommand,' """ %%(job_name, outDir,job_name, errDir,job_name)\n'];


finalization=['input.write(job_string)\n',...
'input.close()\n',...
'sys.stdout = open(outDir+"/job_ids.out","a")\n',...
'print job_name + " " + output.read()\n',...
'sys.stdout.close()\n',...
'print output.read()'];

fileContent=[initialization,args,qsubCmd,finalization];
%% finalize py script
fprintf(fid,fileContent);
fclose(fid);