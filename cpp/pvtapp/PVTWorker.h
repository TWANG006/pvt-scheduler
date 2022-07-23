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

public slots:
	void load_tif(const QString& fileName, const QString& fullPath);

private:
	void get_path_name(
		const QString& filePath,
		const QString& file_name,
		QString& path_name
	);

private:
	H5::H5File m_h5;
	MatrixXXd m_Xtif;
	MatrixXXd m_Ytif;
	MatrixXXd m_Ztif;

};

#endif // !PVT_WORKER_H