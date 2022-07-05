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
	Scheduler();

	//! Construct the Scheduler with Positions and Times
	/*!
	* \param P the N-by-1 Positions
	* \param T the N-by-1 Times
	*/
	Scheduler(const VectorXd& P, const VectorXd& T);
	virtual ~Scheduler();

	//! Calculate PVT using a set of new `v0`, `vt`, `a0`, `at`.
	/*!
	* This callable assumes that the other parameters, i.e., `vmax`,
	* `amax`, `P` and `T` have already been input to the `Scheduler`.
	* \return the PVT struct
	*/
	PVT1D operator () (
		const VectorXd & P,      /*!< [in] Positions*/
		const VectorXd & T,      /*!< [in] Times*/
		const double& vmax,      /*!< [in] max.speed*/
		const double& amax,      /*1< [in] max.acceleration*/
		const double& v0 = 0.0,  /*!< [in] Initial velocity*/
		const double& vt = 0.0,  /*!< [in] End velocity*/
		const double& a0 = 0.0,  /*!< [in] Initial acceleration*/
		const double& at = 0.0   /*!< [in] End acceleration*/
		);

	//! Calculate PVT using a set of new `v0`, `vt`, `a0`, `at`.
	/*!
	* This callable assumes that the other parameters, i.e., `vmax`,
	* `amax`, `P` and `T` have already been input to the `Scheduler`.
	* \return the PVT struct
	*/
	PVT1D operator () (
		const double& v0 = 0.0,  /*!< [in] Initial velocity*/
		const double& vt = 0.0,  /*!< [in] End velocity*/
		const double& a0 = 0.0,  /*!< [in] Initial acceleration*/
		const double& at = 0.0   /*!< [in] End acceleration*/
		);

private:
	VectorXd m_P;          /*!< Positions*/
	VectorXd m_T;          /*!< Times*/
	double m_amax = 0.0;   /*!< Max. absolute accelerations*/
	double m_vmax = 0.0;   /*!< Max. absolute speed*/
	//Vector2d m_v0;  /*!< The initial velocity at the starting of a tool path.*/
	//Vector2d m_vt;  /*!< The end velocity at the ending of a tool path.*/
	//Vector2d m_a0;  /*!< The initial acceleration.*/
	//Vector2d m_at;  /*!< The end acceleration.*/
};


#endif // !SCHEDULER_H



