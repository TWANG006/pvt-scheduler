#ifndef PVT_WORKER_H
#define PVT_WORKER_H

#include <QObject>
#include "H5Cpp.h"
#include "pvtengine.h"

class PVTWorker : public QObject
{
	Q_OBJECT

public:
	PVTWorker(QObject* parent = nullptr);
	~PVTWorker();

signals:
	void err_msg(const QString& msg, const QString& cap="Error");
	void update_tif_plot(
		int rows,
		int cols,
		double res,
		double min_z,
		double max_z,
		double min_x,
		double max_x,
		double min_y,
		double max_y,
		const QVector<double>& X,
		const QVector<double>& Y,
		const QVector<double>& Z
	);
	void update_path_plot(
		double width,
		double height,
		const QVector<double>& px,
		const QVector<double>& py
	);
	void update_dt_plot(
		double total_dt,
		double max_dt,
		double min_dt,
		const QVector<double>& dpx,
		const QVector<double>& dpy,
		const QVector<double>& dt
	);
	void update_feed_plot(
		double max_feed,
		double min_feed,
		const QVector<double>& px,
		const QVector<double>& py,
		const QVector<double>& feed
	);

public slots:
	void load_tif(const QString& file_name, const QString& full_path);
	void load_path(const QString& file_name, const QString& full_path);
	void load_dt(const QString& file_name, const QString& full_path);
	void load_vxvy(const QString& file_name, const QString& full_path);

private:
	void get_path_name(
		const QString& filePath,
		const QString& file_name,
		QString& path_name
	);

private:
	H5::H5File m_h5;  /*!< the H5 file handle*/
	VectorXd   m_px;  /*!< PVT's p in x*/
	VectorXd   m_py;  /*!< PVT's p in y*/
	VectorXd   m_vx;  /*!< PVT's v in x*/
	VectorXd   m_vy;  /*!< PVT's v in y*/
	MatrixXXd  m_Xtif;/*!< TIF x coordinate grid*/
	MatrixXXd  m_Ytif;/*!< TIF y coordinate grid*/
	MatrixXXd  m_Ztif;/*!< TIF*/
	VectorXd   m_dpx; /*!< dwell point x coordinates*/
	VectorXd   m_dpy; /*!< dwell point y coordiantes*/
	VectorXd   m_dt;  /*!< dwell time and the dwell points*/
};

#endif // !PVT_WORKER_H