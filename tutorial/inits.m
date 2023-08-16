%% Set-up script for gPPI-network-tutorial
% Gregory Gutman (11.08.22)

%{
In this function all need parameters are initialized and shortly explained.
It runs in the main-script and needs the adapted workind directory as an
input.
The nifti files are also decompressed.

Overview of subject-unspecific parameters
- roiFolder
- roiList
- sphere
- sphereInfo
- contPeak
- direktionList
- contAdj
- tasks

Overview of subject-specific parameters
- sub
- fstFolder
- ntwFoler
- roiSubFolder
- evGLM
%}

function inits(wkdir)

%% Set up subject-unspecific parameters
% Folder with region mask & list of regions. The region maps are already
% realigned to fit the dimension and orientation of the task.
roiFolder      = [wkdir,'\tutorial\roi-masks\'];
roiList        = dir([roiFolder,'*.nii']);
roiList        = {roiList.name};

% Sphere mask and sphere meta info
    % Sphere will be drawn around peak voxel (see below)
    % In this case I used a 8mm-redius-sphere, any other size or volumne
    % type can be used
    % SphereInfo leads to zero-nifti (with equal proportions to bold sequence)
    % onto which spheres are drawn. I create these by just taking one of
    % the contrast in the first-level folder and multiplying it by 0.
sphere          = load(['C:\Users\grego\Desktop\gppi-network-tutorial\' ...
    'tutorial\templates\sphere_8mm.mat']).sphereCutXYZ;
sphereInfo      = spm_vol(['C:\Users\grego\Desktop\gppi-network-tutorial\' ...
    'tutorial\templates\sphereInfo.nii']);

% Contrasts on which basis the peak voxel should be choosen
    % Here I took the fourth contrast, which is high-calorie food images
    % over low-calorie food images
contPeak        = 'spmT_0004.nii';

% Direction list: defines if maximum peak (1) or minimum peak (0) should be
% used respectivly for each region as the center of a sphere
    % Here only positive peaks are used meaning high>low-calorie food for
    % every region
    % With 0 the reversed contrast - in this case low>high-calorie food - 
    % will be used for peak selection for choosen regions
directionList   = ones(1,246);

% Contrast on which basis eigenvariate is adjusted 
    % Side note: Adjustment for regressors which are not part of contrast
    % Here contrast is effects of interest, so adjustment for all other
    % regressors (6 rigid body regressors)
contAdj         = 6;

% Task names for which to create gPPI-Parameters
tasks          = {'1'  'hi'  'low'  'cont'};

%% Set up subject-specific parameters
% Participant
sub             = 'sub-1304am';

% (Regular) first-level folder (computed prior)
fstFolder       = [wkdir,'\tutorial\data\firstlevel\', sub, '\'];

% Output or network folder
ntwFolder       = [wkdir,'\tutorial\gppi-network\', sub, '\'];
% Roi-mask folder within network folder
roiSubFolder    = [ntwFolder,'roi_masks\'];

% Information and paths to run GLM for eigenvariates and create needed
% SPM.mat
evGLM           = struct();
evGLM.sess      = 2;
evGLM.RT        = 2;
evGLM.tunits    = ['secs'];
evGLM.sub       = sub;
evGLM.design(1) = {[wkdir,'\tutorial\data\designmatrices\', sub, '_design1.mat']};
evGLM.design(2) = {[wkdir,'\tutorial\data\designmatrices\', sub, '_design2.mat']};
evGLM.cofounds(1)= {[wkdir,'\tutorial\data\cofounds\', sub, '_6rigidbody_confounds1.txt']};
evGLM.cofounds(2)= {[wkdir,'\tutorial\data\cofounds\', sub, '_6rigidbody_confounds2.txt']};
evGLM.preprogz(1)= {[wkdir,'\tutorial\data\preprocessed\', sub, '_preproc1.nii.gz']};
evGLM.preprogz(2)= {[wkdir,'\tutorial\data\preprocessed\', sub, '_preproc2.nii.gz']};


%% Decompress nii.gz files
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.files = evGLM.preprogz(1);
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.outdir = {''};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.keep = true;
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.files = evGLM.preprogz(2);
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.outdir = {''};
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.keep = true;
%spm_jobman('run', matlabbatch);

%% Save workspace
save([wkdir,'parameters.mat'])

end