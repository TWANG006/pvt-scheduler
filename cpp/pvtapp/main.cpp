#include "pvtapp.h"
#include <QtWidgets/QApplication>
#include <QVector>
#include <QList>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    // add high-dpi support
    a.setAttribute(Qt::AA_EnableHighDpiScaling);
    a.setAttribute(Qt::AA_UseHighDpiPixmaps);
    a.setOrganizationName("National Synchrotron Light Source II");
    a.setApplicationName("pvtapp");

    // register the extra required meta-objects
    qRegisterMetaType<QVector<double>>("QVector<double>");
    qRegisterMetaType<QList<double>>("QList<double>");

    pvtapp w;
    w.show();
    return a.exec();
}
