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
	return MatrixXXd();
}

void Simulator::removal_per_pvt_segment(const double& p0, const double& p1, const double& v0, const double& v1, MatrixXXd& Zrem)
{

}
