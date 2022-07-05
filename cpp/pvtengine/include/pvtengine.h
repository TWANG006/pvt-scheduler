// The following ifdef block is the standard way of creating macros which make exporting
// from a DLL simpler. All files within this DLL are compiled with the PVTENGINE_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see
// PVTENGINE_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef PVTENGINE_EXPORTS
#define PVTENGINE_API __declspec(dllexport)
#else
#define PVTENGINE_API __declspec(dllimport)
#endif

#include <Eigen/Dense>
using MatrixX2d = Eigen::Matrix<double, Eigen::Dynamic, 2, Eigen::RowMajor>;
using MatrixX4d = Eigen::Matrix<double, Eigen::Dynamic, 4, Eigen::RowMajor>;
using Vector2d = Eigen::Vector<double, 2>;
using VectorXd = Eigen::Vector<double, Eigen::Dynamic>;

struct PVT {
	MatrixX2d P;  /*!< Positions*/
	MatrixX2d V;  /*!< Velocities*/
	VectorXd T;   /*!< Times*/
};

//// This class is exported from the dll
//class PVTENGINE_API Cpvtengine {
//public:
//	Cpvtengine(void);
//	// TODO: add your methods here.
//};
//
//extern PVTENGINE_API int npvtengine;
//
//PVTENGINE_API int fnpvtengine(void);
