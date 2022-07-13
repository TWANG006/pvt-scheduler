#include "pch.h"
#include "Sampler.h"

PVA Sampler::operator()(const double& tau, const PVTC& sparsePVT)
{
	auto num_v = sparsePVT.V.size() - 1;// number of velocities
	VectorXi startIds = VectorXi::Zero(num_v);// start id for each segment

	// 1. run the iterations to get the total number of V in the dense PVT
	Eigen::Index num_dense_v = 0;
	for (Eigen::Index i = 0; i < num_v; i++) {
		// get t0 for each segment
		double t0 = 0.0;
		if (i == 0) {
			t0 = sparsePVT.T(i);
		}
		else {
			t0 = sparsePVT.T(i) + tau;
		}

		// get t1 for each segment
		double t1 = sparsePVT.T(i + 1);

		// get the number of points to be generated between t0 and t1
		num_dense_v += ceil((t1 - t0) / tau);

		if (i < num_v - 1) {
			startIds(i + 1) = num_dense_v;
		}
	}

	// 2. run the iterations again to obtain the dense P V and A


	return PVA();
}
