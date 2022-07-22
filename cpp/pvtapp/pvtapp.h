#ifndef PVT_APP_H
#define PVT_APP_H

#include <QtWidgets/QMainWindow>
#include "ui_pvtapp.h"
#include <QThread>
#include "hdf5.h"
#include "H5Cpp.h"
#include "PVTWorker.h"

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

    // H5 related
    void open_h5file(const QString& file_name);
    void traverse_h5_file(QTreeWidget* tree_widget, const H5::H5File& h5_file);
    void traverse_child(const H5::H5Object& group, QTreeWidgetItem* parent);
    QTreeWidgetItem* add_tree_root(const QString& name, QTreeWidget* tree_widget);
    QTreeWidgetItem* add_tree_child(const QString& name, QTreeWidgetItem* parent);

    void end_thread(QThread& thrd);

    void closeEvent(QCloseEvent* event);

private slots:
    void on_action_Open_triggered();
    void on_itemExpanded(QTreeWidgetItem* item);
    void on_itemCollapsed(QTreeWidgetItem* item);
    void on_itemClicked(QTreeWidgetItem* treeItem, int col);

private:
    Ui::pvtappClass ui;
    PVTWorker* m_ptrPVTWorker;
    QThread m_pvtWorkerThread;

    QString m_h5FileName;
    H5::H5File m_h5;
    QString m_h5FullPath;
};

#endif // !PVT_APP_H



