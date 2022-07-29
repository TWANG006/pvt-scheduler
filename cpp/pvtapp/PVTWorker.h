#ifndef PVT_WORKER_H
#define PVT_WORKER_H

#include <QObject>
#include "H5Cpp.h"
#include "pvtengine.h"
#include "Scheduler.h"
#include "qcustomplot.h"
#include "opencv2/opencv.hpp"
#include <QMutex>

class PVTWorker : public QObject
{
	Q_OBJECT

public:
	PVTWorker(QObject* parent = nullptr);
	~PVTWorker();
	
public:
	void set_stop(bool isStopped)
	{
		QMutexLocker lock(&m_stop_mutex);
		m_is_stopped = isStopped;
	}
	bool get_stop() const 
	{
		return m_is_stopped;
	}

signals:
	void err_msg(const QString& msg, const QString& cap="Error");
	void update_tif_plot(
		const int& rows,
		const int& cols,
		const double& res,
		const double& min_z,
		const double& max_z,
		const double& min_x,
		const double& max_x,
		const double& min_y,
		const double& max_y,
		const QVector<double>& X,
		const QVector<double>& Y,
		const QVector<double>& Z
	);
	void update_path_plot(
		const double& width,
		const double& height,
		const QVector<double>& px,
		const QVector<double>& py
	);
	void update_dt_plot(
		const double& width,
		const double& height,
		const double& total_dt,
		const double& max_dt,
		const double& min_dt,
		const QVector<double>& dpx,
		const QVector<double>& dpy,
		const QVector<double>& dt
	);
	void update_feed_plot(
		const double& width,
		const double& height,
		double max_feed,
		double min_feed,
		const QVector<double>& px,
		const QVector<double>& py,
		const QVector<double>& feed
	);
	void update_surf_plot(
		const int& rows,
		const int& cols,
		const double& max_x,
		const double& min_x,
		const double& max_y,
		const double& min_y,
		const double& max_z,
		const double& min_z,
		const double& rms_z,
		const double& res,
		const QVector<double>& X,
		const QVector<double>& Y,
		const QVector<double>& Z
	);
	void update_res_plot(
		const int& rows,
		const int& cols,
		const double& max_x,
		const double& min_x,
		const double& max_y,
		const double& min_y,
		const double& max_z,
		const double& min_z,
		const double& rms_z,
		const double& res,
		const QVector<double>& X,
		const QVector<double>& Y,
		const QVector<double>& Z
	);
	void update_progress_range(
		const int& min_value,
		const int& max_value
	);
	void update_progress(const int& value);

public slots:
	void load_tif(const QString& file_name, const QString& full_path);
	void load_path(const QString& file_name, const QString& full_path);
	void load_dt(const QString& file_name, const QString& full_path);
	void load_vxvy(const QString& file_name, const QString& full_path);
	void load_surf(const QString& file_name, const QString& full_path);
	void schedule_pvt(
		const double& ax_max,
		const double& vx_max,
		const double& ay_max,
		const double& vy_max,
		bool is_smooth_v = true
	);
	void simulate_pvt(const double& tau);
	void simulate_pvt_and_make_video(const double& tau, const QString& vid_file_name);

private:
	void get_path_name(
		const QString& filePath,
		const QString& file_name,
		QString& path_name
	);
	void init_vid_plt();
	bool init_vid_writer(const int& width, const int& height, const double& fps, const QString& file_name);
	void draw_sim_path();
	void draw_sim_surf(const MatrixXXd& Zres, const double& minz, const double& maxz);
	void draw_sim_tif(const double& x_dp, const double& y_dp);
	void draw_title(const double& pv, const double& rms);

private:
	H5::H5File m_h5;   /*!< the H5 file handle*/
	PVTC       m_xPVTC;/*!< calculated PVT for x*/
	PVTC       m_yPVTC;/*!< calculated PVT for y*/
	MatrixXXd  m_Xtif; /*!< TIF x coordinate grid*/
	MatrixXXd  m_Ytif; /*!< TIF y coordinate grid*/
	MatrixXXd  m_Ztif; /*!< TIF*/
	MatrixXXd  m_X;    /*!< Initial surf X grid*/
	MatrixXXd  m_Y;    /*!< Initial surf Y grid*/
	MatrixXXd  m_Z;    /*!< Initial surf Z*/
	MatrixXXd  m_Zres; /*!< residual surf Z*/
	VectorXd   m_dpx;  /*!< dwell point x coordinates*/
	VectorXd   m_dpy;  /*!< dwell point y coordiantes*/
	VectorXd   m_dt;   /*!< dwell time and the dwell points*/

	/* for video generation functionalities */
	std::unique_ptr<cv::VideoWriter> m_cv_vid; /*!< opencv video writer*/
	std::unique_ptr<QCustomPlot>     m_vid_plt;/*!< the hidden plot*/
	QCPCurve*                        m_path_plt;  /*!< path plot*/
	QCPColorMap*                     m_surf_map;  /*!< surf plot*/
	QCPItemEllipse*                  m_tif_circ;  /*!< TIF schematic plot*/
	QCPTextElement*                  m_title;     /*!< Figure title*/
	double                           m_rx = 0.0;  /*!< TIF half length in x*/
	double                           m_ry = 0.0;  /*!< TIF half length in y*/
	double                           m_minx = 0.0;/*!< min X*/
	double                           m_maxx = 0.0;/*!< max X*/
	double                           m_miny = 0.0;/*!< min Y*/
	double                           m_maxy = 0.0;/*!< max Y*/
	double                           m_minz = 0.0;/*!< min Z*/
	double                           m_maxz = 0.0;/*!< max Z*/
	MatrixXXd                        m_X_mm;      /*!< X in mm*/
	MatrixXXd                        m_Y_mm;      /*!< Y in mm*/
	MatrixXXd                        m_Z_nm;      /*!< Y in mm*/
	QVector<double>                  m_px_mm;     /*!< px in mm*/
	QVector<double>                  m_py_mm;     /*!< py in mm*/
	QMutex                           m_stop_mutex;
	bool                             m_is_stopped = true;
};

#endif // !PVT_WORKER_H