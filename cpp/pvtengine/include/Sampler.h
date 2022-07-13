#ifndef SAMPLER_H
#define SAMPLER_H

#include "pvtengine.h"

class Sampler
{
public:
	// Default constructor
	Sampler() = default;

	// Disable copyping
	Sampler(const Sampler&) = delete;
	Sampler& operator=(const Sampler&) = delete;

	//! Overloaded () operator to calculte the super-sampled PVT grids
	PVT operator () (
		const double & tau,
		const PVT& sparsePVT
	);
};


#endif // !SAMPLER_H