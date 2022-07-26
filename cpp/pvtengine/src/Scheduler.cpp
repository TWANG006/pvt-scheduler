#include "pch.h"
#include "Scheduler.h"
#include <qpOASES.hpp>
#include "Calculator.h"
#include "osqp++.h"

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

PVTC Scheduler::operator()(const VectorXd& P, const VectorXd& T, const double& vmax, const double& amax, const double& v0, const double& vt, const double& a0, const double& at, bool isVsmooth)
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
	if (true == clls_with_qpOASES(V, Coeffs, isVsmooth)) {
		return PVTC{ m_P, V, m_T, Coeffs };
	}
	else {
		return PVTC();
	}
}

PVTC Scheduler::operator()(const double& v0, const double& vt, const double& a0, const double& at, bool isVsmooth)
{
	// update the member variables
	m_v0 = v0;
	m_vt = vt;
	m_a0 = a0;
	m_at = at;

	// call the QP rountines
	VectorXd  V;
	MatrixX4d Coeffs;
	if (true == clls_with_qpOASES(V, Coeffs, isVsmooth)) {
		return PVTC{ m_P, V, m_T, Coeffs };
	}
	else {
		return PVTC();
	}
}

bool Scheduler::clls_with_qpOASES(VectorXd& V, MatrixX4d& Coeffs, bool isVsmooth)
{
	auto num_v = m_T.size() - 1;

	// 0. build the CLLS objective
	MatrixXXd C;
	VectorXd  d;
	build_Cd(C, d);

	// 1. convert to QP objective: H = C^TC, g = -C^Td
	MatrixXXd H(C.transpose() * C);
	VectorXd g(-1 * C.transpose() * d);

	// 2. build the lb and ub
	VectorXd lb, ub;
	build_lbub(lb, ub);

	// 3. build the lbA and ubA, if necessary S
	MatrixXXd A;
	VectorXd lbA, ubA;
	if (isVsmooth) {
		build_lbAubA(A, lbA, ubA);
	}

	// 4. solve the QP for the 1st time
	VectorXd qpSol;
	bool isSuccessful = solve_qp(qpSol, H, g, A, lbA, ubA, lb, ub, isVsmooth);

	// 5. solve the QP for the 2nd time using the updated v0, vt, a0, at
	// update initial & end velocities and accelerations
	m_v0 = qpSol(4);
	m_a0 = qpSol(5);
	m_vt = qpSol(last - 1);
	m_at = qpSol(last);

	// rebuild the objective
	build_Cd(C, d);
	H = C.transpose() * C;
	g = -1 * C.transpose() * d;

	// solve the QP again
	isSuccessful = solve_qp(qpSol, H, g, A, lbA, ubA, lb, ub, isVsmooth);

	// 6 assemble the outputs
	if (isSuccessful) {
		V.resize(qpSol(seq(4, last, 6)).size() + 1);
		V << m_v0, qpSol(seq(4, last, 6));
		
		// 7 recalculate the coeffs
		Coeffs = MatrixX4d::Zero(num_v, 4);

		#pragma omp parallel for
		for (int_t i = 0; i < V.size() - 1; i++) {
			Coeffs.row(i) = pvt_coefficients(
				m_P(i), m_P(i + 1),
				V(i), V(i + 1),
				m_T(i), m_T(i + 1)
			);
		}
	}

	return isSuccessful;
}

