#ifndef SIMULATOR_H
#define SIMULATOR_H

#include "pvtengine.h"

//! This class performs the velocity-based fabrication simulation.
/*!
* An entire optical fabrication procedure is
* 1) Measure the surface, calculate the desired material removal Z.
* 2) Extract the TIF
* 3) Use Z and TIF to optimize dwell time T
* 4) Schedule the PVT with the 'Scheduler'
* 5) Upsample the PVT with 'Sampler'
* 6) With the up-sampled PVT and the 'Interpolator', calculate the
*    removal at different dwell point using 'Simulator'
*/
class Simulator
{
public:

};


#endif // !SIMULATOR_H