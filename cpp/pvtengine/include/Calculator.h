#ifndef CALCULATOR_H
#define CALCULATOR_H

#include "pvtengine.h"

//! This class calculates the PVT coefficients, PVT's P, V and A.
/*! 
* The class uses the PVT values to calculate the polynomial coefficients
* or use the coefficients to calculate the P, V, A for a tool path.
*/
class PVTENGINE_API Calculator {
public:
	//! Default constructor
	Calculator() = default;
	virtual ~Calculator();

	//! Disable copyping
	Calculator(const Calculator&) = delete;
	Calculator& operator=(const Calculator&) = delete;

	//! Choose which (P, V, A) to be computed
	enum PVA
	{
		P,/*!< calculate P*/
		V,/*!< calculate V*/
		A /*!< calculate A*/
	};

public:
	//! Overloaded () to calculate the coefficients
	Vector4d operator()(
		const double& p0,/*!< [in] start position*/
		const double& p1,/*!< [in] end position*/
		const double& v0,/*!< [in] start velocity*/
		const double& v1,/*!< [in] end velocity*/
		const double& t0,/*!< [in] start time point*/
		const double& t1 /*!< [in] end time point*/
	);

	//! Overloaded () to calculate the p, v, a from t and c
	void operator()(
		VectorXd& p,      /*!< [out] PVT's P*/
		VectorXd& v,      /*!< [out] PVT's V*/
		VectorXd& a,      /*!< [out] PVT's A*/
		const VectorXd& t,/*!< [in] PVT's T*/
		const Vector4d& c /*!< [in] PVT polynomial coefficients*/
	);

	//! Overloaded () to calculate p, v, or a
	VectorXd operator()(
		const VectorXd& t,     /*!< [in] PVT's T*/
		const Vector4d& c,     /*!< [in] PVT polynomial coefficients*/
		PVA pva = Calculator::P/*!< [in] P, V, or A to be calculated*/
	);

	//! Calculate the PVT coefficients
	Vector4d pvt_coefficients(
		const double& p0,/*!< [in] start position*/
		const double& p1,/*!< [in] end position*/
		const double& v0,/*!< [in] start velocity*/
		const double& v1,/*!< [in] end velocity*/
		const double& t0,/*!< [in] start time point*/
		const double& t1 /*!< [in] end time point*/
	);

	//! Calculate P from the PVT
	VectorXd calculate_pvt_p(
		const VectorXd& t,/*!< [in] PVT's T*/
		const Vector4d& c /*!< [in] PVT polynomial coefficients*/
	);

	//! Calculate V from the PVT
	VectorXd calculate_pvt_v(
		const VectorXd& t,/*!< [in] PVT's T*/
		const Vector4d& c /*!< [in] PVT polynomial coefficients*/
	);

	//! Calculate A from the PVT
	VectorXd calculate_pvt_a(
		const VectorXd& t,/*!< [in] PVT's T*/
		const Vector4d& c /*!< [in] PVT polynomial coefficients*/
	);

	//! Calculate A from the PVT
	void calculate_pvt(
		VectorXd& p,      /*!< [out] PVT's P*/
		VectorXd& v,      /*!< [out] PVT's V*/
		VectorXd& a,      /*!< [out] PVT's A*/
		const VectorXd& t,/*!< [in] PVT's T*/
		const Vector4d& c /*!< [in] PVT polynomial coefficients*/
	);
};

//! Solve the PVT coefficients from the P, V, and T
PVTENGINE_API Vector4d pvt_coefficients(
	const double& p0,/*!< [in] start position*/
	const double& p1,/*!< [in] end position*/
	const double& v0,/*!< [in] start velocity*/
	const double& v1,/*!< [in] end velocity*/
	const double& t0,/*!< [in] start time point*/
	const double& t1 /*!< [in] end time point*/
);

//! Calculate the P from the PVT model
PVTENGINE_API VectorXd calculate_pvt_p(
	const VectorXd& t,/*!< [in] PVT's T*/
	const Vector4d& c /*!< [in] PVT polynomial coefficients*/
);

//! Calculate the V from the PVT model
PVTENGINE_API VectorXd calculate_pvt_v(
	const VectorXd& t,/*!< [in] PVT's T*/
	const Vector4d& c /*!< [in] PVT polynomial coefficients*/
);

//! Calculate the A from the PVT model
PVTENGINE_API VectorXd calculate_pvt_a(
	const VectorXd& t,/*!< [in] PVT's T*/
	const Vector4d& c /*!< [in] PVT polynomial coefficients*/
);

//! Calculate all the P, V, A from the PVT model
PVTENGINE_API void calculate_pvt(
	VectorXd& p,      /*!< [out] PVT's P*/
	VectorXd& v,      /*!< [out] PVT's V*/
	VectorXd& a,      /*!< [out] PVT's A*/
	const VectorXd& t,/*!< [in] PVT's T*/
	const Vector4d& c /*!< [in] PVT polynomial coefficients*/
);

#endif // !CALCULATOR_H