#ifndef PVTENGINE_H
#define PVTENGINE_H


#ifdef PVTENGINE_EXPORTS
#define PVTENGINE_API __declspec(dllexport)
#else
#define PVTENGINE_API __declspec(dllimport)
#endif


#include <Eigen/Dense>


// Eigen API aliases
using MatrixXXd = Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor>;
using MatrixX2d = Eigen::Matrix<double, Eigen::Dynamic, 2, Eigen::RowMajor>;
using MatrixX4d = Eigen::Matrix<double, Eigen::Dynamic, 4, Eigen::RowMajor>;
using Vector2d = Eigen::Vector<double, 2>;
using Vector4d = Eigen::Vector<double, 4>;
using VectorXd = Eigen::Vector<double, Eigen::Dynamic>;
using Eigen::seq;
using Eigen::seqN;
using Eigen::all;
using Eigen::last;
using Eigen::lastN;


//! PVT struct
struct PVT {
	VectorXd  P;     /*!< Positions*/
	VectorXd  V;     /*!< Velocities*/
	VectorXd  T;     /*!< Times*/
	MatrixX4d Coeffs;/*!< Coefficients*/
};

#endif // !PVTENGINE_H

