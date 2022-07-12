#include "pch.h"
#include "Scheduler.h"

TEST(Scheduler, build_QP) {
	VectorXd px(5);
	px << 1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3;
	VectorXd t(5);
	t << 0, 0.1, 0.12, 0.23, 0.3;

	Scheduler s(px, t, 250e-3, 2);
	PVT pvt_test = s(0.0, 0.0, 0.0, 0.0, true);

	std::cout << pvt_test.P << std::endl << std::endl;
	std::cout << pvt_test.V << std::endl << std::endl;
	std::cout << pvt_test.T << std::endl << std::endl;
	std::cout << pvt_test.Coeffs << std::endl << std::endl;
}