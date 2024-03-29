#ifndef SIMULATOR_H
#define SIMULATOR_H

#include "pvtengine.h"
#include "Interpolator.h"

//! This class performs the velocity-based fabrication simulation.
/*!
* An entire optical fabrication procedure is
* 1) Measure the surface, calculate the desired material removal Z.
* 2) Extract the TIF
* 3) Use Z and TIF to optimize dwell time T
* 4) Schedule the PVT with the 'Scheduler'
* 5) Upsample the PVT with 'Sampler'
* 6) With the up-sampled PVT and the 'Interpolator', calculate the
*    removal at different dwell point using 'Simulator'
*/
class PVTENGINE_API Simulator
{
public:
	//! No default constructor and copying
	Simulator() = delete;
	Simulator(const Simulator&) = delete;
	Simulator& operator=(const Simulator&) = delete;
	virtual ~Simulator();

	//! Construct the Simulator using the PVT and TIF
	/*!
	* This constructor builds the Simulator by precomputing the Bi-
	* cubic interplation LUT using the TIF. This precomputed LUT
	* can then be used for different PVT combinations.
	*/
	Simulator(
		const MatrixXXd& Xtif,/*!< [in] TIF X grid*/
		const MatrixXXd& Ytif,/*!< [in] TIF Y grid*/
		const MatrixXXd& Ztif,/*!< [in] TIF Z grid*/
		const MatrixXXd& X,   /*!< [in] Surface X grid*/
		const MatrixXXd& Y,   /*!< [in] Surface Y grid*/
		const MatrixXXd& Z    /*!< [in] Surface height*/
	);

	//! Overloaded () operator to calculate the estimated removal
	/*!
	* Simulating the removal based on the calculate PVTs
	* /Return the estimated height removal
	*/
	MatrixXXd operator()(
		const PVA& xPV,/*!< [in] PVT in x axis*/
		const PVA& yPV /*!< [in] PVT in y axis*/
	);

	void operator()(
		const double& px0,/*!< [in] starting px*/
		const double& px1,/*!< [in] ending px*/
		const double& py0,/*!< [in] starting py*/
		const double& py1,/*!< [in] ending py*/
		const double& vx0,/*!< [in] starting vx*/
		const double& vx1,/*!< [in] ending vx*/
		const double& vy0,/*!< [in] starting vy*/
		const double& vy1,/*!< [in] ending vy*/
		MatrixXXd& Zrem,  /*!< [out] removed material*/
		double& x_dp,     /*!< [out] dwell point x coordinate*/
		double& y_dp      /*!< [out] dwell point y coordinate*/
	);

	//! calculate removal for each PVT segment
	void removal_per_pvt_segment(
		const double& px0,/*!< [in] starting px*/
		const double& px1,/*!< [in] ending px*/
		const double& py0,/*!< [in] starting py*/
		const double& py1,/*!< [in] ending py*/
		const double& vx0,/*!< [in] starting vx*/
		const double& vx1,/*!< [in] ending vx*/
		const double& vy0,/*!< [in] starting vy*/
		const double& vy1,/*!< [in] ending vy*/
		MatrixXXd& Zrem,  /*!< [out] removed material*/
		double& x_dp,     /*!< [out] dwell point x coordinate*/
		double& y_dp      /*!< [out] dwell point y coordinate*/
	);

private:
	Interpolator m_interp;/*!< bicubic interpolator*/
	MatrixXXd m_X;        /*!< surface X grid*/
	MatrixXXd m_Y;        /*!< surface Y grid*/
	MatrixXXd m_Z;        /*!< surface height*/
};


#endif // !SIMULATOR_H