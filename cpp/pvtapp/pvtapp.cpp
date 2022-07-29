#include "pvtapp.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QCloseEvent>
#include "utils.h"
#include <iostream>

pvtapp::pvtapp(QWidget* parent)
    : QMainWindow(parent)
    , m_ptrPVTWorker(new PVTWorker())
    , m_tifColormap(nullptr)
    , m_surfColormap(nullptr)
    , m_resColormap(nullptr)
    , m_pathCurve(nullptr)
    , m_dtColorCurve(nullptr)
    , m_dtScale(nullptr)
    , m_feedColorCurve(nullptr)
    , m_feedScale(nullptr)
{
    ui.setupUi(this);

    // create the worker thread
    m_ptrPVTWorker->moveToThread(&m_pvtWorkerThread);
    connect(&m_pvtWorkerThread, &QThread::finished, m_ptrPVTWorker, &QObject::deleteLater);

    //setup ui
    init_ui();

    // init the signal/slot connections
    init_connections();

    // start the worker thread
    m_pvtWorkerThread.start();
}

pvtapp::~pvtapp()
{
    end_thread(m_pvtWorkerThread);
}

void pvtapp::err_msg(const QString & msg, const QString& cap)
{
    QMessageBox::critical(
        this,
        cap,
        msg
    );
}

void pvtapp::update_tif_plot(
    const int&             rows,
    const int&             cols,
    const double&          res,
    const double&          min_z,
    const double&          max_z,
    const double&          min_x,
    const double&          max_x,
    const double&          min_y,
    const double&          max_y,
    const QVector<double>& X, 
    const QVector<double>& Y, 
    const QVector<double>& Z
)
{
    // 1. Set the size
    m_tifColormap->data()->setSize(cols, rows);

    double x_s = min_x * 1e3, x_e = max_x * 1e3;
    double y_s = min_y * 1e3, y_e = max_y * 1e3;
    double v = std::max(x_e - x_s, y_e - y_s) * 0.5;

    m_tifColormap->data()->setRange(QCPRange(x_s, x_e), QCPRange(y_s, y_e));

    // 2. Feed the data
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            auto id = ELT2D(cols, j, i);
            m_tifColormap->data()->setData(X[id] * 1e3, Y[id] * 1e3, Z[id] * 1e9);
        }
    }

    // 3. Rescale the color range
    m_tifColormap->setDataRange(QCPRange(min_z * 1e9, max_z * 1e9));

    // 4. rescale the key (x) and value (y) axes so the whole color map is visible:
    ui.tif_plot->xAxis->setRange(0.5 * (x_e - x_s) + x_s - v, 0.5 * (x_e - x_s) + x_s + v);
    ui.tif_plot->yAxis->setRange(0.5 * (y_e - y_s) + y_s - v, 0.5 * (y_e - y_s) + y_s + v);
    ui.tif_plot->xAxis->setScaleRatio(ui.tif_plot->yAxis, 1.0);
    ui.tif_plot->replot();

    // update the params
    ui.prr_value_box->setValue(1e9 * (max_z - min_z));
    ui.r_value_box->setValue((x_e - x_s) * 0.5);
}

void pvtapp::update_path_plot(
    const double&          width,
    const double&          height,
    const QVector<double>& px,
    const QVector<double>& py
)
{
    // update the plots
    m_pathCurve->setData(px, py);
    m_pathCurve->rescaleAxes();
	if (width <= height) {
		ui.path_plot->xAxis->setScaleRatio(ui.path_plot->yAxis, 1.0);
    }
    else {
        ui.path_plot->yAxis->setScaleRatio(ui.path_plot->xAxis, 1.0);
    }
    ui.path_plot->replot();

    // update the params
    ui.path_w_value_box->setValue(width);
    ui.path_h_value_box->setValue(height);
}

