#ifndef PVT_APP_H
#define PVT_APP_H

#include <QtWidgets/QMainWindow>
#include "ui_pvtapp.h"
#include <QThread>
#include <QVector>
#include "hdf5.h"
#include "H5Cpp.h"
#include "PVTWorker.h"
#include "QCPColorCurve.h"

class pvtapp : public QMainWindow
{
    Q_OBJECT

public:
    pvtapp(QWidget* parent = nullptr);
    ~pvtapp();

signals:
    void load_tif(const QString& file_name, const QString& full_path);
    void load_path(const QString& file_name, const QString& full_path);
    void load_dt(const QString& file_name, const QString& full_path);
    void load_vxvy(const QString& file_name, const QString& full_path);
    void load_surf(const QString& file_name, const QString& full_path);

public slots:
    void err_msg(const QString& msg, const QString& cap = "Error");
    void update_tif_plot(
        const int& rows,
        const int& cols,
        const double& res,
        const double& min_z,
        const double& max_z,
        const double& min_x,
        const double& max_x,
        const double& min_y,
        const double& max_y,
        const QVector<double>& X,
        const QVector<double>& Y,
        const QVector<double>& Z
    );
    void update_path_plot(
        const double& width,
        const double& height,
        const QVector<double>& px,
        const QVector<double>& py
    );
    void update_dt_plot(
        const double& total_dt,
        const double& max_dt,
        const double& min_dt,
        const QVector<double>& dpx,
        const QVector<double>& dpy,
        const QVector<double>& dt
    );
    void update_feed_plot(
        const double& max_feed,
        const double& min_feed,
        const QVector<double>& px,
        const QVector<double>& py,
        const QVector<double>& feed
    );
    void update_surf_plot(
        const int& rows,
        const int& cols,
        const double& max_x,
        const double& min_x,
        const double& max_y,
        const double& min_y,
        const double& max_z,
        const double& min_z,
        const double& rms_z,
        const double& res,
        const QVector<double>& X,
        const QVector<double>& Y,
        const QVector<double>& Z
    );

private:
    void init_ui();
    void init_connections();
    void init_qcpcolormap(QCPColorMap*& colormap, QCustomPlot*& widget);
    void init_lineplot(QCustomPlot*& line_plot);
    void init_dtplot(QCustomPlot*& dt_plot);
    void init_feedplot(QCustomPlot*& feed_plot);

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
    void on_load_tif_button_clicked();
    void on_load_path_button_clicked();
    void on_load_dt_button_clicked();
    void on_load_feed_button_clicked();
    void on_load_surf_button_clicked();

private:
    Ui::pvtappClass ui;
    PVTWorker* m_ptrPVTWorker;
    QThread m_pvtWorkerThread;

    QString m_h5FileName;
    H5::H5File m_h5;
    QString m_h5FullPath;

    QCPColorMap* m_tifColormap;
    QCPColorMap* m_surfColormap;
    QCPColorMap* m_resColormap;
    QCPCurve* m_pathCurve;
    QCPColorCurve* m_dtColorCurve;
    QCPColorScale* m_dtScale;
    QCPColorCurve* m_feedColorCurve;
    QCPColorScale* m_feedScale;
};

#endif // !PVT_APP_H