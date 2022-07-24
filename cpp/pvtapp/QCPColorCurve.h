#ifndef QCPCOLORCURVE_H
#define QCPCOLORCURVE_H

#include "qcustomplot.h"

class QCPColorCurve : public QCPCurve
{
	Q_OBJECT

public:
	QCPColorCurve(QCPAxis* keyAxis, QCPAxis* valueAxis);
	virtual ~QCPColorCurve();

	void setData(
		const QVector<double>& keys,
		const QVector<double>& values,
		const QVector<QRgb>& colors
	);

protected:
	//virtual void draw(QCPPainter* painter) Q_DECL_OVERRIDE;
	virtual void drawScatterPlot(
		QCPPainter* painter,
		const QVector<QPointF>& points,
		const QCPScatterStyle& style
	) const Q_DECL_OVERRIDE;


private:
	QVector<QRgb> m_colors;
};

#endif // !QCPCOLORCURVE_H