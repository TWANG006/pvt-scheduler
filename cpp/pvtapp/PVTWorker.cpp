#include "PVTWorker.h"
#include "eigen3-hdf5.hpp"
#include <QVector>
#include <iostream>
#include <numeric>

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
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/px").toStdString(), m_px);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/py").toStdString(), m_py);
		
		// close the file
		m_h5.close();

		if (!(m_px.size() == m_py.size())) {
			emit err_msg("px and py should be in the same size.");
		}
		else {
			// calculate the range in x and y
			auto width = m_px.maxCoeff() - m_px.minCoeff();
			auto height = m_py.maxCoeff() - m_py.minCoeff();

			// convert to mm
			VectorXd px_mm(m_px * 1e3);
			VectorXd py_mm(m_py * 1e3);

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
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/px").toStdString(), m_px);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/py").toStdString(), m_py);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/vx").toStdString(), m_vx);
		EigenHDF5::load<VectorXd>(m_h5, (path_name + "/vy").toStdString(), m_vy);

		// close the file
		m_h5.close();

		if (!(m_px.size() == m_py.size() && m_py.size() == m_vx.size() && m_vx.size() == m_vy.size())) {
			emit err_msg("px, py, vx and vy should be in the same size.");
		}
		else {
			// calculate the total dwell time in [min]
			VectorXd feed_rates(((m_vx.array().square() + m_vy.array().square()).sqrt() * 1e3).matrix());

			// change to mm
			VectorXd px_mm(m_px * 1e3);
			VectorXd py_mm(m_py * 1e3);

			// emit the update dt plot signal
			emit update_feed_plot(
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
	if ((m_px.size() == 0 || m_py.size() == 0 || m_dt.size() == 0)) {
		emit err_msg("Please load the Positions and Dwell time first.");
	}
	else {
		// calculate the PVT's T
		if (m_dt.size() == m_px.size() || m_dt.size() == m_px.size() - 1) {
			if (m_dt.size() == m_px.size() && m_px.size() == m_py.size()) {
				m_t = m_dt;
				std::cout << m_t.transpose() << std::endl;
			}
			else {
				m_t = VectorXd(m_dt.size() + 1);
				m_t << 0, m_dt;
				std::partial_sum(m_t.begin(), m_t.end(), m_t.begin(), std::plus<double>());
			}

			// schedule PVT in x
			auto PVTx = m_scheduler(m_px, m_t, vx_max, ax_max, 0.0, 0.0, 0.0, 0.0, is_smooth_v);
			auto PVTy = m_scheduler(m_py, m_t, vy_max, ay_max, 0.0, 0.0, 0.0, 0.0, is_smooth_v);

			// assign to the members
			m_Cx = PVTx.Coeffs;
			m_vx = PVTx.V;
			m_Cy = PVTy.Coeffs;
			m_vy = PVTy.V;

			std::cout << m_vx.transpose() << std::endl;
			std::cout << m_vy.transpose() << std::endl;

			// calculate the total dwell time in [min]
			VectorXd feed_rates(((m_vx.array().square() + m_vy.array().square()).sqrt() * 1e3).matrix());

			// change to mm
			VectorXd px_mm(m_px * 1e3);
			VectorXd py_mm(m_py * 1e3);

			// emit the update dt plot signal
			emit update_feed_plot(
				feed_rates.maxCoeff(),
				feed_rates.minCoeff(),
				QVector<double>(px_mm.data(), px_mm.data() + px_mm.size()),
				QVector<double>(py_mm.data(), py_mm.data() + py_mm.size()),
				QVector<double>(feed_rates.data(), feed_rates.data() + feed_rates.size())
			);
		}
		else {
			emit err_msg("Positions and Times should have the same number of elements.");
		}
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