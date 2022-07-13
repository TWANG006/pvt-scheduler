#ifndef SAMPLER_H
#define SAMPLER_H

#include "pvtengine.h"




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