void pvtapp::update_dt_plot(
    const double& width,
    const double& height,
    const double&          total_dt,
    const double&          max_dt,
    const double&          min_dt,
    const QVector<double>& dpx,
    const QVector<double>& dpy,
    const QVector<double>& dt
)
{
    // generate gradient
    QCPColorGradient jetG(QCPColorGradient::gpJet);
    
    // colors
    QVector<QRgb> colors(dt.size(), 0);

    // generate colors for each scatter point
    jetG.colorize(dt.data(), QCPRange(min_dt, max_dt), colors.data(), dt.size());

    // set data
    m_dtColorCurve->setData(dpx, dpy, colors);
    m_dtColorCurve->rescaleAxes();
    m_dtScale->setDataRange(QCPRange(min_dt, max_dt));
    m_dtScale->rescaleDataRange(true);
    if (width <= height) {
        ui.dt_plot->xAxis->setScaleRatio(ui.dt_plot->yAxis, 1.0);
    }
    else {
        ui.dt_plot->yAxis->setScaleRatio(ui.dt_plot->xAxis, 1.0);
    }
    ui.dt_plot->replot();

    ui.total_dt_value_box->setValue(total_dt);
}

void pvtapp::update_feed_plot(
    const double& width,
    const double& height,
    const double&          max_feed,
    const double&          min_feed,
    const QVector<double>& px,
    const QVector<double>& py,
    const QVector<double>& feed
)
{
    // generate gradient
    QCPColorGradient jetG(QCPColorGradient::gpJet);

    // colors
    QVector<QRgb> colors(feed.size(), 0);

    // generate colors for each scatter point
    jetG.colorize(feed.data(), QCPRange(min_feed, max_feed), colors.data(), feed.size());

    // set data
    m_feedColorCurve->setData(px, py, colors);
    m_feedColorCurve->rescaleAxes();
    m_feedScale->setDataRange(QCPRange(min_feed, max_feed));
    m_feedScale->rescaleDataRange(true);
    if (width <= height) {
        ui.feed_plot->xAxis->setScaleRatio(ui.feed_plot->yAxis, 1.0);
    }
    else {
        ui.feed_plot->yAxis->setScaleRatio(ui.feed_plot->xAxis, 1.0);
    }
    ui.feed_plot->replot();
}

void pvtapp::update_surf_plot(
    const int&             rows,
    const int&             cols,
    const double&          max_x,
    const double&          min_x,
    const double&          max_y,
    const double&          min_y,
    const double&          max_z,
    const double&          min_z,
    const double&          rms_z,
    const double&          res,
    const QVector<double>& X,
    const QVector<double>& Y,
    const QVector<double>& Z
)
{
    // 1. Set the size
    m_surfColormap->data()->setSize(cols, rows);

    double x_s = min_x * 1e3, x_e = max_x * 1e3;
    double y_s = min_y * 1e3, y_e = max_y * 1e3;
    double v = std::max(x_e - x_s, y_e - y_s) * 0.5;

    m_surfColormap->data()->setRange(QCPRange(x_s, x_e), QCPRange(y_s, y_e));

    // 2. Feed the data
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            auto id = ELT2D(cols, j, i);
            m_surfColormap->data()->setData(X[id] * 1e3, Y[id] * 1e3, Z[id] * 1e9);
        }
    }

    // 3. Rescale the color range
    m_surfColormap->setDataRange(QCPRange(min_z * 1e9, max_z * 1e9));

    // 4. rescale the key (x) and value (y) axes so the whole color map is visible:
    ui.surf_plot->xAxis->setRange(0.5 * (x_e - x_s) + x_s - v, 0.5 * (x_e - x_s) + x_s + v);
    ui.surf_plot->yAxis->setRange(0.5 * (y_e - y_s) + y_s - v, 0.5 * (y_e - y_s) + y_s + v);

    if (x_e - x_s <= y_e - y_s) {
        ui.surf_plot->xAxis->setScaleRatio(ui.surf_plot->yAxis, 1.0);
    }
    else {
        ui.surf_plot->yAxis->setScaleRatio(ui.surf_plot->xAxis, 1.0);
    }

    ui.surf_plot->replot();

    // update the params
    ui.surf_pv_value_box->setValue(1e9 * (max_z - min_z));
    ui.surf_rms_value_box->setValue(1e9 * rms_z);
    ui.surf_res_value_box->setValue(1e3 * res);
}

