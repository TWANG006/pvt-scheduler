#include "pch.h"
#include "Scheduler.h"

TEST(PVT, Scheduler) {
	VectorXd px(5);
	px << 1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3;
	VectorXd t(5);
	t << 0, 0.1, 0.12, 0.23, 0.3;

	Scheduler s(px, t, 250e-3, 2);
	PVTC pvt_test = s(0.0, 0.0, 0.0, 0.0, true);
	
	std::cout << "Position is: " << std::endl;
	std::cout << pvt_test.P.transpose() << std::endl;

	std::cout << "Velocity is: " << std::endl;
	std::cout << pvt_test.V.transpose() << std::endl;

	std::cout << "Time is: " << std::endl;
	std::cout << pvt_test.T.transpose() <<std::endl;

	std::cout << "Coefficient is: " << std::endl;
	std::cout << pvt_test.Coeffs << std::endl;
}