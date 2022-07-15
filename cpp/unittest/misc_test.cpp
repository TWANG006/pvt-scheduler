#include "pch.h"
#include "pvtengine.h"

TEST(misc_test, meshgrid_test)
{
	int Nx = 10;
	int Ny = 5;

	double xmin = -1, xmax = 8;
	double ymin = -1, ymax = 3;

	auto dx = (xmax - xmin) / (Nx - 1);
	auto dy = (ymax - ymin) / (Ny - 1);

	VectorXd x = VectorXd::LinSpaced(Nx, xmin, xmax);
	VectorXd y = VectorXd::LinSpaced(Ny, ymin, ymax);

	MatrixXXd X, Y;

	meshgrid(x, y, X, Y);

	Y = (Y.maxCoeff() - Y.array() + Y.minCoeff()).matrix();

	std::cout << X << std::endl;
	std::cout << Y << std::endl;

	std::cout << Y.colwise().reverse() << std::endl;
}