void pvtapp::update_res_plot(
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
)
{
    // 1. Set the size
    m_resColormap->data()->setSize(cols, rows);

    double x_s = min_x * 1e3, x_e = max_x * 1e3;
    double y_s = min_y * 1e3, y_e = max_y * 1e3;
    double v = std::max(x_e - x_s, y_e - y_s) * 0.5;

    m_resColormap->data()->setRange(QCPRange(x_s, x_e), QCPRange(y_s, y_e));

    // 2. Feed the data
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            auto id = ELT2D(cols, j, i);
            m_resColormap->data()->setData(X[id] * 1e3, Y[id] * 1e3, Z[id] * 1e9);
        }
    }

    // 3. Rescale the color range
    m_resColormap->setDataRange(QCPRange(min_z * 1e9, max_z * 1e9));

    // 4. rescale the key (x) and value (y) axes so the whole color map is visible:
    ui.res_plot->xAxis->setRange(0.5 * (x_e - x_s) + x_s - v, 0.5 * (x_e - x_s) + x_s + v);
    ui.res_plot->yAxis->setRange(0.5 * (y_e - y_s) + y_s - v, 0.5 * (y_e - y_s) + y_s + v);
    
    if (x_e - x_s <= y_e - y_s) {
        ui.res_plot->xAxis->setScaleRatio(ui.res_plot->yAxis, 1.0);
    }
    else {
        ui.res_plot->yAxis->setScaleRatio(ui.res_plot->xAxis, 1.0);
    }
    
    ui.res_plot->replot();

    // update the params
    ui.res_pv_value_box->setValue(1e9 * (max_z - min_z));
    ui.res_rms_value_box->setValue(1e9 * rms_z);
    ui.res_res_value_box->setValue(1e3 * res);

    //// trial
    //auto circle = new QCPItemEllipse(ui.res_plot);
    //circle->setPen(QPen(Qt::black));
    //circle->topLeft->setCoords(-10.5, -10.5);
    //circle->bottomRight->setCoords(-4.5, -4.5);
    //QCPAxis* x = ui.res_plot->xAxis;
    //QCPAxis* y = ui.res_plot->yAxis;
    //x->setScaleRatio(y, 1.0);
    //ui.res_plot->replot();
    //ui.res_plot->savePng("cao.png");
}

void pvtapp::init_ui()
{
    ui.h5_treeWidget->setHeaderHidden(false);
    init_qcpcolormap(m_tifColormap, ui.tif_plot);
    init_qcpcolormap(m_surfColormap, ui.surf_plot);
    init_qcpcolormap(m_resColormap, ui.res_plot);
    init_lineplot(ui.path_plot);
    init_dtplot(ui.dt_plot);
    init_feedplot(ui.feed_plot);
}

