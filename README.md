# pvt-simulator
High-performance optical fabrication simulation based on the Position-Velocity-Time (PVT) motion control model.

## Introduction
This repository provides a PVT-based, fast velocity scheduler and simulator for the control of stages in optical fabrication. The core modules are listed as follows. PVT describes the motion as 3rd order polynomials as
$$a_{i}t_{i-1}^3+b_{i}t_{i-1}^2+c_{i}t_{i-1}+d_{i}=p_{i-1}$$
$$a_{i}t_{i}^3+b_{i}t_{i}^2+c_{i}t_{i}+d_{i}=p_{i}~~~~~~~~~~~~~$$
$$3a_{i}t_{i-1}^2+2b_{i}t_{i-1}+c_{i}=v_{i-1}~~~~~~~~~~$$
$$3a_{i}t_{i}^2+2b_{i}t_{i}+c_{i}=v_{i}~~~~~~~~~~~~~~~~~~~~$$
where $a_{i}$, $b_{i}$, $c_{i}$, $d_{i}$ are the polynomial coefficients, $p_{i}$, $v_{i}$ are positions and velocities at the $i$-th point. In optical fabrication, we always know the **Time** and **Positions** and need to calculate the **Velocities**. This is solved under the PVT framework in this repository. 

## MATLAB module
MATLAB module is provided as a fast simulator when the problem size is small. It is easy to use and the simulation animation can be saved as a video. But this takes unreasonablly long time as the problem size grows.

## C++ module
C++ module is necessary if the number of dwell points is large and the demanded simulation grid is dense. It relies on paralle computing and high-performance math libraries.
- **pvtengine**: the implementation of the PVT-based scheduler and simulator algorithms
  - Scheduler: given $p_{i}$ and $t_{i}$, calculate $v_{i}$ and $a_{i}$, $b_{i}$, $c_{i}$, $d_{i}$ via optimization.
  - Sampler: re-sample the scheduled PVTs to prepare for more precise material removal estimation.
  - Simulator: given a Tool Influence Function (TIF) and the scheduled PVT, simulate the material removal process.
- **unittest**: test the engine using Google test.
- **pvtapp**: a UI application provided to show the animation of the simulation in real time.

## Dependencies
1. [Intel Math Kernel Library (MKL)](https://www.intel.com/content/www/us/en/developer/tools/oneapi/toolkits.html): using BLAS and LAPACK rountines optimized on Intel processors. Eigen below is also using MKL.
2. [Eigen](https://eigen.tuxfamily.org/index.php?title=Main_Page): for convenient matrix and vector manipulations.
3. [qpOASES](https://github.com/coin-or/qpOASES.git): for the QP solver used in the velocity optimization. A Visual Studio 2022, dynamically linked version is also available at [TWANG006/qpOASES](https://github.com/TWANG006/qpOASES.git).
4. [QT](https://www.qt.io/download): for GUI, which is optional.
5. [QCustomPlot](https://www.qcustomplot.com/): for plotting and anmiation.

## Compilation
1. Windows + Visual Studio 2022: this is the default configuration that can be directly used.
2. Mac OS: TODO
3. Linux: TODO

## References
TODO
