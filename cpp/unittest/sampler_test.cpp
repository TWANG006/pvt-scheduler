#include "pch.h"
#include "Scheduler.h"
#include "Sampler.h"

TEST(PVT, Sampler)
{
	VectorXd px{
		{1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3 },
	};
	VectorXd t{
		{0, 0.1, 0.12, 0.23, 0.3},
	};

	// shcedule the sparse PVT
	Scheduler s(px, t, 250e-3, 2);
	PVTC sparsePVT = s(0.0, 0.0, 0.0, 0.0, true);

	std::cout << "Sparse Position is: " << std::endl;
	std::cout << sparsePVT.P.transpose() << std::endl;

	std::cout << "Sparse Velocity is: " << std::endl;
	std::cout << sparsePVT.V.transpose() << std::endl;

	// upsampling
	double tau = 1 / 60.0;
	Sampler sampler;
	PVA densePVA = sampler(tau, sparsePVT);

	// result
	std::cout << "Dense Position is: " << std::endl;
	std::cout << densePVA.P.transpose() << std::endl;

	std::cout << "Dense Velocity is: " << std::endl;
	std::cout << densePVA.V.transpose() << std::endl;

	std::cout << "Dense Acceleration is: " << std::endl;
	std::cout << densePVA.A.transpose() << std::endl;
}