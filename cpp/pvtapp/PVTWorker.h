#ifndef PVT_WORKER_H
#define PVT_WORKER_H

#include <QObject>

class PVTWorker : public QObject
{
	Q_OBJECT

public:
	PVTWorker(QObject* parent = nullptr);
	~PVTWorker();

signals:
	void ErrMsg(const QString& msg, const QString& cap);

public slots:
	void on_load_tif(const QString& fullPath);

private:

};

#endif // !PVT_WORKER_H