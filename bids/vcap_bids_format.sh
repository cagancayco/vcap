#!/bin/bash

#author: Christina Gancayco
#last update: September 15, 2017



# load in subject names, vcap_subjects.txt should contain one ID per line (you can
# copy/paste from Finder into a text file)
# you can change vcap_subs_2017-09-14.txt to your filename
vars=($(awk -F= '{print $1}' vcap_subs_2017-09-14.txt))

# change 91 to however many subjects you have minus 1 (because indexing starts at 0, not 1)
for i in {0..91}; do
subject=$(echo ${vars[i]}| xargs)

# make new subject directories and anatomical/functional subdirectories
mkdir /Volumes/Druzgal_Lab/VCAP/data/$subject
mkdir /Volumes/Druzgal_Lab/VCAP/data/$subject/session_1
mkdir /Volumes/Druzgal_Lab/VCAP/data/$subject/session_1/anat
mkdir /Volumes/Druzgal_Lab/VCAP/data/$subject/session_1/func

# anat_dir and func_dir are variable shortcuts so we don't have to type out the
# full directory for the rest of the script
anat_dir=/Volumes/Druzgal_Lab/VCAP/data/$subject/session_1/anat
func_dir=/Volumes/Druzgal_Lab/VCAP/data/$subject/session_1/func

# move into the subject's raw dicom directory
cd /Volumes/Data/VCAP/$subject

# searches for MPRAGE and resting state dicom folders
mprage_dirs=($(find . -maxdepth 1 -type d -name '*MPRAGE*' | sort))
rsfmri_dirs=($(find . -maxdepth 1 -type d -name '*FMRI_REST*' | sort))

# converts first MPRAGE from DICOM to nifti format, and renames to anat_1.nii
/Applications/MRIcron/dcm2nii -o $anat_dir -g N ${mprage_dirs[0]}
mv $anat_dir/2017*.nii $anat_dir/anat_1.nii

# converts second MPRAGE from DICOM to nifti format, and renames to anat_2.nii
/Applications/MRIcron/dcm2nii -o $anat_dir -g N ${mprage_dirs[1]}
mv $anat_dir/2017*.nii $anat_dir/anat_2.nii

# removes extra cropped and orthogonalized images
rm $anat_dir/c*.nii
rm $anat_dir/o*.nii

# converts first resting state scan from DICOM to nifti format, renames to rest_1.nii
/Applications/MRIcron/dcm2nii -o $func_dir -g N -k 10 ${rsfmri_dirs[0]}
mv $func_dir/2017*.nii $func_dir/rest_1.nii

# converts second resting state scan from DICOM to nifti format, renames to rest_2.nii
/Applications/MRIcron/dcm2nii -o $func_dir -g N -k 10 ${rsfmri_dirs[1]}
mv $func_dir/2017*.nii $func_dir/rest_2.nii

# This is where the files are trimmed. rest_1.nii is original file, rest_1 is name of
# trimmed .nii.gz file that will be created. 10 is the 11th volume, since indexing starts
# at 0, and it will keep 600 volumes starting with 10.
fslroi $func_dir/rest_1.nii $func_dir/rest_1 10 600
fslroi $func_dir/rest_2.nii $func_dir/rest_2 10 600

# this is to remove the 610 volume file
rm $func_dir/*.nii

# this is to unzip the new 600 volume file
gunzip $func_dir/*.nii.gz

done
