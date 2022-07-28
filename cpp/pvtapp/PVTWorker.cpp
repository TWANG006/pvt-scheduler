#include "PVTWorker.h"
#include "eigen3-hdf5.hpp"
#include <QVector>
#include <iostream>
#include <numeric>
#include <Sampler.h>
#include <Simulator.h>

PVTWorker::PVTWorker(QObject* parent)
	: QObject(parent)
{
}

PVTWorker::~PVTWorker()
{
}

void PVTWorker::load_path(const QString& file_name, const QString& full_path)
{
	// get the h5 file and data path names
	QString path_name;
	get_path_name(full_path, file_name, path_name);

	try
	{
		// open the h5 file
		m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

		// load the path
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/px").toStdString(), m_xPVTC.P);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/py").toStdString(), m_yPVTC.P);
		
		// close the file
		m_h5.close();

		if (!(m_yPVTC.P.size() == m_xPVTC.P.size())) {
			emit err_msg("px and py should be in the same size.");
		}
		else {
			// calculate the range in x and y
			auto width = m_xPVTC.P.maxCoeff() - m_xPVTC.P.minCoeff();
			auto height = m_yPVTC.P.maxCoeff() - m_yPVTC.P.minCoeff();

			// convert to mm
			VectorXd px_mm(m_xPVTC.P * 1e3);
			VectorXd py_mm(m_yPVTC.P * 1e3);

			// update the path plot
			emit update_path_plot(
				width * 1e3,
				height * 1e3,
				QVector<double>(px_mm.data(), px_mm.data() + px_mm.size()),
				QVector<double>(py_mm.data(), py_mm.data() + py_mm.size())
			);
		}
	}
	catch (const H5::FileIException& err)
	{
		// close the file handle
		m_h5.close();

		emit err_msg(
			QString("%1 \n %2").arg(file_name).arg(QString(err.getDetailMsg().c_str())),
			QString("File loading error")
		);
	}
}

void PVTWorker::load_dt(const QString& file_name, const QString& full_path)
{
	// get the h5 file and data path names
	QString path_name;
	get_path_name(full_path, file_name, path_name);

	try
	{
		// open the h5 file
		m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

		// load the path
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/dpx").toStdString(), m_dpx);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/dpy").toStdString(), m_dpy);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/dt").toStdString(), m_dt);

		// close the file
		m_h5.close();

		if (!(m_dpx.size() == m_dpy.size() && m_dpy.size() == m_dt.size())) {
			emit err_msg("dpx, dpy and dt should be in the same size.");
		}
		else {
			// calculate the total dwell time in [min]
			auto total_dt = m_dt.sum() * (1 / 60.0);

			// change to mm
			VectorXd dpx_mm(m_dpx * 1e3);
			VectorXd dpy_mm(m_dpy * 1e3);

			// emit the update dt plot signal
			emit update_dt_plot(
				dpx_mm.maxCoeff() - dpx_mm.minCoeff(),
				dpy_mm.maxCoeff() - dpy_mm.minCoeff(),
				total_dt,
				m_dt.maxCoeff(),
				m_dt.minCoeff(),
				QVector<double>(dpx_mm.data(), dpx_mm.data() + dpx_mm.size()),
				QVector<double>(dpy_mm.data(), dpy_mm.data() + dpy_mm.size()),
				QVector<double>(m_dt.data(), m_dt.data() + m_dt.size())
			);
		}
	}
	catch (const H5::FileIException& err)
	{
		// close the file handle
		m_h5.close();

		emit err_msg(
			QString("%1 \n %2").arg(file_name).arg(QString(err.getDetailMsg().c_str())),
			QString("File loading error")
		);
	}
}

