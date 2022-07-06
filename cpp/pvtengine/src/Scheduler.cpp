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

	for (size_t j = 0; j < num_v; j++)
	{
		auto i = j + 1;  // end id of the jth segment
		auto id = j * 6; // starting id of the j-th 6-by-6 block

		// build the matrix C
		// 1st row
		C(id, id    ) = m_T(i - 1) * m_T(i - 1) * m_T(i - 1);
		C(id, id + 1) = m_T(i - 1) * m_T(i - 1);
		C(id, id + 2) = m_T(i - 1);
		C(id, id + 3) = 1.0;

		// 2nd row
		C(id + 1, id    ) = m_T(i) * m_T(i) * m_T(i);
		C(id + 1, id + 1) = m_T(i) * m_T(i);
		C(id + 1, id + 2) = m_T(i);
		C(id + 1, id + 3) = 1.0;

		// 3rd row
		C(id + 2, id    ) = 3 * m_T(i - 1) * m_T(i - 1);
		C(id + 2, id + 1) = 2 * m_T(i - 1);
		C(id + 2, id + 2) = 1;

		// 4th row
		C(id + 3, id    ) = 3 * m_T(i) * m_T(i);
		C(id + 3, id + 1) = 2 * m_T(i);
		C(id + 3, id + 2) = 1;
		C(id + 3, id + 4) = -1;

		// 5th row
		C(id + 4, id    ) = 6 * m_T(i - 1);
		C(id + 4, id + 1) = 2;

		// 6th row
		C(id + 5, id    ) = 6 * m_T(i);
		C(id + 5, id + 1) = 2;
		C(id + 5, id + 5) = -1;

		if (j > 0) {
			C(id + 2, id - 2) = -1;
			C(id + 4, id - 1) = -1;
		}

		// build the vector d
		d(id    ) = m_P(i - 1);
		d(id + 1) = m_P(i);
	}
}


