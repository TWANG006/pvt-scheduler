#include "pvtapp.h"
#include <QtWidgets/QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    pvtapp w;
    w.show();
    return a.exec();
}
