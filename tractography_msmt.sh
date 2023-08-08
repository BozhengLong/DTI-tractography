#!/bin/bash

# convert nifti to native format MIF

Dwi= ..
T1= ..

mrconvert -fslgrad "$Dwi".bvec "$Dwi".bval "$Dwi".nii DwiRaw.mif -json_import "$Dwi".json

# create a mask

dwi2mask DwiRaw.mif - | maskfilter - dilate preprocess_mask.mif -npass 3

# Veraart et al., 2016 Denoising of diffusion MRI

dwidenoise DwiRaw.mif denoise.mif -noise noiselevel.mif -mask preprocess_mask.mif

# Gibbs Ring artifact

mrdegibbs denoise.mif degibbs.mif

# motion and distortion correction

# create b0 AP-PA pair

# dwiextract rawAP.mif b0_AP.mif -bzero
# dwiextract rawPA.mif - -bzero | mrconvert - - coord 3 0 b0_PA.mif
# mrcat b0_AP.mif b0_PA.mif b0_pair.mif

# dwiextract DwiRaw.mif - -bzero | mrconvert - -coord 3 0 b0_AP.mif


# dwifslpreproc degibbs.mif geomcorr.mif -pe_dir PA -rpe_pair -se_epi b0_pair.mif -eddy_options " --data_is_shelled --slm=linear --niter=5 "

# bias field correction

# dwibiascorrect ants geomcorr.mif biascoor.mif -bias biasfield.mif


# prepare for alignment to T1

dwiextract degibbs.mif -bzero - | mrmath -axis 3 - mean b0.nii

flirt.fsl -dof 6 -cost normmi -ref "$T1".nii -in b0.nii -omat T_fsl.txt
transformconvert T_fsl.txt b0.nii "$T1".nii flirt_import T_DWItoT1.txt
mrtransform -linear T_DWItoT1.txt degibbs.mif align.mif

# recon-all

recon-all -i "$T1".nii -subjid sub-001 -sd . -all

# 5tt segmentation

mrconvert sub-001/mri/aparc.a2009s+aseg.mgz aparc.a2009s+aseg.nii.gz
5ttgen freesurfer aparc.a2009s+aseg.nii.gz 5ttseg.mif
5tt2gmwmi 5ttseg.mif 5tt_gmwmi.mif







### diffusion tensor imaging ###

# create a mask
dwi2mask align.mif - | maskfilter - dilate dwi_mask.mif

# create diffusion tensor
dwi2tensor -mask dwi_mask.mif align.mif dt.mif

# calculate eigenvectors and scalar metrics from tensor
tensor2metric dt.mif -fa dt_fa.mif -ad dt_ad.mif



### constrained spherical deconvolution (CSD) ###

# estimate response function for wm, gm, csf
dwi2response msmt_5tt align.mif 5ttseg.mif ms_5tt_wm.txt ms_5tt_gm.txt ms_5tt_csf.txt -voxels ms_5tt_voxels.mif


# estimate fiber orientation distribution FoD
dwi2fod msmt_csd align.mif \
    ms_5tt_wm.txt dwi_wmCsd.mif \
    ms_5tt_gm.txt dwi_gmCsd.mif \
    ms_5tt_csf.txt dwi_csfCsd.mif


# ROI-based tractography

mrthreshold -abs 0.2 dt_fa.mif - | mrcalc - dwi_mask.mif -mult dwi_wmMask.mif


mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 11110 lh_PCC.nii.gz
mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 11115 lh_mFC.nii.gz



# whole brain tractography
# tckgen -algo iFOD2 -act 5ttseg.mif -backtrack -crop_at_gmwmi -cutoff 0.05 -angle 45 -minlength 20 -maxlength 200 -seed_image dwi_wmMask.mif -select 200k dwi_wmCsd.mif fibs_200k_angle45_maxlen200_act.tck


# ROI-based tractography
tckgen -algo iFOD2 -cutoff 0.05 -angle 45 -minlength 20 -maxlength 100 -seed_image lh_PCC.nii.gz -include lh_mFC.nii.gz -seed_unidirectional -stop dwi_wmCsd.mif fib_PCC_mFC_0_05.tck


# ROI-based tractography
# tckgen -algo iFOD2 -cutoff 0.1 -angle 45 -minlength 20 -maxlength 100 -seed_image lh_PCC.nii.gz -include lh_mFC.nii.gz -seed_unidirectional -stop dwi_wmCsd.mif fib_PCC_mFC_0_1.tck
