function [h ,q] = SWESetUp
%% Parameters
% caseName = 'DamBreakDry';
% caseName = 'DamBreakWet';
caseName = 'ParabolicBowl';
% caseName = 'LakeAtRest';
% caseName = 'TsunamiRunup';

% minimum water depth
minDepth = 1e-4;
g        = 9.81;
n        = 1;   % polynomial order 
nele     = 400; % No. of elements

% Set to strucutre variable
phys.name     = caseName;
phys.minDepth = minDepth;
phys.gra      = g;
phys.n        = n;
phys.ne       = nele;

% Set initial conditions
phys = SWEInit(phys);

% set output file
filename = 'SWE1D.nc';
ncfile   = CreateOutputFile(filename, phys);

% Solve Problem
% [h, q] = SWESolverHrefinedWetDry(physics, ncfile);
[h, q]   = SWESolver(phys, ncfile);


end% func


