#include "pvtapp.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QCloseEvent>

pvtapp::pvtapp(QWidget *parent)
    : QMainWindow(parent)
    , m_ptrPVTWorker(new PVTWorker())
    , m_tifColormap(nullptr)
{
    ui.setupUi(this);

    // create the worker thread
    m_ptrPVTWorker->moveToThread(&m_pvtWorkerThread);
    connect(&m_pvtWorkerThread, &QThread::finished, m_ptrPVTWorker, &QObject::deleteLater);

    // init the signal/slot connections
    init_connections();

    //setup ui
    init_ui();

    // start the worker thread
    m_pvtWorkerThread.start();
}

pvtapp::~pvtapp()
{
    end_thread(m_pvtWorkerThread);
}

void pvtapp::ErrMsg(const QString & msg, const QString& cap)
{
    QMessageBox::critical(
        this,
        cap,
        msg
    );
}

void pvtapp::init_ui()
{
    ui.h5_treeWidget->setHeaderHidden(false);
    init_qcpcolormap(m_tifColormap, ui.tif_plot);
}

void pvtapp::init_connections()
{
    connect(ui.h5_treeWidget, &QTreeWidget::itemExpanded, this, &pvtapp::on_itemExpanded);
    connect(ui.h5_treeWidget, &QTreeWidget::itemCollapsed, this, &pvtapp::on_itemCollapsed);
    connect(ui.h5_treeWidget, &QTreeWidget::itemClicked, this, &pvtapp::on_itemClicked);
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

        // show the file info
        QFileInfo file_info(file_name);
        ui.h5_treeWidget->setHeaderLabel(file_info.fileName());
        ui.h5_treeWidget->expandToDepth(0);

        m_h5.close();
    }
    catch (H5::FileIException err)
    {
        // close the file handle
        m_h5.close();

        ErrMsg(
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
    ErrMsg(m_h5FullPath);
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