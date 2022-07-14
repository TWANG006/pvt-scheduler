#ifndef SCHEDULER_H
#define SCHEDULER_H

#include "pvtengine.h"

//! This is the class to calculate the velocities based on PVT.
/*!
* The class use the Positions (P) and the Times (T) as the input to
* calculate the Velocities (V) and the PVT coefficients using a
* Quadratic Programming method.
*/
class PVTENGINE_API Scheduler
{
public:
	//! Default constructor
	Scheduler() = default;

	// Disable copyping
	Scheduler(const Scheduler&) = delete;
	Scheduler& operator=(const Scheduler&) = delete;

	//! Construct the Scheduler with Positions and Times
	/*!
	* \param P the N-by-1 Positions
	* \param T the N-by-1 Times
	*/
	Scheduler(
		const VectorXd& P,     /*!< [in] Positions*/
		const VectorXd& T,     /*!< [in] Times*/
		const double& vmax,    /*!< [in] max.speed*/
		const double& amax,    /*!< [in] max.acceleration*/
		const double& v0 = 0.0,/*!< [in] Initial velocity*/
		const double& vt = 0.0,/*!< [in] End velocity*/
		const double& a0 = 0.0,/*!< [in] Initial acceleration*/
		const double& at = 0.0 /*!< [in] End acceleration*/
	);
	virtual ~Scheduler();

	//! Calculate PVT using a set of new `v0`, `vt`, `a0`, `at`.
	/*!
	* This callable assumes that the other parameters, i.e., `vmax`,
	* `amax`, `P` and `T` have already been input to the `Scheduler`.
	* \return the PVT struct
	*/
	PVTC operator () (
		const VectorXd& P,     /*!< [in] Positions*/
		const VectorXd& T,     /*!< [in] Times*/
		const double& vmax,    /*!< [in] max.speed*/
		const double& amax,    /*!< [in] max.acceleration*/
		const double& v0 = 0.0,/*!< [in] Initial velocity*/
		const double& vt = 0.0,/*!< [in] End velocity*/
		const double& a0 = 0.0,/*!< [in] Initial acceleration*/
		const double& at = 0.0,/*!< [in] End acceleration*/
		bool isVsmooth = false /*!< [in] if V are C1 smooth*/
	);

	//! Calculate PVT using a set of new `v0`, `vt`, `a0`, `at`.
	/*!
	* This callable assumes that the other parameters, i.e., `vmax`,
	* `amax`, `P` and `T` have already been input to the Scheduler.
	* \return the PVT struct
	*/
	PVTC operator () (
		const double& v0 = 0.0,/*!< [in] Initial velocity*/
		const double& vt = 0.0,/*!< [in] End velocity*/
		const double& a0 = 0.0,/*!< [in] Initial acceleration*/
		const double& at = 0.0,/*!< [in] End acceleration*/
		bool isVsmooth = false /*!< [in] if V are C1 smooth*/
	);

private:
	//! Solve the V and Coeffs using the qpOASES lib
	bool clls_with_qpOASES(VectorXd& V, MatrixX4d& Coeffs, bool isVsmooth = false);
	
	//!  Build the 1/2||C^Tx - d||^2 for the QP
	void build_Cd(MatrixXXd& C, VectorXd& d);

	//! Build lb <= x <= ub; for the QP
	void build_lbub(VectorXd& lb, VectorXd& ub);

	//! Build lbA<= Ax <= ubA for the QP
	void build_lbAubA(MatrixXXd& A, VectorXd& lbA, VectorXd& ubA);

	//! Solve the QP
	bool solve_qp(
		VectorXd& qpSol,      /*!< [out] QP solution*/
		MatrixXXd& H,         /*!< [in] Obj. matrix*/
		VectorXd& g,          /*!< [in] Obj. vector*/
		MatrixXXd& A,         /*!< [in] Con. matrix*/
		VectorXd& lbA,        /*!< [in] Con. lower bound*/
		VectorXd& ubA,        /*!< [in] Con. upper bound*/
		VectorXd& lb,         /*!< [in] lower bound*/
		VectorXd& ub,         /*!< [in] upper bound*/
		bool isVsmooth = false/*!< [in]if V are C1 smooth*/
	);

private:
	VectorXd m_P;        /*!< Positions*/
	VectorXd m_T;        /*!< Times*/
	double m_vmax = -1.0;/*!< Max. absolute speed*/
	double m_amax = -1.0;/*!< Max. absolute accelerations*/
	double m_v0 = 0.0;   /*!< The initial velocity at the starting of a tool path.*/
	double m_vt = 0.0;   /*!< The end velocity at the ending of a tool path.*/
	double m_a0 = 0.0;   /*!< The initial acceleration.*/
	double m_at = 0.0;   /*!< The end acceleration.*/
};

#endif // !SCHEDULER_H