# DTI-tractography

This repository contains two shell scripts for performing DTI tractography using MRTrix3, each tailored to a specific type of DTI data:

1. **tractography_msmt.sh:** This script is designed for tractography using the Multi-Shell Multi-Tissue (MSMT) approach. It's ideal for processing DTI images derived from multi-shell, multi-tissue models, offering a detailed analysis suitable for complex brain tissue evaluations.

2. **tractography_tournier.sh:** This script implements the Single Shell tractography approach, as proposed by Tournier et al. It's used for DTI images based on a single shell model, providing a straightforward method for more basic diffusion profile analyses.

Each script should be run in an environment where MRTrix3 is installed and properly configured. For usage details, refer to the individual script files.

## Usage Instructions

### File Preparation

1. Place all the necessary files, including your T1-weighted and DWI images, and the script files (`tractography_msmt.sh` and `tractography_tournier.sh`) in the same directory.

### Configuring the Script

Before running the scripts, you need to specify the T1-weighted and DWI (Diffusion Weighted Imaging) files that the scripts will process. Follow these steps:

2. Open the script file (`tractography_msmt.sh` or `tractography_tournier.sh`) and locate the lines that define the `T1` and `Dwi` variables. They will look something like this:
   ```bash
   T1= ..
   Dwi= ..
   ```
3. Replace the .. with the name of your corresponding T1-weighted or DWI file. Important: Do not include the file extension (.nii or .nii.gz) in the name.

Run the desired script using the bash command. For example:
```bash
bash tractography_msmt.sh
```
or
```bash
bash tractography_tournier.sh
```