void PVTWorker::load_vxvy(const QString& file_name, const QString& full_path)
{
	// get the h5 file and data path names
	QString path_name;
	get_path_name(full_path, file_name, path_name);

	try
	{
		// open the h5 file
		m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

		// load the path
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/t").toStdString(), m_xPVTC.T);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/px").toStdString(), m_xPVTC.P);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/py").toStdString(), m_yPVTC.P);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/vx").toStdString(), m_xPVTC.V);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/vy").toStdString(), m_yPVTC.V);
		EigenHDF5::load<MatrixX4d>(m_h5, (path_name + "/Cx").toStdString(), m_xPVTC.Coeffs);
		EigenHDF5::load<MatrixX4d>(m_h5, (path_name + "/Cy").toStdString(), m_yPVTC.Coeffs);

		// close the file
		m_h5.close();

		if (!(m_xPVTC.T.size() == m_xPVTC.P.size() && m_xPVTC.P.size() == m_yPVTC.P.size() && m_yPVTC.P.size() == m_xPVTC.V.size() && m_xPVTC.V.size() == m_yPVTC.V.size())) {
			emit err_msg("px, py, vx, vy and t should be in the same size.");
		}
		else {
			m_yPVTC.T = m_xPVTC.T;

			// calculate the total dwell time in [min]
			VectorXd feed_rates(((m_xPVTC.V.array().square() + m_yPVTC.V.array().square()).sqrt() * 1e3).matrix());

			// change to mm
			VectorXd px_mm(m_xPVTC.P * 1e3);
			VectorXd py_mm(m_yPVTC.P * 1e3);

			// emit the update dt plot signal
			emit update_feed_plot(
				px_mm.maxCoeff() - px_mm.minCoeff(),
				py_mm.maxCoeff() - py_mm.minCoeff(),
				feed_rates.maxCoeff(),
				feed_rates.minCoeff(),
				QVector<double>(px_mm.data(), px_mm.data() + px_mm.size()),
				QVector<double>(py_mm.data(), py_mm.data() + py_mm.size()),
				QVector<double>(feed_rates.data(), feed_rates.data() + feed_rates.size())
			);
		}
	}
	catch (const H5::FileIException& err)
	{
		// close the file handle
		m_h5.close();

		emit err_msg(
			QString("%1 \n %2").arg(file_name).arg(QString(err.getDetailMsg().c_str())),
			QString("File loading error")
		);
	}
}

void PVTWorker::load_surf(const QString& file_name, const QString& full_path)
{
	// get the h5 file and data path names
	QString path_name;
	get_path_name(full_path, file_name, path_name);

	try
	{
		// open the h5 file
		m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

		// load the path
		EigenHDF5::load<MatrixXXd>(m_h5, (path_name + "/X").toStdString(), m_X);
		EigenHDF5::load<MatrixXXd>(m_h5, (path_name + "/Y").toStdString(), m_Y);
		EigenHDF5::load<MatrixXXd>(m_h5, (path_name + "/Z").toStdString(), m_Z);

		// close the file
		m_h5.close();

		if (!(m_X.size() == m_Y.size() && m_Y.size() == m_Z.size())) {
			emit err_msg("X, Y and Z should be in the same size.");
		}
		else{
			// emit the update dt plot signal
			emit update_surf_plot(
				m_X.rows(),
				m_X.cols(),
				m_X.maxCoeff(),
				m_X.minCoeff(),
				m_Y.maxCoeff(),
				m_Y.minCoeff(),
				m_Z.maxCoeff(),
				m_Z.minCoeff(),
				RMS(m_Z),
				m_X(0, 1) - m_X(0, 0),
				QVector<double>(m_X.data(), m_X.data() + m_X.size()),
				QVector<double>(m_Y.data(), m_Y.data() + m_Y.size()),
				QVector<double>(m_Z.data(), m_Z.data() + m_Z.size())
			);
		}
	}
	catch (const H5::FileIException& err)
	{
		// close the file handle
		m_h5.close();

		emit err_msg(
			QString("%1 \n %2").arg(file_name).arg(QString(err.getDetailMsg().c_str())),
			QString("File loading error")
		);
	}
}

void PVTWorker::schedule_pvt(const double& ax_max, const double& vx_max, const double& ay_max, const double& vy_max, bool is_smooth_v)
{
	// check if the required data for Scheduler are all loaded
	if ((m_xPVTC.P.size() == 0 || m_yPVTC.P.size() == 0 || m_dt.size() == 0)) {
		emit err_msg("Please load the Positions and Dwell time first.");
	}
	else {
		// calculate the PVT's T
		if (m_dt.size() == m_xPVTC.P.size() || m_dt.size() == m_xPVTC.P.size() - 1) {
			if (m_dt.size() == m_xPVTC.P.size() && m_xPVTC.P.size() == m_yPVTC.P.size()) {
				m_xPVTC.T = m_dt;
				m_yPVTC.T = m_dt;
			}
			else {
				m_xPVTC.T = VectorXd(m_dt.size() + 1);
				m_xPVTC.T << 0, m_dt;
				std::partial_sum(m_xPVTC.T.begin(), m_xPVTC.T.end(), m_xPVTC.T.begin(), std::plus<double>());
				m_yPVTC.T = m_xPVTC.T;
			}

			// schedule PVT in x
			Scheduler scheduler;
			std::string str_error;
			m_xPVTC = scheduler(str_error, m_xPVTC.P, m_xPVTC.T, vx_max, ax_max, 0.0, 0.0, 0.0, 0.0, is_smooth_v);
			m_yPVTC = scheduler(str_error, m_yPVTC.P, m_yPVTC.T, vy_max, ay_max, 0.0, 0.0, 0.0, 0.0, is_smooth_v);

			if (str_error.size() < 1) {
				// calculate the total dwell time in [min]
				VectorXd feed_rates(((m_xPVTC.V.array().square() + m_yPVTC.V.array().square()).sqrt() * 1e3).matrix());

				// change to mm
				VectorXd px_mm(m_xPVTC.P * 1e3);
				VectorXd py_mm(m_yPVTC.P * 1e3);

				// emit the update dt plot signal
				emit update_feed_plot(
					px_mm.maxCoeff() - px_mm.minCoeff(),
					py_mm.maxCoeff() - py_mm.minCoeff(),
					feed_rates.maxCoeff(),
					feed_rates.minCoeff(),
					QVector<double>(px_mm.data(), px_mm.data() + px_mm.size()),
					QVector<double>(py_mm.data(), py_mm.data() + py_mm.size()),
					QVector<double>(feed_rates.data(), feed_rates.data() + feed_rates.size())
				);
			}
			else {
				emit err_msg(QString::fromStdString(str_error));
			}
		}
		else {
			emit err_msg("Positions and Times should have the same number of elements.");
		}
	}
}

