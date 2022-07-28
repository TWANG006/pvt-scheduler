#include "pch.h"
#include "Interpolator.h"

Interpolator::Interpolator(const MatrixXXd& X, const MatrixXXd& Y, const MatrixXXd& Z)
	: m_X(X)
	, m_Y(Y)
	, m_Z(Z)
	, m_xmin(X.minCoeff())
	, m_xmax(X.maxCoeff())
	, m_ymin(Y.minCoeff())
	, m_ymax(Y.maxCoeff())
	, m_xrange(X.row(0).cbegin(), X.row(0).cend())
	, m_yrange(Y.col(0).cbegin(), Y.col(0).cend())
{
	//1. Precompute the gradients of Z
	build_bicubic_interpolant();
}

double Interpolator::operator()(const double& x, const double& y) const
{
	return interp(x, y);
}

MatrixXXd Interpolator::operator()(const MatrixXXd& X, const MatrixXXd& Y) const
{
	auto Ny = X.rows();
	auto Nx = X.cols();

	MatrixXXd Z(Ny, Nx);

	for (int_t i = 0; i < Ny; i++) {
		for (int_t j = 0; j < Nx; j++) {
			Z(i, j) = interp(X(i, j), Y(i, j));
		}
	}

	return Z;
}

MatrixXXd Interpolator::multi_thread_interp(const MatrixXXd& X, const MatrixXXd& Y) const
{
	auto Ny = X.rows();
	auto Nx = X.cols();

	MatrixXXd Z(Ny, Nx);

	#pragma omp parallel for
	for (int_t i = 0; i < Ny; i++) {
		for (int_t j = 0; j < Nx; j++) {
			Z(i, j) = interp(X(i, j), Y(i, j));
		}
	}

	return Z;
}


