#include "pch.h"
#include "Scheduler.h"

Scheduler::Scheduler(const VectorXd& P, const VectorXd& T, const double& vmax, const double& amax, const double& v0, const double& vt, const double& a0, const double& at)
	: m_P(P)
	, m_T(T)
	, m_vmax(vmax)
	, m_amax(amax)
	, m_v0(v0)
	, m_vt(vt)
	, m_a0(a0)
	, m_at(at)
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

void Scheduler::build_Cd(MatrixXXd& C, VectorXd& d)
{
	// get the number of v's needed to be calculated
	auto num_v = m_T.size() - 1;

	// 6num_v equations of unknowns + 4 equations of knowns
	// for v0, a0, vt, at
	C = MatrixXXd::Zero(6 * num_v + 4, 6 * num_v);
	d = VectorXd::Zero(6 * num_v + 4);
}


