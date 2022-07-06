#include "pch.h"
#include "Scheduler.h"
#include <qpOASES.hpp>

Scheduler::Scheduler(const VectorXd& P, const VectorXd& T, const double& vmax, const double& amax, const double& v0, const double& vt, const double& a0, const double& at)
	: m_P(P)
	, m_T(T)
	, m_vmax(vmax)
	, m_amax(amax)
	, m_v0(v0)
	, m_vt(vt)
	, m_a0(a0)
	, m_at(at)
{}

Scheduler::~Scheduler()
{}

PVT Scheduler::operator()(const VectorXd& P, const VectorXd& T, const double& vmax, const double& amax, const double& v0, const double& vt, const double& a0, const double& at)
{
	// update the member variables
	m_P = P;
	m_T = T;
	m_amax = amax;
	m_vmax = vmax;
	m_v0 = v0;
	m_vt = vt;
	m_a0 = a0;
	m_at = at;

	// call the QP rountines
	VectorXd  V;
	MatrixX4d Coeffs;
	clls_with_qpOASES(V, Coeffs);

	return PVT{m_P, V, m_T, Coeffs};
}



PVT Scheduler::operator()(const double& v0, const double& vt, const double& a0, const double& at)
{
	// update the member variables
	m_v0 = v0;
	m_vt = vt;
	m_a0 = a0;
	m_at = at;


	// call the QP rountines
	VectorXd  V;
	MatrixX4d Coeffs;
	clls_with_qpOASES(V, Coeffs);

	return PVT{ m_P, V, m_T, Coeffs };
}

void Scheduler::clls_with_qpOASES(VectorXd& V, MatrixX4d& Coeffs)
{
	// 0. build the CLLS objective
	MatrixXXd C;
	VectorXd  d;
	build_Cd(C, d);

	// 1. convert to QP objective
	MatrixXXd H(C.transpose() * C);
	VectorXd g(-1 * C.transpose() * d);

	// FOR DEBUG
	/*std::cout << C.rows() << ", " << C.cols() << std::endl;
	std::cout << H.rows() << ", " << H.cols() << std::endl;*/

	// 2. build the lb and ub
	VectorXd lb, ub;
	build_lbub(lb, ub);

	// FOR DUBUG
	/*std::cout << lb.transpose() << std::endl;
	std::cout << ub.transpose() << std::endl;
	std::cout << lb.size() << std::endl;
	std::cout << ub.size() << std::endl;*/
}

void Scheduler::build_Cd(MatrixXXd& C, VectorXd& d)
{
	// get the number of v's needed to be calculated
	auto num_v = m_T.size() - 1;

	// 6num_v equations of unknowns + 4 equations of knowns
	// for v0, a0, vt, at
	C = MatrixXXd::Zero(6 * num_v + 4, 6 * num_v);
	d = VectorXd::Zero(6 * num_v + 4);

#pragma omp parallel for
	for (long long j = 0; j < num_v; j++)
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

	// feed the initial and ending conditions
	d.tail(4) << m_v0, m_a0, m_vt, m_at ;
	C(6 * num_v,     4            ) = 1;
	C(6 * num_v + 1, 5            ) = 1;
	C(6 * num_v + 2, 6 * num_v - 2) = 1;
	C(6 * num_v + 3, 6 * num_v - 1) = 1;
}

void Scheduler::build_lbub(VectorXd& lb, VectorXd& ub)
{
	// number of velocities to be calculated
	auto num_v = m_T.size() - 1;

	// build the lb
	lb = VectorXd::Constant(6 * num_v, -qpOASES::INFTY);
	lb(seq(4, last, 6)).setConstant(-m_vmax);
	lb(seq(5, last, 6)).setConstant(-m_amax);

	// build the ub
	ub = VectorXd::Constant(6 * num_v, qpOASES::INFTY);
	ub(seq(4, last, 6)).setConstant(m_vmax);
	ub(seq(5, last, 6)).setConstant(m_amax);
}


