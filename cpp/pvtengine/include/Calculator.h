#ifndef CALCULATOR_H
#define CALCULATOR_H

#include "pvtengine.h"

class PVTENGINE_API Calculator {
public:
	// Default constructor
	Calculator() = default;
	virtual ~Calculator();

	// Disable copyping
	Calculator(const Calculator&) = delete;
	Calculator& operator=(const Calculator&) = delete;

	enum PVA
	{
		P,
		V,
		A
	};


public:
	//! Overloaded () to calculate the coefficients
	Vector4d operator()(
		const double& p0, const double& p1,
		const double& v0, const double& v1,
		const double& t0, const double& t1
	);

	//! Overloaded () to calculate the p, v, a from t and c
	void operator()(
		VectorXd& p,
		VectorXd& v,
		VectorXd& a,
		const VectorXd& t,
		const Vector4d& c
	);

	//! Overloaded () to calculate p, v, or a
	VectorXd operator()(
		const VectorXd& t,
		const Vector4d& c,
		PVA pva = Calculator::P
	);

	//! Calculate the PVT coefficients
	Vector4d pvt_coefficients(
		const double& p0, const double& p1,
		const double& v0, const double& v1,
		const double& t0, const double& t1
	);

	//! Calculate P from the PVT
	VectorXd calculate_pvt_p(
		const VectorXd& t,
		const Vector4d& c
	);

	//! Calculate V from the PVT
	VectorXd calculate_pvt_v(
		const VectorXd& t,
		const Vector4d& c
	);

	//! Calculate A from the PVT
	VectorXd calculate_pvt_a(
		const VectorXd& t,
		const Vector4d& c
	);

	//! Calculate A from the PVT
	void calculate_pvt(
		VectorXd& p,
		VectorXd& v,
		VectorXd& a,
		const VectorXd& t,
		const Vector4d& c
	);
};

//! Solve the PVT coefficients from the P, V, and T
PVTENGINE_API Vector4d pvt_coefficients(
	const double& p0, const double& p1,
	const double& v0, const double& v1,
	const double& t0, const double& t1
);


PVTENGINE_API VectorXd calculate_pvt_p(
	const VectorXd& t,
	const Vector4d& c
);

PVTENGINE_API VectorXd calculate_pvt_v(
	const VectorXd& t,
	const Vector4d& c
);

PVTENGINE_API VectorXd calculate_pvt_a(
	const VectorXd& t,
	const Vector4d& c
);

PVTENGINE_API void calculate_pvt(
	VectorXd& p,
	VectorXd& v,
	VectorXd& a,
	const VectorXd& t,
	const Vector4d& c
);


#endif // !CALCULATOR_H