bool Scheduler::clls_with_osqp(VectorXd& V, MatrixX4d& Coeffs, bool isVsmooth)
{
	auto num_v = m_T.size() - 1;

	// 0. build the CLLS objective
	MatrixXXd C;
	VectorXd  d;
	build_Cd(C, d);

	// 1. convert to QP objective: H = C^TC, g = -C^Td
	MatrixXXd H(C.transpose() * C);
	VectorXd g(-1 * C.transpose() * d);

	// 2. build the constratins
	MatrixXXd A;
	VectorXd lb, ub;
	build_lbAub(A, lb, ub);

	// 3. first solve
	osqp::OsqpInstance instance;
	instance.objective_matrix = H.sparseView();
	instance.objective_vector = g;
	instance.constraint_matrix = A.sparseView();
	instance.lower_bounds = lb;
	instance.upper_bounds = ub;
	osqp::OsqpSolver solver;
	osqp::OsqpSettings settings;
	auto status = solver.Init(instance, settings);
	auto exit_code = solver.Solve();
	VectorXd qpSol = solver.primal_solution();
	
	m_v0 = qpSol(4);
	m_a0 = qpSol(5);
	m_vt = qpSol(last - 1);
	m_at = qpSol(last);

	// rebuild the objective
	build_Cd(C, d);
	H = C.transpose() * C;
	g = -1 * C.transpose() * d;
	instance.objective_matrix = H.sparseView();
	instance.objective_vector = g;

	//5. refined solve
	solver.Init(instance, settings);
	solver.Solve();
	qpSol = solver.primal_solution();

	V.resize(qpSol(seq(4, last, 6)).size() + 1);
	V << m_v0, qpSol(seq(4, last, 6));

	// 7 recalculate the coeffs
	Coeffs = MatrixX4d::Zero(num_v, 4);

	#pragma omp parallel for
	for (int_t i = 0; i < V.size() - 1; i++) {
		Coeffs.row(i) = pvt_coefficients(
			m_P(i), m_P(i + 1),
			V(i), V(i + 1),
			m_T(i), m_T(i + 1)
		);
	}

	return true;
}

