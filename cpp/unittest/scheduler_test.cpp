#include "pch.h"
#include "Scheduler.h"

TEST(Eigen, Row_or_Col_major) {
	MatrixX4d M{
		{1, 2, 3, 4}, 
		{5, 6, 7, 8}
	};

	std::cout << M << std::endl;
	std::cout << M.data()[0] << M.data()[1] << std::endl;

	Eigen::Matrix3d N{
		{1, 2, 3},
		{4, 5, 6},
		{7, 8, 9}
	};

	std::cout << N << std::endl;
	std::cout << N.data()[0] << N.data()[1] << std::endl;

}

TEST(Scheduler, build_QP) {
	VectorXd px(5);
	px << 1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3;
	VectorXd t(5);
	t << 0, 0.1, 0.12, 0.23, 0.3;

	Scheduler s(px, t, 250e-3, 2);
	s();
}