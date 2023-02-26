#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="Curaba_test"
#SBATCH --partition=EPYC
#or FHPC
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=2:00:00

module load architecture/AMD
module load mkl
module load openBLAS/0.3.21-omp

export code=/u/dssc/ccurab00/scratch/Foundations_of_HPC_2022/Assignment/exercise2
export OMP_NUM_THREADS=64
# export LD_LIBRARY_PATH=/u/dssc/ccurab00/scratch/blis/lib:$LD_LIBRARY_PATH
# export BLIS_NUM_THREADS=64
export OMP_PLACES=sockets
export OMP_PROC_BIND=spread


cd $code
make clean
make cpu

gcc -fopenmp 00_where_I_am.c -o 00_where_I_am.x
rm where_I_am.csv
./00_where_I_am.x >> where_I_am_sockets_spread.csv

for i in {0..20}
do	let size=$((2000+2000*$i))
        for j in {1..3}
        do 
           	echo $size
                ./gemm_mkl.x $size $size $size >> 1_double_mkl_EPYC_sockets_spread.csv
                ./gemm_oblas.x $size $size $size >> 1_double_oblas_EPYC_sockets_spread.csv
#              	./gemm_blis.x $size $size $size >> 1_float_blis_64.csv
        done
done
