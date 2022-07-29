#include "PVTWorker.h"
#include "eigen3-hdf5.hpp"
#include <QVector>
#include <iostream>
#include <numeric>
#include <Sampler.h>
#include <Simulator.h>
#include "opencv2/opencv.hpp"

PVTWorker::PVTWorker(QObject* parent)
	: QObject(parent)
	, m_cv_vid(nullptr)
	, m_vid_plt(nullptr)
	, m_path_plt(nullptr)
	, m_tif_circ(nullptr)
	, m_surf_map(nullptr)
	, m_title(nullptr)
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
		// init video plt
		init_vid_plt();

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

		auto frame_img = m_vid_plt->toPixmap().toImage();

		if (init_vid_writer(frame_img.width(), frame_img.height(), round(1 / tau), vid_file_name)) {
			set_stop(false);

			// simulate and generate video frames one-by-one
			for (int_t i = 0; i < num_seg && !get_stop(); i++) {
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

				// plot the current frame
				MatrixXXd Zres_tmp_nm = 1e9 * (m_Z - Zrem);
				draw_sim_surf(Zres_tmp_nm, m_minz, m_maxz);
				draw_sim_path();
				draw_sim_tif(x_dp_per_iter * 1e3, y_dp_per_iter * 1e3);
				draw_title(Zres_tmp_nm.maxCoeff() - Zres_tmp_nm.minCoeff(), RMS(Zres_tmp_nm));

				// create the frame
				frame_img = m_vid_plt->toPixmap().toImage();
				auto frame = cv::Mat(
					frame_img.height(),
					frame_img.width(),
					CV_8UC4,
					(uchar*)frame_img.bits(),
					frame_img.bytesPerLine()
				).clone();
				cv::cvtColor(frame, frame, CV_RGBA2RGB);

				// write the frame
				m_cv_vid->write(frame);

				//// show the intermediate result every 10s
				//if ((i * tau > 1) && (int_t(i * tau) % 10 == 0)) {
				//	VectorXd coeffs;
				//	m_Zres = remove_polynomials(coeffs, m_X, m_Y, m_Z - Zrem, 1);
				//	emit update_res_plot(
				//		Zres_tmp_nm.rows(),
				//		Zres_tmp_nm.cols(),
				//		m_maxx,
				//		m_minx,
				//		m_maxy,
				//		m_miny,
				//		m_maxz*1e-9,
				//		m_minz*1e-9,
				//		RMS(m_Zres),
				//		m_X(0, 1) - m_X(0, 0),
				//		QVector<double>(m_X.data(), m_X.data() + m_X.size()),
				//		QVector<double>(m_Y.data(), m_Y.data() + m_Y.size()),
				//		QVector<double>(m_Zres.data(), m_Zres.data() + m_Zres.size())
				//	);
				//}
			}
			m_cv_vid->release();

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
				m_maxz * 1e-9,
				m_minz * 1e-9,
				RMS(m_Zres),
				m_X(0, 1) - m_X(0, 0),
				QVector<double>(m_X.data(), m_X.data() + m_X.size()),
				QVector<double>(m_Y.data(), m_Y.data() + m_Y.size()),
				QVector<double>(m_Zres.data(), m_Zres.data() + m_Zres.size())
			);
		}
	}
}

void PVTWorker::get_path_name(const QString& filePath, const QString& file_name, QString& path_name)
{
	path_name = filePath.right(filePath.length() - file_name.length());
}

void PVTWorker::init_vid_plt()
{
	// prepare the coordintes
	m_X_mm = m_X * 1e3;
	m_Y_mm = m_Y * 1e3;
	m_Z_nm = ((m_Z.array() - m_Z.mean()) * 1e9).matrix();
	VectorXd pxmm = m_xPVTC.P * 1e3;
	VectorXd pymm = m_yPVTC.P * 1e3;
	m_px_mm = QVector<double>(pxmm.data(), pxmm.data() + pxmm.size());
	m_py_mm = QVector<double>(pymm.data(), pymm.data() + pymm.size());
	m_minx = m_X.minCoeff();
	m_maxx = m_X.maxCoeff();
	m_miny = m_Y.minCoeff();
	m_maxy = m_Y.maxCoeff();
	m_maxz = m_Z_nm.maxCoeff();
	m_minz = m_Z_nm.minCoeff();
	m_maxz = std::min(abs(m_minz), abs(m_maxz));
	m_minz = -std::min(abs(m_minz), abs(m_maxz));

	// init the hidden plot
	m_vid_plt.reset(new QCustomPlot());
	//m_vid_plt->setMinimumHeight(900);
	//m_vid_plt->setMinimumWidth(1600);
	m_vid_plt->xAxis2->setVisible(true);
	m_vid_plt->xAxis2->setTickLabels(false);
	m_vid_plt->yAxis2->setVisible(true);
	m_vid_plt->yAxis2->setTickLabels(false);
	connect(m_vid_plt->xAxis, SIGNAL(rangeChanged(QCPRange)), m_vid_plt->xAxis2, SLOT(setRange(QCPRange)));
	connect(m_vid_plt->yAxis, SIGNAL(rangeChanged(QCPRange)), m_vid_plt->yAxis2, SLOT(setRange(QCPRange)));
	
	// init the colormap
	m_surf_map = new QCPColorMap(m_vid_plt->xAxis, m_vid_plt->yAxis);
	QCPColorScale* scale = new QCPColorScale(m_vid_plt.get());
	m_vid_plt->plotLayout()->addElement(0, 1, scale);
	scale->setType(QCPAxis::atRight);
	scale->setRangeDrag(false);
	scale->setRangeZoom(false);
	scale->setLabel("[nm]");
	m_surf_map->setColorScale(scale);
	QCPColorGradient cg(QCPColorGradient::gpJet);
	cg.setNanHandling(QCPColorGradient::nhTransparent);
	m_surf_map->setGradient(cg);
	QCPMarginGroup* marginGroup = new QCPMarginGroup(m_vid_plt.get());
	m_vid_plt->axisRect()->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
	scale->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
	draw_sim_surf(m_Z_nm, m_minz, m_maxz);

	// init the path plot
	m_path_plt = new QCPCurve(m_vid_plt->xAxis, m_vid_plt->yAxis);
	m_path_plt->setPen(QPen(QColor(40, 110, 255, 128)));
	m_path_plt->setLineStyle(QCPCurve::lsLine);
	m_path_plt->setScatterStyle(QCPScatterStyle::ssDisc);
	draw_sim_path();
	
	// init the tif circ to be at the starting point on the path
	m_tif_circ = new QCPItemEllipse(m_vid_plt.get());
	m_tif_circ->setPen(QPen(QColor(60, 82, 45)));
	draw_sim_tif(m_xPVTC.P(0) * 1e3, m_yPVTC.P(0) * 1e3);

	// set title
	m_vid_plt->plotLayout()->insertRow(0);
	m_title = new QCPTextElement(m_vid_plt.get());
	m_vid_plt->plotLayout()->addElement(0, 0, m_title);
	m_title->setFont(QFont("sans", 17, QFont::Bold));
	draw_title((m_maxz - m_minz), RMS(m_Z_nm));
}