void Interpolator::build_bicubic_interpolant()
{
	auto Ny = m_Z.rows();// number of rows
	auto Nx = m_Z.cols();// number of cols

	// pre-allocate the space for the LUT
	m_LUT = Matrix44dArray(Ny - 1, Nx - 1);

	// construct the Left and Right matrices
	/*
	 *|a00 a01 a02 a03| | 1  0  0  0 || f00  f01  fy00  fy01||1  0 -3  2|
	 *|a10 a11 a12 a13|=| 0  0  1  0 || f10  f11  fy10  fy11||0  0  3 -2|
	 *|a20 a21 a22 a23| |-3  3 -2  -1||fx00 fx01 fxy00 fxy00||0  1 -2  1|
	 *|a30 a31 a32 a33| | 2 -2  1  1 ||fx10 fx11 fxy10 fxy11||0  0 -1  1|
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
    #pragma omp parallel for
	for (int_t i = 0; i < Ny - 1; i++) {
		for (int_t j = 0; j < Nx - 1; j++) {
			// calculate the F matrix
			double  f00  = m_Z(i, j    ), f01  = m_Z(i + 1, j    ), fy00  = 0.0, fy01  = 0.0;
			double  f10  = m_Z(i, j + 1), f11  = m_Z(i + 1, j + 1), fy10  = 0.0, fy11  = 0.0;
			double  fx00 = 0.0,           fx01 = 0.0,               fxy00 = 0.0, fxy01 = 0.0;
			double  fx10 = 0.0,           fx11 = 0.0,               fxy10 = 0.0, fxy11 = 0.0;

			auto dy = m_Y(i + 1, j) - m_Y(i, j);//(i,j)th length in y
			auto dx = m_X(i, j + 1) - m_X(i, j);//(i,j)th length in x

			// using the central-difference to calculate interior gradients
			// and forwrad- and backward-difference on the edges.
			// calculate gradient y (row)
			auto ip = std::max<int_t>(i - 1, 0);     // (i-1)th id
			auto in = std::min<int_t>(i + 1, Ny - 1);// (i+1)th id
			auto hy = (m_Y(in, j) - m_Y(ip, j)) / dy;// dist between (i-1) and (i+1)
			fy00 = (m_Z(in, j) - m_Z(ip, j)) / hy;
			fy10 = (m_Z(in, j + 1) - m_Z(ip, j + 1)) / hy;

			ip = std::max<int_t>(i, 0);
			in = std::min<int_t>(i + 2, Ny - 1);
			hy = (m_Y(in, j) - m_Y(ip, j)) / dy;
			fy01 = (m_Z(in, j) - m_Z(ip, j)) / hy;
			fy11 = (m_Z(in, j + 1) - m_Z(ip, j + 1)) / hy;

			// calculate the gradient x (col);
			auto jp = std::max<int_t>(j - 1, 0);
			auto jn = std::min<int_t>(j + 1, Nx - 1);
			auto hx = (m_X(i, jn) - m_X(i, jp)) / dx;
			fx00 = (m_Z(i, jn) - m_Z(i, jp)) / hx;
			fx01 = (m_Z(i + 1, jn) - m_Z(i + 1, jp)) / hx;

			jp = std::max<int_t>(j, 0);
			jn = std::min<int_t>(j + 2, Nx - 1);
			hx = (m_X(i, jn) - m_X(i, jp)) / dx;
			fx10 = (m_Z(i, jn) - m_Z(i, jp)) / hx;
			fx11 = (m_Z(i + 1, jn) - m_Z(i + 1, jp)) / hx;

			// calculate gradient xy
			ip = std::max<int_t>(i - 1, 0);
			in = std::min<int_t>(i + 1, Ny - 1);
			jp = std::max<int_t>(j - 1, 0);
			jn = std::min<int_t>(j + 1, Nx - 1);
			hy = (m_Y(in, j) - m_Y(ip, j)) / dy;
			hx = (m_X(i, jn) - m_X(i, jp)) / dx;
			fxy00 = ((m_Z(in, jn) - m_Z(in, jp)) / hx - (m_Z(ip, jn) - m_Z(ip, jp)) / hx) / hy;

			ip = std::max<int_t>(i, 0);
			in = std::min<int_t>(i + 2, Ny - 1);
			hy = (m_Y(in, j) - m_Y(ip, j)) / dy;
			fxy01 = ((m_Z(in, jn) - m_Z(in, jp) / hx - (m_Z(ip, jn) - m_Z(ip, jp)) / hx)) / hy;

			ip = std::max<int_t>(i - 1, 0);
			in = std::min<int_t>(i + 1, Ny - 1);
			jp = std::max<int_t>(j, 0);
			jn = std::min<int_t>(j + 2, Nx - 1);
			hy = (m_Y(in, j) - m_Y(ip, j)) / dy;
			hx = (m_X(i, jn) - m_X(i, jp)) / dx;
			fxy10 = ((m_Z(in, jn) - m_Z(in, jp)) / hx - (m_Z(ip, jn) - m_Z(ip, jp)) / hx) / hy;

			ip = std::max<int_t>(i, 0);
			in = std::min<int_t>(i + 2, Ny - 1);
			hy = (m_Y(in, j) - m_Y(ip, j)) / dy;
			fxy11 = ((m_Z(in, jn) - m_Z(in, jp)) / hx - (m_Z(ip, jn) - m_Z(ip, jp)) / hx) / hy;

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

double Interpolator::interp(const double& x, const double& y) const
{
	// no extrapolation
	if (x < m_xmin || x > m_xmax || y < m_ymin || y > m_ymax) {
		return 0.0;
	}

	// find the interval that x, y belongs to
	auto i = get_y_index_below(y);
	auto j = get_x_index_left_of(x);

	i = i < 0 ? 0 : i;
	j = j < 0 ? 0 : j;

	// calculate the distance
	auto dy = m_Y(i + 1, j) - m_Y(i, j);
	auto dx = m_X(i, j + 1) - m_X(i, j);

	// create the coordinate vectors
	ColVector4d vy;
	vy[0] = 1;                 // 1
	vy[1] = (y - m_Y(i, j)) / dy;// y^1
	vy[2] = vy[1] * vy[1];     // y^2
	vy[3] = vy[2] * vy[1];     // y^3

	RowVector4d vx;
	vx[0] = 1;                 // 1
	vx[1] = (x - m_X(i, j)) / dx;// x^1
	vx[2] = vx[1] * vx[1];     // x^2
	vx[3] = vx[2] * vx[1];     // x^3

	return vx * m_LUT(i, j) * vy;
}

int_t Interpolator::get_x_index_left_of(const double& x) const
{
	return std::lower_bound(m_xrange.cbegin(), m_xrange.cend(), x) - m_xrange.cbegin() - 1;
}

int_t Interpolator::get_y_index_below(const double& y) const
{
	return std::lower_bound(m_yrange.cbegin(), m_yrange.cend(), y) - m_yrange.cbegin() - 1;
}