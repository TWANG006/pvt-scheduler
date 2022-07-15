#include "pch.h"
#include "Interpolator.h"

TEST(Interpolator, Simple_function)
{
	// build the test data
	int Nx = 10;
	int Ny = 5;

	double xmin = -1, xmax = 8;
	double ymin = -1, ymax = 3;

	VectorXd x = VectorXd::LinSpaced(Nx, xmin, xmax);
	VectorXd y = VectorXd::LinSpaced(Ny, ymin, ymax);

	MatrixXXd X, Y;
	meshgrid(x, y, X, Y);

	// test function
	auto f = [](double x, double y) {return x * y + 2 * x + 3 * y; };

	MatrixXXd Z(Ny, Nx);
	for (int i = 0; i < Ny; i++) {
		for (int j = 0; j < Nx; j++) {
			Z(i, j) = f(X(i, j), Y(i, j));
		}
	}

	// build the interpolator
	Interpolator bicubic(X, Y, Z);

	std::cout << bicubic(1.5, 2.2) << ", " << bicubic(2.1, 2.3) << std::endl;

	ASSERT_NEAR(bicubic(1.5, 2.2),  f(1.5, 2.2), 0.1);
	ASSERT_NEAR(bicubic(0, 0),  f(0, 0), 0.1);
	ASSERT_NEAR(bicubic(2, -1), f(2, -1), 0.1);

	ASSERT_NEAR(bicubic(-2, -1), 0, 0.00002);
	ASSERT_NEAR(bicubic(10, 3), 0, 0.00002);
}