void pvtapp::init_connections()
{
    connect(ui.h5_treeWidget, &QTreeWidget::itemExpanded, this, &pvtapp::on_itemExpanded);
    connect(ui.h5_treeWidget, &QTreeWidget::itemCollapsed, this, &pvtapp::on_itemCollapsed);
    connect(ui.h5_treeWidget, &QTreeWidget::itemClicked, this, &pvtapp::on_itemClicked);
    connect(ui.actionToggle_TIF_view, &QAction::toggled, ui.tif_dockWidget, &QDockWidget::setVisible);
    connect(ui.tif_dockWidget, &QDockWidget::visibilityChanged, ui.actionToggle_TIF_view, &QAction::setChecked);
    connect(ui.actionToggle_File_view, &QAction::toggled, ui.file_dockWidget, &QDockWidget::setVisible);
    connect(ui.file_dockWidget, &QDockWidget::visibilityChanged, ui.actionToggle_File_view, &QAction::setChecked);
    connect(ui.actionToggle_Tool_path_view, &QAction::toggled, ui.path_dockWidget, &QDockWidget::setVisible);
    connect(ui.path_dockWidget, &QDockWidget::visibilityChanged, ui.actionToggle_Tool_path_view, &QAction::setChecked);
    connect(ui.actionToggle_Dwell_time_view, &QAction::toggled, ui.dt_dockWidget, &QDockWidget::setVisible);
    connect(ui.dt_dockWidget, &QDockWidget::visibilityChanged, ui.actionToggle_Dwell_time_view, &QAction::setChecked);
    connect(ui.velocity_dockWidget, &QDockWidget::visibilityChanged, ui.actionToggle_Feedrate_view, &QAction::setChecked);
    connect(ui.actionToggle_Feedrate_view, &QAction::toggled, ui.velocity_dockWidget, &QDockWidget::setVisible);

    connect(m_ptrPVTWorker, &PVTWorker::err_msg, this, &pvtapp::err_msg);
    connect(this, &pvtapp::load_tif, m_ptrPVTWorker, &PVTWorker::load_tif);
    connect(m_ptrPVTWorker, &PVTWorker::update_tif_plot, this, &pvtapp::update_tif_plot);
    connect(this, &pvtapp::load_surf, m_ptrPVTWorker, &PVTWorker::load_surf);
    connect(m_ptrPVTWorker, &PVTWorker::update_surf_plot, this, &pvtapp::update_surf_plot);
    connect(this, &pvtapp::load_path, m_ptrPVTWorker, &PVTWorker::load_path);
    connect(m_ptrPVTWorker, &PVTWorker::update_path_plot, this, &pvtapp::update_path_plot);
    connect(this, &pvtapp::load_dt, m_ptrPVTWorker, &PVTWorker::load_dt);
    connect(m_ptrPVTWorker, &PVTWorker::update_dt_plot, this, &pvtapp::update_dt_plot);
    connect(this, &pvtapp::load_vxvy, m_ptrPVTWorker, &PVTWorker::load_vxvy);
    connect(m_ptrPVTWorker, &PVTWorker::update_feed_plot, this, &pvtapp::update_feed_plot);
    connect(this, &pvtapp::simulate_pvt, m_ptrPVTWorker, &PVTWorker::simulate_pvt);
    connect(m_ptrPVTWorker, &PVTWorker::update_res_plot, this, &pvtapp::update_res_plot);
    connect(this, &pvtapp::schedule_pvt, m_ptrPVTWorker, &PVTWorker::schedule_pvt);
	connect(this, &pvtapp::simulate_pvt_and_make_video, m_ptrPVTWorker, &PVTWorker::simulate_pvt_and_make_video);
    connect(m_ptrPVTWorker, &PVTWorker::update_progress_range, ui.video_progressBar, &QProgressBar::setRange);
    connect(m_ptrPVTWorker, &PVTWorker::update_progress, ui.video_progressBar, &QProgressBar::setValue);
}

void pvtapp::init_qcpcolormap(QCPColorMap*& colormap, QCustomPlot*& widget)
{
    // setup the widget
    widget->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
    widget->axisRect()->setupFullAxesBox(true);
    widget->xAxis->setLabel("x [mm]");
    widget->yAxis->setLabel("y [mm]");

    // setup the colormap
    colormap = new QCPColorMap(widget->xAxis, widget->yAxis);
    QCPColorScale* scale = new QCPColorScale(widget);
    widget->plotLayout()->addElement(0, 1, scale);
    scale->setType(QCPAxis::atRight);
    scale->setRangeDrag(false);
    scale->setRangeZoom(false);
    scale->setLabel("[nm]");
    colormap->setColorScale(scale);
    QCPColorGradient cg(QCPColorGradient::gpJet);
    cg.setNanHandling(QCPColorGradient::nhTransparent);
    colormap->setGradient(cg);

    // setup colorbar
    QCPMarginGroup* marginGroup = new QCPMarginGroup(widget);
    widget->axisRect()->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
    scale->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
}

