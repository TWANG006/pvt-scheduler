#include "pch.h"
#include "Sampler.h"
#include "Calculator.h"

PVA Sampler::operator()(const double& tau, const PVTC& sparsePVT)
{
	auto num_v = sparsePVT.V.size() - 1;// number of velocities
	VectorXi startIds = VectorXi::Zero(num_v);// start id for each segment

	// 1. run the iterations to get the total number of V in the dense PVT
	int_t num_dense_v = 0;
	for (int_t i = 0; i < num_v; i++) {
		// get t0 for each segment
		double t0 = 0.0;
		if (i == 0) { t0 = sparsePVT.T(i); }
		else { t0 = sparsePVT.T(i) + tau; }

		// get t1 for each segment
		double t1 = sparsePVT.T(i + 1);

		// get the number of points to be generated between t0 and t1
		num_dense_v += (int_t)ceil((t1 - t0) / tau);

		if (i < num_v - 1) {
			startIds(i + 1) = num_dense_v;
		}
	}
	// 2. run the iterations again to obtain the dense P V and A
	PVA densePVA{
		VectorXd::Zero(num_dense_v),
		VectorXd::Zero(num_dense_v),
		VectorXd::Zero(num_dense_v),
	};
    //#pragma omp parallel for
	for (int_t i = 0; i < num_v; i++) {
		// get t0 for each segment
		double t0 = 0.0;
		if (i == 0) { t0 = sparsePVT.T(i); }
		else { t0 = sparsePVT.T(i) + tau; }

		// get t1 for each segment
		double t1 = sparsePVT.T(i + 1);

		// get the t's for each segment
		VectorXd t02t1 = VectorXd::LinSpaced((int_t)ceil((t1 - t0) / tau), t0, t1);
		auto num_t02t1 = t02t1.size();

		// calculate P, V, A for each element
		VectorXd P, V, A;
		calculate_pvt(P, V, A, t02t1, sparsePVT.Coeffs.row(i));

		densePVA.P(seqN(startIds(i), num_t02t1)) = P;
		densePVA.V(seqN(startIds(i), num_t02t1)) = V;
		densePVA.A(seqN(startIds(i), num_t02t1)) = A;
	}

	return densePVA;
}
