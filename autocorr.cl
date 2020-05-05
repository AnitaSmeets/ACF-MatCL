#ifdef cl_khr_fp64
    #pragma OPENCL EXTENSION cl_khr_fp64 : enable
#else
    #error "IEEE-754 double precision not supported by OpenCL implementation."
#endif

__kernel void int_sums(__constant double *A, __global int *Nr,
							__global double *Isum,
							__global double *Isqsum) {

        //Initialize temporary storage for pixels in local memory
		__local double pixels1[(int)N];
		__local double pixels2[(int)N];

		int drow = get_global_id(0);
		int dcol = get_global_id(1);

        //Initialize temporary variables
		int Nr_L = 0;
		
		double Isum_pp = 0;
		double Isqsum_pp = 0;
		
		double Isum_np = 0;
		double Isqsum_np = 0;
		
		double Isum_pn = 0;
		double Isqsum_pn = 0;

		double Isum_nn = 0;
		double Isqsum_nn = 0;
		
        //Initialize indices
		int in1;
		int in2;
		
		for (int i = 0; i < (int)N - drow; i++) {

            //Retrieve two rows of pixels separated by drow from the 
            //input matrix to local memory. Every worker in a workgroup 
            //retrieves one or more pixels, depending on image size.

            for (int n = 0; n < (int)X; n++) {
                in1 = (get_local_id(1) + n * (int)M) * (int)N + i;
                in2 = (get_local_id(1) + n * (int)M) * (int)N + (i + drow);

                pixels1[(get_local_id(1) + n * (int)M)] = A[in1];
                pixels2[(get_local_id(1) + n * (int)M)] = A[in2];
            }
            
            //Wait until all workers have stopped accessing local memory
			barrier(CLK_LOCAL_MEM_FENCE);
		
            //Increment temporary variables using data from the pixels in
            //local memory.
			for (int j = 0; j < (int)N - dcol; j++) {
				Nr_L += 1;

				Isum_pp += pixels1[j];
				Isqsum_pp += pixels1[j] * pixels1[j];
				
				Isum_np += pixels2[j];
				Isqsum_np += pixels2[j] * pixels2[j];
				
				Isum_pn += pixels1[j + dcol];
				Isqsum_pn += pixels1[j + dcol] * pixels1[j + dcol];
				
				Isum_nn += pixels2[j + dcol];
				Isqsum_nn += pixels2[j + dcol] * pixels2[j + dcol];
			}
			
            //Wait until all workers have stopped accessing local memory
			barrier(CLK_LOCAL_MEM_FENCE);
		}

		int width = (2 * (int)N - 1);
		int offset = ((int)N - 1);

        //Assign temporary variables to indices in output matrices

        Nr[(offset + dcol) * width + offset + drow] = Nr_L;
        Nr[(offset + dcol) * width + offset - drow] = Nr_L;
        Nr[(offset - dcol) * width + offset + drow] = Nr_L;
        Nr[(offset - dcol) * width + offset - drow] = Nr_L;

        Isum[(offset + dcol) * width + offset + drow] = Isum_pp;
        Isum[(offset + dcol) * width + offset - drow] = Isum_np;
        Isum[(offset - dcol) * width + offset + drow] = Isum_pn;
        Isum[(offset - dcol) * width + offset - drow] = Isum_nn;

        Isqsum[(offset + dcol) * width + offset + drow] = Isqsum_pp;
        Isqsum[(offset + dcol) * width + offset - drow] = Isqsum_np;
        Isqsum[(offset - dcol) * width + offset + drow] = Isqsum_pn;
        Isqsum[(offset - dcol) * width + offset - drow] = Isqsum_nn;
}

__kernel void acf(__constant double *A, __constant double *I1avg,
                    __constant double *I2avg, __global double *B) {

        //Initialize temporary storage for pixels in local memory
        __local double pixels1[(int)N];
		__local double pixels2[(int)N];

		int drow = get_global_id(0);
		int dcol = get_global_id(1);

        //Initialize temporary variables
        double B_pp = 0;
        double B_np = 0;
        double B_pn = 0;
        double B_nn = 0;
        
        int width = (2 * (int)N - 1);
		int offset = ((int)N - 1);

        //Obtain values from input matrices
        double I1avg_pp = I1avg[(offset + dcol) * width + offset + drow];
        double I1avg_np = I1avg[(offset + dcol) * width + offset - drow];
        double I1avg_pn = I1avg[(offset - dcol) * width + offset + drow];
        double I1avg_nn = I1avg[(offset - dcol) * width + offset - drow];
        
        double I2avg_pp = I2avg[(offset + dcol) * width + offset + drow];
        double I2avg_np = I2avg[(offset + dcol) * width + offset - drow];
        double I2avg_pn = I2avg[(offset - dcol) * width + offset + drow];
        double I2avg_nn = I2avg[(offset - dcol) * width + offset - drow];

        int in1;
		int in2;
		
		for (int i = 0; i < (int)N - drow; i++) {

            //Retrieve two rows of pixels separated by drow from the 
            //input matrix to local memory. Every worker in a workgroup 
            //retrieves one or more pixels, depending on image size.

            for (int n = 0; n < (int)X; n++) {
                in1 = (get_local_id(1) + n * (int)M) * (int)N + i;
                in2 = (get_local_id(1) + n * (int)M) * (int)N + (i + drow);

                pixels1[(get_local_id(1) + n * (int)M)] = A[in1];
                pixels2[(get_local_id(1) + n * (int)M)] = A[in2];
            }

            //Wait until all workers have stopped accessing local memory
			barrier(CLK_LOCAL_MEM_FENCE);

            //Increment temporary variables using data from the pixels in
            //local memory.
		
			for (int j = 0; j < (int)N - dcol; j++) {
				
                B_pp += (pixels1[j] - I1avg_pp) * (pixels2[j + dcol] - I2avg_pp);
                B_np += (pixels2[j] - I1avg_np) * (pixels1[j + dcol] - I2avg_np);
                B_pn += (pixels1[j + dcol] - I1avg_pn) * (pixels2[j] - I2avg_pn);
                B_nn += (pixels2[j + dcol] - I1avg_nn) * (pixels1[j] - I2avg_nn);
			}
	
            //Wait until all workers have stopped accessing local memory
			barrier(CLK_LOCAL_MEM_FENCE);
		}

        //Assign temporary variables to indices in output matrices

        B[(offset + dcol) * width + offset + drow] = B_pp;
        B[(offset + dcol) * width + offset - drow] = B_np;
        B[(offset - dcol) * width + offset + drow] = B_pn;
        B[(offset - dcol) * width + offset - drow] = B_nn;
}