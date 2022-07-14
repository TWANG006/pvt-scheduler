#ifndef SAMPLER_H
#define SAMPLER_H

#include "pvtengine.h"

//! This is the class to up-sample the calculate sparse PVT grid
/*! 
* The class has an overloaded () operator, which accept 'tau' and
* the sparse PVT as the inputs. 'tau' is the delta t used to up-
* sample the PVT grid.
*/
class PVTENGINE_API Sampler
{
public:
	//! Default constructor
	Sampler() = default;

	//! Disable copyping
	Sampler(const Sampler&) = delete;
	Sampler& operator=(const Sampler&) = delete;

	//! Overloaded () operator to calculte the super-sampled PVT grids
	PVA operator () (
		const double & tau,  /*!< [in] the delta_t used to upsample the PVT grid */
		const PVTC& sparsePVT/*!< [in] the existing sparse PVT*/
	);
};


#endif // !SAMPLER_H