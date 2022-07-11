#ifndef CALCULATOR_H
#define CALCULATOR_H

#include "pvtengine.h"

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

