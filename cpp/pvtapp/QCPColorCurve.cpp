#include "QCPColorCurve.h"

QCPColorCurve::QCPColorCurve(QCPAxis* keyAxis, QCPAxis* valueAxis)
	: QCPCurve(keyAxis, valueAxis)
{
}

QCPColorCurve::~QCPColorCurve()
{
}

void QCPColorCurve::setData(const QVector<double>& keys, const QVector<double>& values, const QVector<QRgb>& colors)
{
	if (values.size() != colors.size()) return;
	m_colors = colors;
	QCPCurve::setData(keys, values);
}

void QCPColorCurve::drawScatterPlot(QCPPainter* painter, const QVector<QPointF>& points, const QCPScatterStyle& style) const
{
	applyScattersAntialiasingHint(painter);
	auto nPoints = points.size();

	for (int i = 0; i < nPoints; i++) {
		if (!qIsNaN(points.at(i).x()) && !qIsNaN(points.at(i).y())) {
			painter->setPen(QColor(m_colors[i]));
			style.drawShape(painter, points.at(i));
		}
	}
}

//void QCPColorCurve::draw(QCPPainter* painter)
//{
//	QCPCurve::draw(painter);
//}
