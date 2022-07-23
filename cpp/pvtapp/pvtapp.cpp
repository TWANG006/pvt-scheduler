#include "pvtapp.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QCloseEvent>
#include "utils.h"

pvtapp::pvtapp(QWidget *parent)
    : QMainWindow(parent)
    , m_ptrPVTWorker(new PVTWorker())
    , m_tifColormap(nullptr)
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

void pvtapp::update_tif_plot(int rows, int cols, double res, double min_z, double max_z, const QVector<double>& X, const QVector<double>& Y, const QVector<double>& Z)
{
    // 1. Set the size
    m_tifColormap->data()->setSize(cols, rows);

    double x_s = X[0] * 1e3, x_e = X[cols - 1] * 1e3;
    double y_e = Y[0] * 1e3, y_s = Y[(rows - 1) * cols] * 1e3;
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

    ui.tif_plot->replot();

    // update the params
    ui.prr_value_box->setValue(1e9 * (max_z - min_z));
    ui.r_value_box->setValue((x_e - x_s) * 0.5);
}

void pvtapp::update_path_plot(double width, double height, const QVector<double>& px, const QVector<double>& py)
{
    ui.path_plot->graph()->setData(px, py);
    ui.path_plot->graph()->rescaleAxes();
    ui.path_plot->replot();
}

void pvtapp::init_ui()
{
    ui.h5_treeWidget->setHeaderHidden(false);
    init_qcpcolormap(m_tifColormap, ui.tif_plot);
    init_lineplot(ui.path_plot);
}

void pvtapp::init_connections()
{
    connect(ui.h5_treeWidget, &QTreeWidget::itemExpanded, this, &pvtapp::on_itemExpanded);
    connect(ui.h5_treeWidget, &QTreeWidget::itemCollapsed, this, &pvtapp::on_itemCollapsed);
    connect(ui.h5_treeWidget, &QTreeWidget::itemClicked, this, &pvtapp::on_itemClicked);
    connect(this, &pvtapp::load_tif, m_ptrPVTWorker, &PVTWorker::load_tif);
    connect(m_ptrPVTWorker, &PVTWorker::err_msg, this, &pvtapp::err_msg);
    connect(m_ptrPVTWorker, &PVTWorker::update_tif_plot, this, &pvtapp::update_tif_plot);
    connect(this, &pvtapp::load_path, m_ptrPVTWorker, &PVTWorker::load_path);
    connect(m_ptrPVTWorker, &PVTWorker::update_path_plot, this, &pvtapp::update_path_plot);
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
    scale->setLabel("height");
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
    line_plot->addGraph();

    // set pen color to blue
    line_plot->graph()->setPen(QPen(QColor(40, 110, 255)));
    line_plot->graph()->setLineStyle(QCPGraph::lsNone);
    line_plot->graph()->setScatterStyle(QCPScatterStyle::ssDisc);

    // configure right and top axis to show ticks but no labels
    line_plot->xAxis2->setVisible(true);
    line_plot->xAxis2->setTickLabels(false);
    line_plot->yAxis2->setVisible(true);
    line_plot->yAxis2->setTickLabels(false);

    // make left and bottom axes always transfer their ranges to right and top axes:
    connect(line_plot->xAxis, SIGNAL(rangeChanged(QCPRange)), line_plot->xAxis2, SLOT(setRange(QCPRange)));
    connect(line_plot->yAxis, SIGNAL(rangeChanged(QCPRange)), line_plot->yAxis2, SLOT(setRange(QCPRange)));
    
    // rescale the graph so that it its the visible area
    line_plot->graph()->rescaleAxes();

    // Allow user to drag axis ranges with mouse, zoom with mouse wheel and select graphs by clicking:
    line_plot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom | QCP::iSelectPlottables);
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
    if (!m_h5FileName.isEmpty()) {
        open_h5file(m_h5FileName);
    }
}