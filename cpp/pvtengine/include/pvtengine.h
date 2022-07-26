#ifndef PVTENGINE_H
#define PVTENGINE_H


#ifdef PVTENGINE_EXPORTS
#define PVTENGINE_API __declspec(dllexport)
#else
#define PVTENGINE_API __declspec(dllimport)
#endif

#include <Eigen/Dense>


// Eigen API aliases
using int_t = Eigen::Index;
using Matrix44d = Eigen::Matrix<double, 4, 4, Eigen::RowMajor>;
using MatrixXXd = Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor>;
using MatrixX2d = Eigen::Matrix<double, Eigen::Dynamic, 2, Eigen::RowMajor>;
using MatrixX4d = Eigen::Matrix<double, Eigen::Dynamic, 4, Eigen::RowMajor>;
using Matrix44dArray = Eigen::Array<Matrix44d, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor>;
using Vector2d  = Eigen::Vector<double, 2>;
using Vector4d  = Eigen::Vector<double, 4>;
using VectorXd  = Eigen::Vector<double, Eigen::Dynamic>;
using VectorXi  = Eigen::Vector<int_t, Eigen::Dynamic>;
using RowVector4d = Eigen::Matrix<double, 1, 4>;
using ColVector4d = Eigen::Matrix<double, 4, 1>;
using Eigen::seq;
using Eigen::seqN;
using Eigen::all;
using Eigen::last;
using Eigen::lastN;
const double kInfinity = std::numeric_limits<double>::infinity();

//! PVT struct
struct PVTC {
	VectorXd  P;     /*!< Positions*/
	VectorXd  V;     /*!< Velocities*/
	VectorXd  T;     /*!< Times*/
	MatrixX4d Coeffs;/*!< Coefficients*/
};

//! PVA struct
struct PVA {
	VectorXd  P;/*!< Positions*/
	VectorXd  V;/*!< Velocities*/
	VectorXd  A;/*!< Accelerations*/
};

//! generate the X, Y meshgrid mimicking the matlab function
PVTENGINE_API void meshgrid(
	const VectorXd& x,/*!< [in] x vector*/
	const VectorXd& y,/*!< [in] y vector*/
	MatrixXXd& X,     /*!< [out] X grid*/
	MatrixXXd& Y      /*!< [out] Y grid*/
);

PVTENGINE_API double PV(const MatrixXXd& Z);

PVTENGINE_API double PV(const VectorXd& z);

PVTENGINE_API double RMS(const MatrixXXd& Z);

PVTENGINE_API double RMS(const VectorXd& Z);

PVTENGINE_API MatrixXXd remove_polynomials(
	VectorXd& coeffs,
	const MatrixXXd& X,
	const MatrixXXd& Y,
	const MatrixXXd& Z,
	int_t p = 1
);

#endif // !PVTENGINE_