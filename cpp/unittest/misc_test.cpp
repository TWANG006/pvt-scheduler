#include "pch.h"
#include "pvtengine.h"
#include "osqp++.h"

TEST(misc_test, remove)
{
	VectorXd x{ {1, 2}, };
	VectorXd y{ {1, 2}, };
	MatrixXXd X, Y;
	meshgrid(x, y, X, Y);

	MatrixXXd Z{ {1, NAN}, {1, 1}, };
	std::cout << Z << std::endl;
	VectorXd coeffs;
	remove_polynomials(coeffs, X, Y, Z, 1);
}

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

TEST(misc_test, eigen_mul)
{
	MatrixXXd matBinData1 = MatrixXXd::Random(2, 3);
	Eigen::MatrixXd matBinData2 = matBinData1;

	std::cout << matBinData1 << std::endl;
	std::cout << matBinData2 << std::endl;
}

TEST(misc_test, osqpcpp)
{
	const double kInfinity = std::numeric_limits<double>::infinity();
	Eigen::SparseMatrix<double, Eigen::RowMajor> objective_matrix(2, 2);

	const Eigen::Triplet<double> kTripletsP[] = {
	{0, 0, 2.0}, {1, 0, 0.5}, {0, 1, 0.5}, {1, 1, 2.0} };
	objective_matrix.setFromTriplets(std::begin(kTripletsP),
		std::end(kTripletsP));

	Eigen::SparseMatrix<double, Eigen::RowMajor> constraint_matrix(1, 2);
	const Eigen::Triplet<double> kTripletsA[] = { {0, 0, 1.0} };
	constraint_matrix.setFromTriplets(std::begin(kTripletsA),
		std::end(kTripletsA));

	osqp::OsqpInstance instance;
	instance.objective_matrix = objective_matrix;
	instance.objective_vector.resize(2);
	instance.objective_vector << 1.0, 0.0;
	instance.constraint_matrix = constraint_matrix;
	instance.lower_bounds.resize(1);
	instance.lower_bounds << 1.0;
	instance.upper_bounds.resize(1);
	instance.upper_bounds << kInfinity;

	osqp::OsqpSolver solver;
	osqp::OsqpSettings settings;
	// Edit settings if appropriate.
	auto status = solver.Init(instance, settings);
	// Assuming status.ok().
	osqp::OsqpExitCode exit_code = solver.Solve();
	//// Assuming exit_code == OsqpExitCode::kOptimal.
	//double optimal_objective = solver.objective_value();
	Eigen::VectorXd optimal_solution = solver.primal_solution();

	std::cout << optimal_solution << std::endl;
}