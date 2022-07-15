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
