#include "pch.h"
#include "Scheduler.h"

Scheduler::Scheduler()
{
}

Scheduler::Scheduler(const VectorXd& P, const VectorXd& T)
	: m_P(P)
	, m_T(T)
{
}

Scheduler::~Scheduler()
{
}

PVT1D Scheduler::operator()(const VectorXd& P, const VectorXd& T, const double& vmax, const double& amax, const double& v0, const double& vt, const double& a0, const double& at)
{
	return PVT1D();
}



PVT1D Scheduler::operator()(const double& v0, const double& vt, const double& a0, const double& at)
{
	return PVT1D();
}


