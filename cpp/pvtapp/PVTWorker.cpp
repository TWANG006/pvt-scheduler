#include "PVTWorker.h"
#include "eigen3-hdf5.hpp"
#include <QVector>

PVTWorker::PVTWorker(QObject* parent)
	: QObject(parent)
{
}

PVTWorker::~PVTWorker()
{
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

		// plot the TIF
		auto sz = m_Ztif.rows() * m_Ztif.cols();
		emit update_tif_plot(
			m_Ztif.rows(),
			m_Ztif.cols(),
			m_Xtif(0, 1) - m_Xtif(0, 0),
			m_Ztif.minCoeff(),
			m_Ztif.maxCoeff(),
			QVector<double>(m_Xtif.data(), m_Xtif.data() + sz),
			QVector<double>(m_Ytif.data(), m_Ytif.data() + sz),
			QVector<double>(m_Ztif.data(), m_Ztif.data() + sz)
		);
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