void pvtapp::init_lineplot(QCustomPlot*& line_plot)
{
    // add graph
    m_pathCurve = new QCPCurve(line_plot->xAxis, line_plot->yAxis);

    // set pen color to blue
    m_pathCurve->setPen(QPen(QColor(40, 110, 255)));
    m_pathCurve->setLineStyle(QCPCurve::lsLine);
    m_pathCurve->setScatterStyle(QCPScatterStyle::ssDisc);

    // configure right and top axis to show ticks but no labels
    line_plot->xAxis2->setVisible(true);
    line_plot->xAxis2->setTickLabels(false);
    line_plot->yAxis2->setVisible(true);
    line_plot->yAxis2->setTickLabels(false);

    // make left and bottom axes always transfer their ranges to right and top axes:
    connect(line_plot->xAxis, SIGNAL(rangeChanged(QCPRange)), line_plot->xAxis2, SLOT(setRange(QCPRange)));
    connect(line_plot->yAxis, SIGNAL(rangeChanged(QCPRange)), line_plot->yAxis2, SLOT(setRange(QCPRange)));
    
    // rescale the graph so that it its the visible area
    m_pathCurve->rescaleAxes();

    // Allow user to drag axis ranges with mouse, zoom with mouse wheel and select graphs by clicking:
    line_plot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom | QCP::iSelectPlottables);
}

void pvtapp::init_dtplot(QCustomPlot*& scatter_plot)
{
    // add the color curve graph
    m_dtColorCurve = new QCPColorCurve(scatter_plot->xAxis, scatter_plot->yAxis);

    // set the line style to scatter points
    m_dtColorCurve->setLineStyle(QCPCurve::lsNone);
    m_dtColorCurve->setScatterStyle(QCPScatterStyle::ssDisc);

    // configure right and top axis to show ticks but no labels
    scatter_plot->xAxis2->setVisible(true);
    scatter_plot->xAxis2->setTickLabels(false);
    scatter_plot->yAxis2->setVisible(true);
    scatter_plot->yAxis2->setTickLabels(false);

    // make left and bottom axes always transfer their ranges to right and top axes:
    connect(scatter_plot->xAxis, SIGNAL(rangeChanged(QCPRange)), scatter_plot->xAxis2, SLOT(setRange(QCPRange)));
    connect(scatter_plot->yAxis, SIGNAL(rangeChanged(QCPRange)), scatter_plot->yAxis2, SLOT(setRange(QCPRange)));

    // rescale the graph so that it its the visible area
    m_dtColorCurve->rescaleAxes();

    // Allow user to drag axis ranges with mouse, zoom with mouse wheel and select graphs by clicking:
    scatter_plot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom | QCP::iSelectPlottables);

    // set colorbar
    m_dtScale = new QCPColorScale(scatter_plot);
    scatter_plot->plotLayout()->addElement(0, 1, m_dtScale);
    m_dtScale->setGradient(QCPColorGradient(QCPColorGradient::gpJet));
    m_dtScale->setType(QCPAxis::atRight);
    m_dtScale->setRangeDrag(false);
    m_dtScale->setRangeZoom(false);
    m_dtScale->setLabel("[s]");
    QCPMarginGroup* marginGroup = new QCPMarginGroup(scatter_plot);
    scatter_plot->axisRect()->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
    m_dtScale->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
}

void pvtapp::init_feedplot(QCustomPlot*& feed_plot)
{
    // add the color curve graph
    m_feedColorCurve = new QCPColorCurve(feed_plot->xAxis, feed_plot->yAxis);

    // set the line style to scatter points
    m_feedColorCurve->setLineStyle(QCPCurve::lsNone);
    m_feedColorCurve->setScatterStyle(QCPScatterStyle::ssDisc);

    // configure right and top axis to show ticks but no labels
    feed_plot->xAxis2->setVisible(true);
    feed_plot->xAxis2->setTickLabels(false);
    feed_plot->yAxis2->setVisible(true);
    feed_plot->yAxis2->setTickLabels(false);

    // make left and bottom axes always transfer their ranges to right and top axes:
    connect(feed_plot->xAxis, SIGNAL(rangeChanged(QCPRange)), feed_plot->xAxis2, SLOT(setRange(QCPRange)));
    connect(feed_plot->yAxis, SIGNAL(rangeChanged(QCPRange)), feed_plot->yAxis2, SLOT(setRange(QCPRange)));

    // rescale the graph so that it its the visible area
    m_feedColorCurve->rescaleAxes();

    // Allow user to drag axis ranges with mouse, zoom with mouse wheel and select graphs by clicking:
    feed_plot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom | QCP::iSelectPlottables);

    // set colorbar
    m_feedScale = new QCPColorScale(feed_plot);
    feed_plot->plotLayout()->addElement(0, 1, m_feedScale);
    m_feedScale->setGradient(QCPColorGradient(QCPColorGradient::gpJet));
    m_feedScale->setType(QCPAxis::atRight);
    m_feedScale->setRangeDrag(false);
    m_feedScale->setRangeZoom(false);
    m_feedScale->setLabel("[mm/s]");
    QCPMarginGroup* marginGroup = new QCPMarginGroup(feed_plot);
    feed_plot->axisRect()->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
    m_feedScale->setMarginGroup(QCP::msBottom | QCP::msTop, marginGroup);
}

