#ifndef QCPCOLORCURVE_H
#define QCPCOLORCURVE_H

#include "qcustomplot.h"

class QCPColorCurve : public QCPCurve
{
public:
	QCPColorCurve(QCPAxis* keyAxis, QCPAxis* valueAxis);
	virtual ~QCPColorCurve();

	void setData(
		const QVector<double>& keys,
		const QVector<double>& values,
		const QVector<QColor>& colors
	);

protected:
	virtual void drawScatterPlot(
		QCPPainter* painter, 
		const QVector<QPoint>& points,
		const QCPScatterStyle& style
	) const;

private:
	QVector<QColor> m_colors;
};

#endif // !QCPCOLORCURVE_H