void PVTWorker::simulate_pvt(const double& tau)
{
	// check if the required data for Scheduler are all loaded
	if ((m_xPVTC.P.size() == 0 || m_yPVTC.P.size() == 0 || m_xPVTC.P.size() != m_yPVTC.P.size() ||
		 m_xPVTC.T.size() == 0 || m_yPVTC.T.size() == 0 || m_xPVTC.T.size() != m_yPVTC.T.size() ||
		 m_xPVTC.V.size() == 0 || m_yPVTC.V.size() == 0 || m_xPVTC.V.size() != m_yPVTC.V.size() ||
		 m_xPVTC.Coeffs.size() == 0 || m_yPVTC.Coeffs.size() == 0 || m_xPVTC.Coeffs.size() != m_yPVTC.Coeffs.size())) {
		emit err_msg("Please load the Positions, Velocities and Times first.");
	}
	else if (m_X.size() == 0 || m_Y.size() == 0 || m_Z.size() == 0) {
		emit err_msg("Please load the initial surface.");
	}
	else if (m_Xtif.size() == 0 || m_Ytif.size() == 0 || m_Ztif.size() == 0) {
		emit err_msg("Please load a TIF.");
	}
	else {
		Sampler sampler;
		PVA xPVA = sampler(tau, m_xPVTC);
		PVA yPVA = sampler(tau, m_yPVTC);
		Simulator simulator(m_Xtif, m_Ytif.colwise().reverse(), m_Ztif.colwise().reverse(), m_X, m_Y, m_Z);
		VectorXd coeffs;
		m_Zres = remove_polynomials(coeffs, m_X, m_Y, m_Z - simulator(xPVA, yPVA), 1);

		emit update_res_plot(
			m_X.rows(),
			m_X.cols(),
			m_X.maxCoeff(),
			m_X.minCoeff(),
			m_Y.maxCoeff(),
			m_Y.minCoeff(),
			m_Zres.maxCoeff(),
			m_Zres.minCoeff(),
			RMS(m_Zres),
			m_X(0, 1) - m_X(0, 0),
			QVector<double>(m_X.data(), m_X.data() + m_X.size()),
			QVector<double>(m_Y.data(), m_Y.data() + m_Y.size()),
			QVector<double>(m_Zres.data(), m_Zres.data() + m_Zres.size())
		);
	}
}

