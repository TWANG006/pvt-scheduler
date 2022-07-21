#ifndef PVT_APP_H
#define PVT_APP_H

#include <QtWidgets/QMainWindow>
#include "ui_pvtapp.h"
#include "H5Cpp.h"

class pvtapp : public QMainWindow
{
    Q_OBJECT

public:
    pvtapp(QWidget* parent = nullptr);
    ~pvtapp();

public slots:
    void ErrMsg(const QString& msg, const QString& cap = "Error");

private:
    void init_ui();
    void init_connections();
    void open_h5file(const QString& file_name);
    void traverse_h5_file(QTreeWidget* tree_widget, const H5::H5File& h5_file);
    QTreeWidgetItem* add_tree_root(const QString& name, QTreeWidget* tree_widget);
    void add_tree_child(const QString& name, QTreeWidgetItem* parent);
    
    void closeEvent(QCloseEvent* event);

private slots:
    void on_action_Open_triggered();

private:
    Ui::pvtappClass ui;
    QString m_h5FileName;
    H5::H5File m_h5;
};

#endif // !PVT_APP_H