void pvtapp::open_h5file(const QString& file_name)
{
    //m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

    try
    {
        H5::Exception::dontPrint();

        // try to open the file
        m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

        // traverse the h5 file if open succeed
        traverse_h5_file(ui.h5_treeWidget, m_h5);
        
        m_h5.close();

        // show the file info
        QFileInfo file_info(file_name);
        ui.h5_treeWidget->setHeaderLabel(file_info.fileName());
        ui.h5_treeWidget->expandToDepth(0);

        // clear the selection
        m_h5FullPath.clear();
    }
    catch (const H5::FileIException& err)
    {
        // close the file handle
        m_h5.close();

        err_msg(
            QString("%1 \n %2").arg(file_name).arg(QString(err.getDetailMsg().c_str())),
            QString("File loading error")
        );
    }
}

void pvtapp::traverse_h5_file(QTreeWidget* tree_widget, const H5::H5File& h5_file)
{
    // clear the current content
    tree_widget->clear();
    
    // add the file name as the 1st level node
    QTreeWidgetItem* root_item = add_tree_root(m_h5FileName, tree_widget);
    root_item->setIcon(0, QIcon(":/pvtapp/images/folder.svg"));

    // traverse the h5_file
    for (int i = 0; i < h5_file.getNumObjs(); i++) {
        // get the child object name and add to the tree widget
        auto obj_name = h5_file.getObjnameByIdx(i);
        QTreeWidgetItem* child_item = add_tree_child(QString::fromStdString(obj_name), root_item);

        // traverse the sub-groups, if any
        if (h5_file.getObjTypeByIdx(i) == H5G_obj_t::H5G_GROUP) {
            child_item->setIcon(0, QIcon(":/pvtapp/images/folder.svg"));
            traverse_child(h5_file.openGroup(obj_name), child_item);
        }
        if (h5_file.getObjTypeByIdx(i) == H5G_obj_t::H5G_DATASET) {
            child_item->setIcon(0, QIcon(":/pvtapp/images/dataset.svg"));
        }
    }
}

void pvtapp::traverse_child(const H5::H5Object& group, QTreeWidgetItem* parent)
{
    auto num_obj = group.getNumObjs();
    if (num_obj == 0) {
        return;
    }
    for (int i = 0; i < num_obj; i++) {
        auto obj_name = group.getObjnameByIdx(i);
        QTreeWidgetItem* root_item = add_tree_child(QString::fromStdString(obj_name), parent);

        if (group.getObjTypeByIdx(i) == H5G_obj_t::H5G_GROUP) {
            root_item->setIcon(0, QIcon(":/pvtapp/images/folder.svg"));
            traverse_child(group.openGroup(group.getObjnameByIdx(i)), root_item);
        }
        if (group.getObjTypeByIdx(i) == H5G_obj_t::H5G_DATASET) {
            root_item->setIcon(0, QIcon(":/pvtapp/images/dataset.svg"));
        }
    }
}

QTreeWidgetItem* pvtapp::add_tree_root(const QString& name, QTreeWidget* tree_widget)
{
    QTreeWidgetItem* root_item = new QTreeWidgetItem(tree_widget);
    root_item->setText(0, name);
    return root_item;
}

QTreeWidgetItem* pvtapp::add_tree_child(const QString& name, QTreeWidgetItem* parent)
{
    QTreeWidgetItem* child_item = new QTreeWidgetItem();
    child_item->setText(0, name);
    parent->addChild(child_item);
    return child_item;
}

