#include "pch.h"
#include "Simulator.h"

Simulator::~Simulator()
{
}

Simulator::Simulator(const MatrixXXd& Xtif, const MatrixXXd& Ytif, const MatrixXXd& Ztif, const MatrixXXd& X, const MatrixXXd& Y, const MatrixXXd& Z)
	: m_interp(Xtif, Ytif, Ztif)
	, m_X(X)
	, m_Y(Y)
	, m_Z(Z)
{
}

MatrixXXd Simulator::operator()(const PVA& xPV, const PVA& yPV)
{
	auto num_seg = xPV.P.size() - 1;// number of segments
	MatrixXXd Zrem(m_Z.rows(), m_Z.cols());
	Zrem.fill(0.0);
	
    #pragma omp parallel 
	{
		MatrixXXd Zrem_private(m_Z.rows(), m_Z.cols());
		Zrem_private.fill(0.0);

		#pragma omp for nowait
		for (int_t i = 0; i < num_seg; i++) {
			MatrixXXd Zrem_per_seg;
			double x_dp = 0.0, y_dp = 0.0;

			// get the per-segment removal
			removal_per_pvt_segment(
				xPV.P(i), xPV.P(i + 1),
				yPV.P(i), yPV.P(i + 1),
				xPV.V(i), xPV.V(i + 1),
				yPV.V(i), yPV.V(i + 1),
				Zrem_per_seg,
				x_dp, y_dp
			);

			// acumulate to the thread-private Zrem_private
			Zrem_private += Zrem_per_seg;
		}
		// accumulate to the final result
		#pragma omp critical
		{
			Zrem += Zrem_private;
		}
	}

	return Zrem;
}

void Simulator::removal_per_pvt_segment(const double& px0, const double& px1, const double& py0, const double& py1, const double& vx0, const double& vx1, const double& vy0, const double& vy1, MatrixXXd& Zrem, double& x_dp, double& y_dp)
{
	// calculate the dwell point
	x_dp = 0.5 * (px0 + px1);
	y_dp = 0.5 * (py0 + py1);

	// calculate the dwell time as the p_avg / v_avg
	auto t_dp = std::max<double>(
		std::abs((px0 - px1) / (0.5 * (vx0 + vx1))),
		std::abs((py0 - py1) / (0.5 * (vy0 + vy1)))
	);

	// calculate the distance from each point on the surface to the dwell
	// point (x_dp, y_dp)
	auto Xk = (m_X.array() - x_dp).matrix();
	auto Yk = (m_Y.array() - y_dp).matrix();

	// calculate the removal
	Zrem = m_interp(Xk, Yk) * t_dp;
}

