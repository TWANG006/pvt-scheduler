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
	auto id = Z.array().isNaN();
	VectorXd x = id.select(0, X);
	VectorXd z = id.select(0, Z);
	std::cout << x << std::endl;
	std::cout << z << std::endl;

	return MatrixXXd();
}

MatrixXXd remove_polynomials(const MatrixXXd& X, const MatrixXXd& Y, const MatrixXXd& Z, int_t p)
{
	return MatrixXXd();
}
