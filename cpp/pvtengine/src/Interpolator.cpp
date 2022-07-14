#include "pch.h"
#include "Interpolator.h"

Interpolator::Interpolator(const MatrixXXd& X, const MatrixXXd& Y, const MatrixXXd& Z)
{
	//1. Precompute the gradients of Z

}

void Interpolator::build_bicubic_interpolant(const MatrixXXd& X, const MatrixXXd& Y, const MatrixXXd& Z)
{
	auto Ny = Z.rows();// number of rows
	auto Nx = Z.cols();// number of cols

	// pre-allocate the space for the LUT
	m_LUT = Matrix44dArray(Ny - 1, Nx - 1);

	// construct the Left and Right matrices
	/*
	 *|a00 a01 a02 a03| | 1  0  0  0 || f00  f01  fy00  fy01||1  0 -3 2|
	 *|a10 a11 a12 a13|=| 0  0  1  0 || f10  f11  fy10  fy11||0  0  3 2|
	 *|a20 a21 a22 a23| |-3  3 -2  -1||fx00 fx01 fxy00 fxy00||0  1 -2 1|
	 *|a30 a31 a32 a33| | 2 -2  1  1 ||fx10 fx11 fxy10 fxy11||0  0 -1 1|
	*/
	Matrix44d L{
		{ 1,  0,  0,  0},
		{ 0,  0,  1,  0},
		{-3,  3, -2, -1},
		{ 2, -2,  1,  1},
	};
	Matrix44d R{
		{ 1,  0, -3,  2},
		{ 0,  0,  3, -2},
		{ 0,  1, -2,  1},
		{ 0,  0, -1,  1}
	};

	// precompute the coefficients for each interval
	for (int_t i = 0; i < Ny - 1; i++) {
		for (int_t j = 0; j < Nx - 1; j++) {
			// calculate the F matrix
			double  f00  = Z(i, j    ), f01  = Z(i + 1, j    ), fy00  = 0.0, fy01  = 0.0;
			double  f10  = Z(i, j + 1), f11  = Z(i + 1, j + 1), fy10  = 0.0, fy11  = 0.0;
			double  fx00 = 0.0,         fx01 = 0.0,             fxy00 = 0.0, fxy01 = 0.0;
			double  fx10 = 0.0,         fx11 = 0.0,             fxy10 = 0.0, fxy11 = 0.0;

			auto dy = Y(i + 1, j) - Y(i, j);//(i,j)th length in y
			auto dx = X(i, j + 1) - X(i, j);//(i,j)th length in x

			// using the central-difference to calculate interior gradients
			// and forwrad- and backward-difference on the edges.
			// calculate gradient y (row)
			auto ip = std::max<int_t>(i - 1, 0);     // (i-1)th id
			auto in = std::min<int_t>(i + 1, Ny - 1);// (i+1)th id
			auto hy = (Y(in, j) - Y(ip, j)) / dy;// dist between (i-1) and (i+1)
			fy00 = (Z(in, j) - Z(ip, j)) / hy;
			fy10 = (Z(in, j + 1) - Z(ip, j + 1)) / hy;

			ip = std::max<int_t>(i, 0);
			in = std::min<int_t>(i + 2, Ny - 1);
			hy = (Y(in, j) - Y(ip, j)) / dy;
			fy01 = (Z(in, j) - Z(ip, j)) / hy;
			fy11 = (Z(in, j + 1) - Z(ip, j + 1)) / hy;

			// calculate the gradient x (col);
			auto jp = std::max<int_t>(j - 1, 0);
			auto jn = std::min<int_t>(j + 1, Nx - 1);
			auto hx = (X(i, jn) - X(i, jp)) / dx;
			fx00 = (Z(i, jn) - Z(i, jp)) / hx;
			fx01 = (Z(i + 1, jn) - Z(i + 1, jp)) / hx;

			jp = std::max<int_t>(j, 0);
			jn = std::min<int_t>(j + 2, Nx - 1);
			hx = (X(i, jn) - X(i, jp)) / dx;
			fx10 = (Z(i, jn) - Z(i, jp)) / hx;
			fx11 = (Z(i + 1, jn) - Z(i + 1, jp)) / hx;

			// calculate gradient xy
			ip = std::max<int_t>(i - 1, 0);
			in = std::min<int_t>(i + 1, Ny - 1);
			jp = std::max<int_t>(j - 1, 0);
			jn = std::min<int_t>(j + 1, Nx - 1);
			hy = (Y(in, j) - Y(ip, j)) / dy;
			hx = (X(i, jn) - X(i, jp)) / dx;
			fxy00 = ((Z(in, jn) - Z(in, jp)) / hx - (Z(ip, jn) - Z(ip, jp)) / hx) / hy;

			ip = std::max<int_t>(i, 0);
			in = std::min<int_t>(i + 2, Ny - 1);
			hy = (Y(in, j) - Y(ip, j)) / dy;
			fxy01 = ((Z(in, jn) - Z(in, jp) / hx - (Z(ip, jn) - Z(ip, jp)) / hx)) / hy;

			ip = std::max<int_t>(i - 1, 0);
			in = std::min<int_t>(i + 1, Ny - 1);
			jp = std::max<int_t>(j, 0);
			jn = std::min<int_t>(j + 2, Nx - 1);
			hy = (Y(in, j) - Y(ip, j)) / dy;
			hx = (X(i, jn) - X(i, jp)) / dx;
			fxy10 = ((Z(in, jn) - Z(in, jp)) / hx - (Z(ip, jn) - Z(ip, jp)) / hx) / hy;

			ip = std::max<int_t>(i, 0);
			in = std::min<int_t>(i + 2, Ny - 1);
			hy = (Y(in, j) - Y(ip, j)) / dy;
			fxy11 = ((Z(in, jn) - Z(in, jp)) / hx - (Z(ip, jn) - Z(ip, jp)) / hx) / hy;

			// construct the matrix F
			Matrix44d F{
				{f00,  f01,  fy00,  fy01},
				{f10,  f11,  fy10,  fy11},
				{fx00, fx01, fxy00, fxy01},
				{fx10, fx11, fxy10, fxy11},
			};

			// calculate the (i,j)th matrix A
			m_LUT(i, j) = L * F * R;
		}
	}
}

void Interpolator::precompute_gradients(const MatrixXXd& Z, MatrixXXd& Zx, MatrixXXd& Zy, MatrixXXd& Zxy)
{

}