void Scheduler::build_lbAub(MatrixXXd& A, VectorXd& lb, VectorXd& ub, bool isVsmooth)
{
	auto num_v = m_T.size() - 1;

	// box bounding
	VectorXd lb_bound = VectorXd::Constant(6 * num_v, -kInfinity);
	lb_bound(seq(4, last, 6)).setConstant(-m_vmax);
	lb_bound(seq(5, last, 6)).setConstant(-m_amax);

	VectorXd ub_bound = VectorXd::Constant(6 * num_v, kInfinity);
	ub_bound(seq(4, last, 6)).setConstant(m_vmax);
	ub_bound(seq(5, last, 6)).setConstant(m_amax);

	MatrixXXd A_bound = MatrixXXd::Identity(6 * num_v, 6 * num_v);

	// equality contraints
	if (!isVsmooth) {
		A = A_bound;
		lb = lb_bound;
		ub = ub_bound;
	}
	else {
		MatrixXXd A_eq;
		VectorXd lbA, ubA;
		build_lbAubA(A_eq, lbA, ubA);

		A = MatrixXXd(A_eq.rows() + A_bound.rows(), A_eq.cols());
		A << A_bound,
			 A_eq;

		lb = VectorXd(lbA.size() + lb_bound.size());
		lb << lb_bound, lbA;

		ub = VectorXd(ubA.size() + ub_bound.size());
		ub << ub_bound, ubA;
	}
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
	for (int_t j = 0; j < num_v; j++)
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

		if (0 < j) {
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

	/*lb = VectorXd::Constant(6 * num_v, -1e16);
	ub = VectorXd::Constant(6 * num_v, 1e16);

	for (int i = 1; i < m_T.size(); i++) {
		bool isNeg = m_P(i) - m_P(i - 1) < 0;

		if (isNeg) {
			lb((i - 1) * 6 + 4) = -m_vmax;
			ub((i - 1) * 6 + 4) = 0;
		}
		else {
			lb((i - 1) * 6 + 4) = 0;
			ub((i - 1) * 6 + 4) = m_vmax;
		}
		lb((i - 1) * 6 + 5) = -m_amax;
		ub((i - 1) * 6 + 5) = m_amax;
	}*/

	// build the lb
	lb = VectorXd::Constant(6 * num_v, -kInfinity);
	lb(seq(4, last, 6)).setConstant(-m_vmax);
	lb(seq(5, last, 6)).setConstant(-m_amax);

	// build the ub
	ub = VectorXd::Constant(6 * num_v, kInfinity);
	ub(seq(4, last, 6)).setConstant(m_vmax);
	ub(seq(5, last, 6)).setConstant(m_amax);
}

void Scheduler::build_lbAubA(MatrixXXd& A, VectorXd& lbA, VectorXd& ubA)
{
	auto num_v = m_T.size() - 1;// number of V to calculate
	A = MatrixXXd::Zero(1 * (num_v - 2), 6 * num_v);
	lbA = VectorXd::Zero(1 * (num_v - 2));
	ubA = VectorXd::Zero(1 * (num_v - 2));

    #pragma omp parallel for
	for (int_t j = 1; j < num_v - 1; j++) {
		auto i = j + 1;
		auto id = j * 6;

		// equal a at the intermediate points
		A(j - 1, id - 6) = 6 * m_T(i - 1);
		A(j - 1, id    ) = -6 * m_T(i - 1);
		A(j - 1, id - 5) = 2;
		A(j - 1, id + 1) = -2;

		// equal v at the intermediate points
		//A(j - 1, id - 6) = 3 * m_T(i - 1) * m_T(i - 1);
		//A(j - 1, id    ) = -3 * m_T(i - 1) * m_T(i - 1);
		//A(j - 1, id - 5) = 2 * m_T(i - 1);
		//A(j - 1, id + 1) = -2 * m_T(i - 1);
		//A(j - 1, id - 4) = 1;
		//A(j - 1, id + 2) = -1;

		//// eqaul p at the intermediate points
		//A(j + 1, id - 6) = m_T(i - 1) * m_T(i - 1) * m_T(i - 1);
		//A(j + 1, id    ) = -m_T(i - 1) * m_T(i - 1) * m_T(i - 1);
		//A(j + 1, id - 5) = m_T(i - 1) * m_T(i - 1);
		//A(j + 1, id + 1) = -m_T(i - 1) * m_T(i - 1);
		//A(j + 1, id - 4) = m_T(i - 1);
		//A(j + 1, id + 2) = -m_T(i - 1);
		//A(j + 1, id - 3) = 1;
		//A(j + 1, id + 3) = -1;
	}
}

bool Scheduler::solve_qp(VectorXd& qpSol, MatrixXXd& H, VectorXd& g, MatrixXXd& A, VectorXd& lbA, VectorXd& ubA, VectorXd& lb, VectorXd& ub, bool isVsmooth)
{
	int nV = (int)g.size();// number of variables
	int nWSR = 1000;    // max worker set recalculation
	qpSol = VectorXd::Zero(nV);
		
	if (isVsmooth) { // if using the smoothness constriants
		int nC = (int)A.rows();              // number of constriants
		qpOASES::QProblem qp(nV, nC);        // general QP
		qpOASES::Options options;            // default options
		options.setToMPC();
		options.printLevel = qpOASES::PL_MEDIUM;// no output
		qp.setOptions(options);

		// initialization
		if (qpOASES::SUCCESSFUL_RETURN != qp.init(H.data(), g.data(), A.data(), lb.data(), ub.data(), lbA.data(), ubA.data(), nWSR, NULL, NULL)) {
			std::cout << "qpOASES initialization failed." << std::endl;
			return false;
		}
		else {
			if (qpOASES::SUCCESSFUL_RETURN != qp.getPrimalSolution(qpSol.data())) {
				std::cout << "qpOASES solution failed." << std::endl;
				return false;
			}
		}
	}
	else { // if not using the smoothness constraints
		qpOASES::QProblemB qp(nV);            // initialize the bounded problem
		qpOASES::Options options;             // default options
		options.setToMPC();
		options.printLevel = qpOASES::PL_MEDIUM;// no output
		qp.setOptions(options);

		if (qpOASES::SUCCESSFUL_RETURN != qp.init(H.data(), g.data(), lb.data(), ub.data(), nWSR, NULL, NULL)) {
			std::cout << "qpOASES initialization failed." << std::endl;
			return false;
		}
		else {
			if (qpOASES::SUCCESSFUL_RETURN != qp.getPrimalSolution(qpSol.data())) {
				std::cout << "qpOASES solution failed." << std::endl;
				return false;
			}
		}
	}
	return true;
}