void pvtapp::on_itemClicked(QTreeWidgetItem* treeItem, int col)
{
    m_h5FullPath = treeItem->text(col);

    while (treeItem->parent() != NULL)
    {
        m_h5FullPath = treeItem->parent()->text(col) + "/" + m_h5FullPath;
        treeItem = treeItem->parent();
    }
}

void pvtapp::on_load_tif_button_clicked()
{
    if (m_h5FullPath.isEmpty()) {
        err_msg("Please select where the TIF is from the above H5 file.");
    }
    else {
        // determine if the selection contains TIF
        bool isXtif = false, isYtif = false, isZtif = false;
        auto selected_items = ui.h5_treeWidget->selectedItems();
        for (auto& item : selected_items) {
            for (int i = 0; i < item->childCount(); i++) {
                if (item->child(i)->text(0).contains("Xtif")) { isXtif = true; }
                if (item->child(i)->text(0).contains("Ytif")) { isYtif = true; }
                if (item->child(i)->text(0).contains("Ztif")) { isZtif = true; }
            }
        }

        if (isXtif && isYtif && isZtif) {
            emit load_tif(m_h5FileName, m_h5FullPath);
        }
        else {
            err_msg("Xtif, Ytif or Ztif is not found in the selected location.");
        }
    }
}

void pvtapp::on_load_path_button_clicked()
{
    if (m_h5FullPath.isEmpty()) {
        err_msg("Please select where the Path is from the above H5 file.");
    }
    else {
        bool is_px = false, is_py = false;
        auto selected_items = ui.h5_treeWidget->selectedItems();
        for (auto& item : selected_items) {
            for (int i = 0; i < item->childCount(); i++) {
                if (item->child(i)->text(0).contains("px")) { is_px = true; }
                if (item->child(i)->text(0).contains("py")) { is_py = true; }
            }
        }

        if (is_px && is_py) {
            emit load_path(m_h5FileName, m_h5FullPath);
        }
        else {
            err_msg(tr("px or py is not found in the selected path: \n %1")
                .arg(m_h5FullPath)
            );
        }
    }
}

void pvtapp::on_load_dt_button_clicked()
{
    if (m_h5FullPath.isEmpty()) {
        err_msg("Please select where the Dwell Time is from the above H5 file.");
    }
    else {
        bool is_dpx = false, is_dpy = false, is_dt = false;
        auto selected_items = ui.h5_treeWidget->selectedItems();
        for (auto& item : selected_items) {
            for (int i = 0; i < item->childCount(); i++) {
                if (item->child(i)->text(0).contains("dpx")) { is_dpx = true; }
                if (item->child(i)->text(0).contains("dpy")) { is_dpy = true; }
                if (item->child(i)->text(0).contains("dt"))  { is_dt = true;  }
            }
        }

        if (is_dpx && is_dpy && is_dt) {
            emit load_dt(m_h5FileName, m_h5FullPath);
        }
        else {
            err_msg(tr("dpx, dpy or dt is not found in the selected path: \n %1")
                .arg(m_h5FullPath)
            );
        }
    }
}

void pvtapp::on_load_feed_button_clicked()
{
    if (m_h5FullPath.isEmpty()) {
        err_msg("Please select where the Dwell Time is from the above H5 file.");
    }
    else {
        bool is_vx = false, is_vy = false, is_px = false, is_py = false, is_Cx = false, is_Cy = false;
        auto selected_items = ui.h5_treeWidget->selectedItems();
        for (auto& item : selected_items) {
            for (int i = 0; i < item->childCount(); i++) {
                if (item->child(i)->text(0).contains("px")) { is_px = true; }
                if (item->child(i)->text(0).contains("py")) { is_py = true; }
                if (item->child(i)->text(0).contains("vx")) { is_vx = true; }
                if (item->child(i)->text(0).contains("vy")) { is_vy = true; }
                if (item->child(i)->text(0).contains("Cx")) { is_Cx = true; }
                if (item->child(i)->text(0).contains("Cy")) { is_Cy = true; }
            }
        }
        if (is_vx && is_vy && is_px && is_py && is_Cx && is_Cy) {
            emit load_vxvy(m_h5FileName, m_h5FullPath);
        }
        else {
            err_msg(tr("px, py, vx, vy, Cx or Cy is not found in the selected path: \n %1")
                .arg(m_h5FullPath)
            );
        }
    }
}

