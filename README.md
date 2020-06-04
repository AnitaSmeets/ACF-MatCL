# ACF-MatCL
These are a collection of MATLAB and OpenCL functions that calculate the statistical auto-correlation of a 2D matrix.

These functions make use of the [MatCL OpenCL interface for MATLAB](https://github.com/IANW-Projects/MatCL). Required functions from MatCL are included in the folder MatCL-master. MatCL is licensed under the Creative Commons licence [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode).

## Description

## Setup

Download all files in the repository.
Depending on the functions to be used, the Parallel Processing Toolbox and/or the OpenCL runtime need to be installed. Check the function requirements for more information.

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

### Function requirements

| Function |  Parallel Processing Toolbox | OpenCL runtime |
|---|:---:|:---:|
|`cl_get_devices` | | :heavy_check_mark: |
|`autocorr_stat` | | |
|`bulk_ACF` | :heavy_check_mark: | |
|`autocorr_stat_opencl` | | :heavy_check_mark:|
|`average_ACF` | | |


## Usage

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

#### Calculate 2D auto-correlation using MATLAB only:  
```ACF = autocorr_stat(A);```

  **Input:**  
   `A`: Input matrix (must be 2D matrix)  
   
  **Output:**  
   `ACF`: Output 2D auto-correlation  
   
---
#### Calculate multiple 2D auto-correlations using the MATLAB Parallel Computing Toolbox:  
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
   