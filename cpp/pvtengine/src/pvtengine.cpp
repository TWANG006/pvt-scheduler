// pvtengine.cpp : Defines the exported functions for the DLL.
//


#include "pch.h"
#include "framework.h"
#include "pvtengine.h"

PVTENGINE_API void meshgrid(const VectorXd& x, const VectorXd& y, MatrixXXd& X, MatrixXXd& Y)
{
	auto Nx = x.size();
	auto Ny = y.size();

	X = x.transpose().replicate(Ny, 1);
	Y = y.replicate(1, Nx);
}

PVTENGINE_API double PV(const MatrixXXd& Z)
{
	return (Z.maxCoeff() - Z.minCoeff());
}

PVTENGINE_API double PV(const VectorXd& z)
{
	return (z.maxCoeff() - z.minCoeff());
}

PVTENGINE_API double RMS(const MatrixXXd& Z)
{
	return sqrt(((Z.array() - Z.mean()).square().sum() / (Z.size() - 1)));
}

PVTENGINE_API double RMS(const VectorXd& Z)
{
	return sqrt(((Z.array() - Z.mean()).square().sum() / (Z.size() - 1)));
}

PVTENGINE_API MatrixXXd remove_polynomials(VectorXd& coeffs, const MatrixXXd& X, const MatrixXXd& Y, const MatrixXXd& Z, int_t p)
{
	std::vector<double> x, y, z;

	for (int_t i = 0; i < Z.rows(); i++) {
		for (int_t j = 0; j < Z.cols(); j++) {
			if (std::isfinite(Z(i, j))) {
				x.push_back(X(i, j));
				y.push_back(Y(i, j));
				z.push_back(Z(i, j));
			}
		}
	}
	VectorXd vx = Eigen::Map<VectorXd, Eigen::Unaligned>(x.data(), x.size());
	VectorXd vy = Eigen::Map<VectorXd, Eigen::Unaligned>(y.data(), y.size());
	VectorXd vz = Eigen::Map<VectorXd, Eigen::Unaligned>(z.data(), z.size());

	// build the design matrix
	MatrixXXd H = MatrixXXd::Ones(vz.size(), (p + 1) * (p + 2) / 2);
	
	int_t k = 0;
	for (int_t s = 0; s < p + 1; s++) {
		for (int_t a = s; a > -1; a--) {
			auto b = s - a;
			H.col(k) = (vx.array().pow(a) * vy.array().pow(b)).matrix();
			k += 1;
		}
	}
	coeffs = H.colPivHouseholderQr().solve(vz);

	// fitting
	MatrixXXd Zf = MatrixXXd::Zero(Z.rows(), Z.cols());
	k = 0;
	for (int_t s = 0; s < p + 1; s++) {
		for (int_t a = s; a > -1; a--) {
			auto b = s - a;
			Zf = Zf + (coeffs(k) * X.array().pow(a) * Y.array().pow(b)).matrix();
			k += 1;
		}
	}

	// residual
	return (Z - Zf);
}

MatrixXXd remove_polynomials(const MatrixXXd& X, const MatrixXXd& Y, const MatrixXXd& Z, int_t p)
{
	return MatrixXXd();
}
