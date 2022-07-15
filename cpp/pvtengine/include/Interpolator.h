#ifndef INTERPOLATOR_H
#define INTERPOLATOR_H

#include "pvtengine.h"
#include <vector>

//! This class implements the Bi-cubic interpolant for interpolating
//! the TIF, which is needed in the Simulator
/*! 
* The Bi-cubic interpolator is defined as
*                        3   3
*              z(x,y) = sum sum a_ij * x^i * y^j
*                       i=0 j=0
* which can be concisely converted to matrix-based operations as
*   |a00 a01 a02 a03| | 1  0  0  0|| f00  f01  fy00  fy01||1  0 -3  2|
* A=|a10 a11 a12 a13|=| 0  0  1  0|| f10  f11  fy10  fy11||0  0  3 -2|
*   |a20 a21 a22 a23| |-3  3 -2 -1||fx00 fx01 fxy00 fxy00||0  1 -2  1|
*   |a30 a31 a32 a33| | 2 -2  1  1||fx10 fx11 fxy10 fxy11||0  0 -1  1|
* and the interpolated values p(x,y) can be obatained as
*                     |a00 a01 a02 a03|| 1 |
* z(x,y)=|1 x x^2 x^3||a10 a11 a12 a13|| y |.
*                     |a20 a21 a22 a23||y^2|
*                     |a30 a31 a32 a33||y^3|
* The Implementation steps are
* 1. Precompute the gradients fx, fy, fxy at all the positions
* 2. Precompute the coefficient matrices A for all the intervals
* 3. Find the new point (x,y)'s interval
* 4. Calculate z(x,y)
*/
class PVTENGINE_API Interpolator
{
public:
	//! No default constructor and copying
	Interpolator() = delete;
	Interpolator(const Interpolator&) = delete;
	Interpolator& operator=(const Interpolator&) = delete;

	//! Construct the interpolator using the X,Y,Z
	Interpolator(
		const MatrixXXd& X,/*!< [in] x coordinate grid*/
		const MatrixXXd& Y,/*!< [in] y coordinate grid*/
		const MatrixXXd& Z /*!< [in] z coordinate grid*/
	);

	double operator() (
		const double& x,/*!< [in] queried x coordinate*/
		const double& y /*!< [in] queried y coordinate*/
	) const;

	MatrixXXd operator() (
		const MatrixXXd& X,/*!< [in] X coordinate grid*/
		const MatrixXXd& Y /*!< [in] Y coordinate grid*/
	) const;

protected:
	//! Build the bicubic interpolation LUT
	void build_bicubic_interpolant();

	//! Perform the interpolation
	double interp(const double& x, const double& y) const;

	//! find the lower-bound indcies of x, y for the interpolation
	int_t get_x_index_left_of(const double& x) const;
	int_t get_y_index_below(const double& y) const;

private:
	Matrix44dArray m_LUT;/*!< Bucubic lookup table*/
	double m_xmin = INFINITY;
	double m_xmax = -INFINITY;
	double m_ymin = INFINITY;
	double m_ymax = -INFINITY;

	MatrixXXd m_X;
	MatrixXXd m_Y;
	MatrixXXd m_Z;

	std::vector<double> m_xrange;
	std::vector<double> m_yrange;
};


#endif // INTERPOLATOR_H