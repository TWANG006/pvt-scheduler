#include "pch.h"
#include "Calculator.h"


PVTENGINE_API Vector4d pvt_coefficients(const double& p0, const double& p1, const double& v0, const double& v1, const double& t0, const double& t1)
{
	Matrix4d A{
		{t0 * t0 * t0, t0 * t0, t0, 1},
		{t1 * t1 * t1, t1 * t1, t1, 1},
		{3 * t0 * t0 , 2 * t0 , 1 , 0},
		{3 * t1 * t1 , 2 * t1 , 1 , 0},
	};
	Vector4d b{
		{p0, p1, v0, v1}
	};

	return A.colPivHouseholderQr().solve(b);
}

PVTENGINE_API VectorXd calculate_pvt_p(const VectorXd& t, const Vector4d& c)
{
	return (c(1) * t.array().cube() + c(2) * t.array().square() + c(3) * t.array() + c(4)).matrix();
}

PVTENGINE_API VectorXd calculate_pvt_v(const VectorXd& t, const Vector4d& c)
{
	return (3 * c(1) + t.array().square() + 2 * c(2) * t.array() + c(3)).matrix();
}

PVTENGINE_API VectorXd calculate_pvt_a(const VectorXd& t, const Vector4d& c)
{
	return (6 * c(1) * t.array() + c(2)).matrix();
}

PVTENGINE_API void calculate_pvt(VectorXd& p, VectorXd& v, VectorXd& a, const VectorXd& t, const Vector4d& c)
{
	p = (c(1) * t.array().cube() + c(2) * t.array().square() + c(3) * t.array() + c(4)).matrix();
	v = (3 * c(1) + t.array().square() + 2 * c(2) * t.array() + c(3)).matrix();
	a = (6 * c(1) * t.array() + c(2)).matrix();
}