bool PVTWorker::init_vid_writer(const int& width, const int& height, const double& fps, const QString& file_name)
{
	QFileInfo file_info(file_name);
	QString file_extension = file_info.suffix();

	if (QString::compare(file_extension, QLatin1String("mp4")) == 0) {
		m_cv_vid.reset(new cv::VideoWriter(
			file_name.toStdString(),
			CV_FOURCC('D', 'I', 'V', 'X'),
			fps,
			cv::Size(width, height),
			true
		));
	}
	else if (QString::compare(file_extension, QLatin1String("flv")) == 0) {
		m_cv_vid.reset(new cv::VideoWriter(
			file_name.toStdString(),
			CV_FOURCC('F', 'L', 'V', '1'),
			fps,
			cv::Size(width, height),
			true
		));
	}
	else if (QString::compare(file_extension, QLatin1String("wmv")) == 0) {
		m_cv_vid.reset(new cv::VideoWriter(
			file_name.toStdString(),
			CV_FOURCC('W', 'M', 'V', '2'),
			fps,
			cv::Size(width, height),
			true
		));
	}
	else if (QString::compare(file_extension, QLatin1String("mpeg")) == 0) {
		m_cv_vid.reset(new cv::VideoWriter(
			file_name.toStdString(),
			CV_FOURCC('P', 'I', 'M', '2'),
			fps,
			cv::Size(width, height),
			true
		));
	}
	else {
		emit err_msg(tr("Unsupported video format (%1) selected.").arg(file_extension));
		return false;
	}
	return true;
}

void PVTWorker::draw_sim_path()
{
	m_path_plt->setData(
		QVector<double>(m_px_mm.data(), m_px_mm.data() + m_px_mm.size()),
		QVector<double>(m_py_mm.data(), m_py_mm.data() + m_py_mm.size())
	);
	m_path_plt->rescaleAxes();
	m_vid_plt->xAxis->setScaleRatio(m_vid_plt->yAxis, 1.0);
	m_vid_plt->replot();
}

void PVTWorker::draw_sim_surf(const MatrixXXd& Zres, const double& minz_nm, const double& maxz_nm)
{
	auto z_mean = Zres.mean();

	// 1. Set the size
	m_surf_map->data()->setSize(Zres.cols(), Zres.rows());
	m_surf_map->data()->setRange(QCPRange(m_minx * 1e3, m_maxx * 1e3), QCPRange(m_miny * 1e3, m_maxy * 1e3));

	// 2. Feed the data
	for (int i = 0; i < Zres.rows(); i++)
	{
		for (int j = 0; j < Zres.cols(); j++)
		{
			m_surf_map->data()->setData(m_X_mm(i, j), m_Y_mm(i, j), Zres(i, j) - z_mean);
		}
	}
	
	// 3. Rescale the color range
	m_surf_map->setDataRange(QCPRange(minz_nm, maxz_nm));

	m_vid_plt->xAxis->setScaleRatio(m_vid_plt->yAxis, 1.0);
	m_vid_plt->replot();
}

void PVTWorker::draw_sim_tif(const double& x_dp, const double& y_dp)
{
	m_tif_circ->topLeft->setCoords(x_dp - m_rx * 1e3, y_dp + m_ry * 1e3);
	m_tif_circ->bottomRight->setCoords(x_dp + m_rx * 1e3, y_dp - m_ry * 1e3);
	m_vid_plt->xAxis->setScaleRatio(m_vid_plt->yAxis, 1.0);
	m_vid_plt->replot();
}

void PVTWorker::draw_title(const double& pv, const double& rms)
{
	m_title->setText(tr("PV = %1 nm, RMS = %2 nm")
		.arg(pv)
		.arg(rms)
	);
	m_vid_plt->xAxis->setScaleRatio(m_vid_plt->yAxis, 1.0);
	m_vid_plt->replot();
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
			// calculate the TIF dimensions
			m_rx = 0.5 * (m_Xtif.maxCoeff() - m_Xtif.minCoeff());
			m_ry = 0.5 * (m_Ytif.maxCoeff() - m_Ytif.minCoeff());

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