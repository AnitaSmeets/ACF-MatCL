# ACF-MatCL
A collection of MATLAB and OpenCL functions that calculate the statistical auto-correlation of a 2D matrix.

These functions make use of the [MatCL OpenCL interface for MATLAB](https://github.com/IANW-Projects/MatCL). Required functions from MatCL are included in the folder MatCL-master. MatCL is licensed under the Creative Commons licence [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode).

Tested on MATLAB R2020a

## Description
The functions can be used to calculate a 2D auto-correlation. The functions calculate a Pearson product-moment correlation coefficient for all possible displacements of the image with respect to itself. This is also known as the Zero-normalized cross-correlation of an image with a displaced version of itself.

The collection also includes a function used for the calculation of a radially averaged auto-correlation of a 2D auto-correlation.

The calculations of the 2D auto-correlations can be done at several levels of parallelisation. An overview of the functions and an explanation of which to use in what situation are given at the end of this manual.

## Setup

Download all files in the repository.
Depending on the functions to be used, the Parallel Processing Toolbox and/or the OpenCL runtime need to be installed. 

### Function requirements

| Function |  Parallel Processing Toolbox | OpenCL runtime |
|---|:---:|:---:|
|`cl_get_devices` | | :heavy_check_mark: |
|`autocorr_stat` | | |
|`bulk_ACF` | :heavy_check_mark: | |
|`autocorr_stat_opencl` | | :heavy_check_mark:|
|`average_ACF` | | |


### Windows

#### Parallel Processing Toolbox
In MATLAB go to Home -> Environment -> Add-Ons. In the Add-On Explorer, search for the Parallel Processing Toolbox and install it

#### OpenCL runtime

The OpenCL runtime should be included in standard graphics drivers. If not, search the internet for the appropriate runtime for your GPU or CPU.

### Linux

#### Parallel Processing Toolbox
Run the MATLAB installer for your Linux distribution and select the Parallel Processing Toolbox in the package selection.

#### OpenCL runtime
OpenCL runtimes may not be included in the graphics drivers. Look for and install the appropriate runtime for your GPU or CPU using your package manager.

For example on a system with an AMD FirePro M4000 GPU and an Intel Core i7-3630QM CPU running Arch Linux the packages would be `opencl-mesa` for the GPU and `intel-opencl-runtime` for the CPU.


## Usage

Information for individual functions is also available through the `help` command (`help autocorr_stat`). Examples can be found in the 'Examples' folder. 

#### Enumerate OpenCL Devices (returns a list whose i-th entry corresponds to the i-th OpenCL device):  
```[names, dev_class, max_mem, max_wg_size, max_local_work_size, compute_units] = cl_get_devices();```  

  **Output:**  
   `names`: Names of all available devices  
   `dev_class`: The device class (CPU, GPU or Other for other or unknown Accelerators)  
   `max_mem`: The available device memory in bytes  
   `max_wg_size`: Max. size of OpenCL work group  
   `max_local_work_size`: Max. size of work items  
   `compute_units`: Number of compute units (e.g. CPU cores) of the device  
   
---

#### Calculate 2D auto-correlation (single-threaded):  
```ACF = autocorr_stat(A);```

  **Input:**  
   `A`: Input matrix (must be 2D matrix)  
   
  **Output:**  
   `ACF`: Output 2D auto-correlation  
   
---
#### Calculate multiple 2D auto-correlations (multi-threaded):  
```D = bulk_ACF(C);```

  **Input:**  
   `C`: Cell array containing 2D matrices to be evaluated  
   
  **Output:**  
   `D`: Output cell array containing 2D auto-correlations  

---
#### Calculate 2D auto-correlation using OpenCL:  
```ACF = autocorr_stat_opencl(A, device_num);```

  **Input:**  
   `A`: Input matrix (must be square 2D matrix. If the dimensions of `A` are larger than `max_wg_size`, they must be a multiple of `max_wg_size` (see `cl_get_devices`))  
   `device_num`: OpenCL device to be used. Integer corresponding to the desired device (see `cl_get_devices`)  
   
  **Output:**  
   `ACF`: Output 2D auto-correlation  
   
---
#### Calculate radially averaged auto-correlation:  
```[ACFr, R] = average_ACF(A, angles, radii);```

  **Input:**  
   `A`: Input 2D auto-correlation  
   `angles`: (Optional) array of angles over which to perform the averaging. Default is `0:0.1:359.9`  
   `radii`: (Optional) array of radii for which to perform the averaging. Default is `0:0.1:(floor(min(size(A)) / 2) - 1)`. The maximum possible radius is `(min(size(A)) / 2) - 1)`  
   
  **Output:**  
   `ACFr`: 1D array of radially averaged auto-correlation  
   `R`: 1D array of radii (in pixels)  
   

## 'What function do I use?'

### Calculation times

The code was tested in MATLAB R2020a on a system with an Intel Core i7-3630QM CPU and an AMD FirePro M4000 GPU.

| | 1 x (128x128) | 50 x (128x128) | 1 x (512x512) | 50 x (512x512) |
|---|---|---|---|---|
|`autocorr_stat`| 28 s | 24 min* | 2 h* | 100 h* |
|`bulk_ACF` (8 workers)| 29 s | 7.5 min | 2 h* | 32 h* |
|`autocorr_stat_opencl` (CPU) | 0.75 s | 36 s | 30 s | 25 min*|
|`autocorr_stat_opencl` (GPU) | 0.75 s | 35 s | 16.5 s| 14 min*|

Times marked with * are estimated using known data and N^2 scaling.


Check the following descriptions of the functions to decide which function is best suited to your goals.

### 'I only need to calculate a few auto-correlations of small images'
If only a few auto-correlations of small images (128x128 px) need to be calculated, `autocorr_stat` is sufficient. It only requires the normal MATLAB installation. 
On the test system, the calculation for one image of 128x128 pixels took 28 s.

**Note:** The function scales with N^2. A 256x256 image will take 16 times as long as a 128x128 image.

### 'I need to calculate several auto-correlations of small images'
The `bulk_ACF` function calls `autocorr_stat` in parallel threads. This means that `time(X images) < X * time(1 image)`. The exact time depends on the CPU and on the amount of MATLAB parallel workers (can be changed in the Parallel Processing Toolbox preferences).
Using 8 workers in the Parallel Pool on the test system the calculation of 50 images of 128x128 pixels took 7.5 min. 

**Tip:** Change the amount of workers of your MATLAB Parallel Pool in the Parallel Processing Toolbox preferences and see what gives the best performance. A good starting point would be the amount of threads your CPU can run.

**Note:** The function scales with N^2.

### 'I don't want to wait that long'
The `autocorr_stat_opencl` function runs the same calculation on either the GPU or the CPU using OpenCL code. You can see which devices are available using `cl_get_devices`. 

On the test system, the calculation of one 128x128 image took 0.75 s (both CPU and GPU).

**Note 1:** The function scales with N^2

**Note 2 (Windows):** Running calculations for large images (during testing > 256x256) on a GPU that is also in use by the operating system may cause a crash. Consider running the code on a separate GPU (if available) or on the CPU to avoid this.

**Note 3 (Linux):** On Linux systems, the desktop environment may freeze while the program is running on the GPU. Once the program is finished, everything will work again. Consider running the code on a separate GPU (if available) or on the CPU to avoid this.

