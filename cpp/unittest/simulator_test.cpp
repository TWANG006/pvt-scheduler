#include "pch.h"
#include "Simulator.h"
#include "eigen3-hdf5.hpp"

TEST(Simulator, hdf5_2_eigen)
{
	H5::H5File h5_file(
		"../../data/sim_data/step_02_pvt_2d_from_udo.h5",
		H5F_ACC_RDWR
	);	

	MatrixXXd Xtif, Ytif, Ztif, X, Y, Z;
	PVA xPV, yPV;
	EigenHDF5::load<MatrixXXd>(h5_file, "Xtif", Xtif);
	EigenHDF5::internal::_load<MatrixXXd>(h5_file.openDataSet("Ytif"), Ytif);
	EigenHDF5::internal::_load<MatrixXXd>(h5_file.openDataSet("Ztif"), Ztif);
	EigenHDF5::internal::_load<MatrixXXd>(h5_file.openDataSet("X"), X);
	EigenHDF5::internal::_load<MatrixXXd>(h5_file.openDataSet("Y"), Y);
	EigenHDF5::internal::_load<MatrixXXd>(h5_file.openDataSet("Z"), Z);
	EigenHDF5::internal::_load<VectorXd>(h5_file.openDataSet("px"), xPV.P);
	EigenHDF5::internal::_load<VectorXd>(h5_file.openDataSet("py"), yPV.P);
	EigenHDF5::internal::_load<VectorXd>(h5_file.openDataSet("vx"), xPV.V);
	EigenHDF5::internal::_load<VectorXd>(h5_file.openDataSet("vy"), yPV.V);

	//std::cout << Ytif.col(0) << std::endl;

	Ytif = Ytif.colwise().reverse().eval();
	Ztif = Ztif.colwise().reverse().eval();

	std::cout << Ytif.minCoeff() << std::endl;
	std::cout << Ytif.maxCoeff() << std::endl;

	std::cout << Xtif.minCoeff() << std::endl;
	std::cout << Xtif.maxCoeff() << std::endl;

	//Y = Y.colwise().reverse().eval();
	//Z = Z.colwise().reverse().eval();

	Simulator sim(Xtif, Ytif, Ztif, X, Y, Z);
	auto Zrem = sim(xPV, yPV);

	EigenHDF5::save<MatrixXXd>(h5_file, "Zrem", Zrem);

	std::cout << Zrem.mean() << std::endl;
}