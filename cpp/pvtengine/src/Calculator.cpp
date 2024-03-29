#include "pch.h"
#include "Calculator.h"


Calculator::~Calculator()
{
}

Vector4d Calculator::operator()(const double& p0, const double& p1, const double& v0, const double& v1, const double& t0, const double& t1)
{
	return pvt_coefficients(p0, p1, v0, v1, t0, t1);
}

void Calculator::operator()(VectorXd& p, VectorXd& v, VectorXd& a, const VectorXd& t, const Vector4d& c)
{
	calculate_pvt(p, v, a, t, c);
}

VectorXd Calculator::operator()(const VectorXd& t, const Vector4d& c, PVA pva)
{
	switch (pva)
	{
	case Calculator::P:
		return calculate_pvt_p(t, c);
	case Calculator::V:
		return calculate_pvt_v(t, c);
	case Calculator::A:
		return calculate_pvt_a(t, c);
	default:
		return Vector4d();
	}
}

Vector4d Calculator::pvt_coefficients(const double& p0, const double& p1, const double& v0, const double& v1, const double& t0, const double& t1)
{
	Matrix44d A{
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

VectorXd Calculator::calculate_pvt_p(const VectorXd& t, const Vector4d& c)
{
	return (c(0) * t.array().cube() + c(1) * t.array().square() + c(2) * t.array() + c(3)).matrix();
}

VectorXd Calculator::calculate_pvt_v(const VectorXd& t, const Vector4d& c)
{
	return (3 * c(0) * t.array().square() + 2 * c(1) * t.array() + c(2)).matrix();
}

VectorXd Calculator::calculate_pvt_a(const VectorXd& t, const Vector4d& c)
{
	return (6 * c(0) * t.array() + 2 * c(1)).matrix();
}

void Calculator::calculate_pvt(VectorXd& p, VectorXd& v, VectorXd& a, const VectorXd& t, const Vector4d& c)
{
	p = (c(0) * t.array().cube() + c(1) * t.array().square() + c(2) * t.array() + c(3)).matrix();
	v = (3 * c(0) * t.array().square() + 2 * c(1) * t.array() + c(2)).matrix();
	a = (6 * c(0) * t.array() + 2 * c(1)).matrix();
}

PVTENGINE_API Vector4d pvt_coefficients(const double& p0, const double& p1, const double& v0, const double& v1, const double& t0, const double& t1)
{
	Matrix44d A{
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
	return (c(0) * t.array().cube() + c(1) * t.array().square() + c(2) * t.array() + c(3)).matrix();
}

PVTENGINE_API VectorXd calculate_pvt_v(const VectorXd& t, const Vector4d& c)
{
	return (3 * c(0) * t.array().square() + 2 * c(1) * t.array() + c(2)).matrix();
}

PVTENGINE_API VectorXd calculate_pvt_a(const VectorXd& t, const Vector4d& c)
{
	return (6 * c(0) * t.array() + 2 * c(1)).matrix();
}

PVTENGINE_API void calculate_pvt(VectorXd& p, VectorXd& v, VectorXd& a, const VectorXd& t, const Vector4d& c)
{
	p = (c(0) * t.array().cube() + c(1) * t.array().square() + c(2) * t.array() + c(3)).matrix();
	v = (3 * c(0) * t.array().square() + 2 * c(1) * t.array() + c(2)).matrix();
	a = (6 * c(0) * t.array() + 2 * c(1)).matrix();
}
