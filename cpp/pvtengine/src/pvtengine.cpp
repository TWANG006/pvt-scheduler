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