void pvtapp::on_load_surf_button_clicked()
{
    if (m_h5FullPath.isEmpty()) {
        err_msg("Please select where the Dwell Time is from the above H5 file.");
    }
    else {
        bool is_X = false, is_Y = false, is_Z = false;
        auto selected_items = ui.h5_treeWidget->selectedItems();
        for (auto& item : selected_items) {
            for (int i = 0; i < item->childCount(); i++) {
                if (item->child(i)->text(0).contains("X")) { is_X = true; }
                if (item->child(i)->text(0).contains("Y")) { is_Y = true; }
                if (item->child(i)->text(0).contains("Z")) { is_Z = true; }
            }
        }
		if (is_X && is_Y && is_Z) {
            emit load_surf(m_h5FileName, m_h5FullPath);
        }
        else {
            err_msg(tr("X, Y or Z is not found in the selected path: \n %1")
                .arg(m_h5FullPath)
            );
        }
    }
}

void pvtapp::on_pvt_calc_button_clicked()
{
    if (m_h5FileName.isEmpty()) {
        err_msg("Please select a valid file first.");
    }
    else {
        // obtain the parameters
        double ax_max = ui.axmax_value_box->value();
        double vx_max = ui.vxmax_value_box->value();
        double ay_max = ui.aymax_value_box->value();
        double vy_max = ui.vymax_value_box->value();
        bool is_smooth_v = ui.smooth_v_checkBox->isChecked();

        if (ax_max < 1e-10 || vx_max < 1e-10 || ay_max < 1e-10 || vy_max < 1e-10) {
            err_msg("Max accelerations and velocities cannot be 0.");
        }
        else {
            emit schedule_pvt(ax_max, vx_max, ay_max, vy_max, is_smooth_v);
        }
    }
}

void pvtapp::on_pvt_sim_button_clicked()
{
    if (m_h5FileName.isEmpty()) {
        err_msg("Please select a valid file first.");
    }
	else {
		double tau = ui.dt_value_box->value();
		emit simulate_pvt(tau);
    }
}

void pvtapp::on_pvt_vid_button_clicked()
{
    // get the output video file name
    QString vid_file_name = QFileDialog::getSaveFileName(
        this, 
        tr("Compute and save the simulation to a video."),
        "",
        tr("Video (*.mp4 *.wmv *.mpeg *.flv)")
    );

    if (!vid_file_name.isNull()) {
        double tau = ui.dt_value_box->value();
        emit simulate_pvt_and_make_video(tau, vid_file_name);
    }
}

void pvtapp::on_stop_gen_vid_button_clicked()
{
    m_ptrPVTWorker->set_stop(true);
}

void pvtapp::end_thread(QThread& thrd)
{
    if (thrd.isRunning()) {
        thrd.quit();
        thrd.wait();
    }
}

void pvtapp::closeEvent(QCloseEvent* event)
{
    auto res = QMessageBox::warning(
        this,
        tr("Exit"),
        tr("Do you want to close the pvtapp?"),
        QMessageBox::Yes,
        QMessageBox::No
    );
    
    if (QMessageBox::Yes == res) {
        event->accept();
    }
    else {
        event->ignore();
    }
}

void pvtapp::on_itemExpanded(QTreeWidgetItem* item)
{
    item->setIcon(0, QIcon(":/pvtapp/images/folder-open.svg"));
}

void pvtapp::on_itemCollapsed(QTreeWidgetItem* item)
{
    item->setIcon(0, QIcon(":/pvtapp/images/folder.svg"));
}

void pvtapp::on_action_Open_triggered()
{
    // get the h5 file name
    m_h5FileName = QFileDialog::getOpenFileName(
        this,
        "Select an HDF5 file",
        "",
        "HDF5 Files(*.hdf *.h5 *.hdf5)"
    );

    // try to open the file if it exists
    if (!m_h5FileName.isNull()) {
        open_h5file(m_h5FileName);
    }
}