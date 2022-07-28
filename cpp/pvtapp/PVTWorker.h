#ifndef PVT_WORKER_H
#define PVT_WORKER_H

#include <QObject>
#include "H5Cpp.h"
#include "pvtengine.h"
#include "Scheduler.h"

class PVTWorker : public QObject
{
	Q_OBJECT

public:
	PVTWorker(QObject* parent = nullptr);
	~PVTWorker();

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

private:
	H5::H5File m_h5;  /*!< the H5 file handle*/
	PVTC       m_xPVTC;
	PVTC       m_yPVTC;
	MatrixXXd  m_Xtif;/*!< TIF x coordinate grid*/
	MatrixXXd  m_Ytif;/*!< TIF y coordinate grid*/
	MatrixXXd  m_Ztif;/*!< TIF*/
	MatrixXXd  m_X;   /*!< Initial surf X grid*/
	MatrixXXd  m_Y;   /*!< Initial surf Y grid*/
	MatrixXXd  m_Z;   /*!< Initial surf Z*/
	MatrixXXd  m_Zres;/*!< residual surf Z*/
	VectorXd   m_dpx; /*!< dwell point x coordinates*/
	VectorXd   m_dpy; /*!< dwell point y coordiantes*/
	VectorXd   m_dt;  /*!< dwell time and the dwell points*/

	Scheduler m_scheduler;
};

#endif // !PVT_WORKER_H