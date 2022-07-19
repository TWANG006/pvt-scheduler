#pragma once

#include <QtWidgets/QMainWindow>
#include "ui_pvtapp.h"

class pvtapp : public QMainWindow
{
    Q_OBJECT

public:
    pvtapp(QWidget *parent = nullptr);
    ~pvtapp();

private:
    Ui::pvtappClass ui;
};
