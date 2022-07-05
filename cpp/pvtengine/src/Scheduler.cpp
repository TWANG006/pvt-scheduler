#include "pch.h"
#include "Scheduler.h"

Scheduler::Scheduler()
{
}

Scheduler::Scheduler(const MatrixX2d& P, const VectorXd& T)
{
}

Scheduler::~Scheduler()
{
}

PVT Scheduler::operator()(const Vector2d& v0, const Vector2d& vt, const Vector2d& a0, const Vector2d& at)
{
	return PVT();
}
