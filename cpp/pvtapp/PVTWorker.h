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

public slots:
	void load_tif(const QString& file_name, const QString& full_path);
	void load_path(const QString& file_name, const QString& full_path);

private:
	void get_path_name(
		const QString& filePath,
		const QString& file_name,
		QString& path_name
	);

private:
	H5::H5File m_h5;
	VectorXd m_px;
	VectorXd m_py;
	MatrixXXd m_Xtif;
	MatrixXXd m_Ytif;
	MatrixXXd m_Ztif;

};

#endif // !PVT_WORKER_H