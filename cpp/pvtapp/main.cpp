#include "pvtapp.h"
#include <QtWidgets/QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    a.setAttribute(Qt::AA_EnableHighDpiScaling);
    a.setAttribute(Qt::AA_UseHighDpiPixmaps);
    a.setOrganizationName("National Synchrotron Light Source II");
    a.setApplicationName("pvtapp");

    pvtapp w;
    w.show();
    return a.exec();
}
