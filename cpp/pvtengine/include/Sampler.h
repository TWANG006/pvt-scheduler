#ifndef SAMPLER_H
#define SAMPLER_H

class Sampler
{
public:
	// Default constructor
	Sampler() = default;

	// Disable copyping
	Sampler(const Sampler&) = delete;
	Sampler& operator=(const Sampler&) = delete;

	//! Overloaded () operator to calculte the super-sampled PVT grids

};


#endif // !SAMPLER_H