void PVTWorker::simulate_pvt_and_make_video(const double& tau, const QString& vid_file_name)
{
	// check if the required data for Scheduler are all loaded
	if ((m_xPVTC.P.size() == 0 || m_yPVTC.P.size() == 0 || m_xPVTC.P.size() != m_yPVTC.P.size() ||
		m_xPVTC.T.size() == 0 || m_yPVTC.T.size() == 0 || m_xPVTC.T.size() != m_yPVTC.T.size() ||
		m_xPVTC.V.size() == 0 || m_yPVTC.V.size() == 0 || m_xPVTC.V.size() != m_yPVTC.V.size() ||
		m_xPVTC.Coeffs.size() == 0 || m_yPVTC.Coeffs.size() == 0 || m_xPVTC.Coeffs.size() != m_yPVTC.Coeffs.size())) {
		emit err_msg("Please load the Positions, Velocities and Times first.");
	}
	else if (m_X.size() == 0 || m_Y.size() == 0 || m_Z.size() == 0) {
		emit err_msg("Please load the initial surface.");
	}
	else if (m_Xtif.size() == 0 || m_Ytif.size() == 0 || m_Ztif.size() == 0) {
		emit err_msg("Please load a TIF.");
	}
	else {
		// sampling
		Sampler sampler;
		PVA xPVA = sampler(tau, m_xPVTC);
		PVA yPVA = sampler(tau, m_yPVTC);

		// initialize the simulator
		Simulator simulator(m_Xtif, m_Ytif.colwise().reverse(), m_Ztif.colwise().reverse(), m_X, m_Y, m_Z);

		// initialize the Zremoval to 0's
		MatrixXXd Zrem(m_Z.rows(), m_Z.cols());
		Zrem.fill(0.0);
		MatrixXXd Zrem_per_iter(m_Z.rows(), m_Z.cols());
		double x_dp_per_iter = 0.0, y_dp_per_iter = 0.0;

		// get the number of segment and notify the ui's progress bar
		auto num_seg = xPVA.P.size() - 1;
		emit update_progress_range(0, num_seg);

		// simulate and generate video frames one-by-one
		for (int_t i = 0; i < num_seg; i++) {
			simulator.removal_per_pvt_segment(
				xPVA.P(i), xPVA.P(i + 1),
				yPVA.P(i), yPVA.P(i + 1),
				xPVA.V(i), xPVA.V(i + 1),
				yPVA.V(i), yPVA.V(i + 1),
				Zrem_per_iter,
				x_dp_per_iter,
				y_dp_per_iter
			);
			// accumulate the removal
			Zrem += Zrem_per_iter;
			emit update_progress(i + 1);

			// update plot every 20 frames

			// create and save each frame
		}

		// show the final residual after generating the video
		VectorXd coeffs;
		m_Zres = remove_polynomials(coeffs, m_X, m_Y, m_Z - Zrem, 1);
		emit update_res_plot(
			m_X.rows(),
			m_X.cols(),
			m_X.maxCoeff(),
			m_X.minCoeff(),
			m_Y.maxCoeff(),
			m_Y.minCoeff(),
			m_Zres.maxCoeff(),
			m_Zres.minCoeff(),
			RMS(m_Zres),
			m_X(0, 1) - m_X(0, 0),
			QVector<double>(m_X.data(), m_X.data() + m_X.size()),
			QVector<double>(m_Y.data(), m_Y.data() + m_Y.size()),
			QVector<double>(m_Zres.data(), m_Zres.data() + m_Zres.size())
		);
	}
}

void PVTWorker::get_path_name(const QString& filePath, const QString& file_name, QString& path_name)
{
	path_name = filePath.right(filePath.length() - file_name.length());
}

void PVTWorker::load_tif(const QString& file_name, const QString& fullPath)
{
	// get the h5 file and data path names
	QString path_name;
	get_path_name(fullPath, file_name, path_name);

	try
	{
		// open the h5 file
		m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

		// load the tif
		EigenHDF5::load< MatrixXXd>(m_h5, (path_name + "/Xtif").toStdString(), m_Xtif);
		EigenHDF5::load< MatrixXXd>(m_h5, (path_name + "/Ytif").toStdString(), m_Ytif);
		EigenHDF5::load< MatrixXXd>(m_h5, (path_name + "/Ztif").toStdString(), m_Ztif);
		
		m_h5.close();

		if (!(m_Xtif.size() == m_Ytif.size() && m_Ytif.size() == m_Ztif.size())) {
			emit err_msg("Xtif, Ytif and Ztif should be in the same size.");
		}
		else{
			// plot the TIF
			auto sz = m_Ztif.rows() * m_Ztif.cols();
			emit update_tif_plot(
				m_Ztif.rows(),
				m_Ztif.cols(),
				m_Xtif(0, 1) - m_Xtif(0, 0),
				m_Ztif.minCoeff(),
				m_Ztif.maxCoeff(),
				m_Xtif.minCoeff(),
				m_Xtif.maxCoeff(),
				m_Ytif.minCoeff(),
				m_Ytif.maxCoeff(),
				QVector<double>(m_Xtif.data(), m_Xtif.data() + sz),
				QVector<double>(m_Ytif.data(), m_Ytif.data() + sz),
				QVector<double>(m_Ztif.data(), m_Ztif.data() + sz)
			);
		}
	}
	catch (const H5::FileIException& err)
	{
		// close the file handle
		m_h5.close();

		emit err_msg(
			QString("%1 \n %2").arg(file_name).arg(QString(err.getDetailMsg().c_str())),
			QString("File loading error")
		);
	}
}