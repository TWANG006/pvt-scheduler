#ifndef PVT_WORKER_H
#define PVT_WORKER_H

#include <QObject>

class PVTWorker : public QObject
{
	Q_OBJECT

public:
	PVTWorker(QObject* parent = nullptr);
	~PVTWorker();

private:

};

#endif // !PVT_WORKER_H