#include "pvtapp.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QCloseEvent>

pvtapp::pvtapp(QWidget *parent)
    : QMainWindow(parent)
    , m_ptrPVTWorker(new PVTWorker())
{
    ui.setupUi(this);

    // create the worker thread
    m_ptrPVTWorker->moveToThread(&m_pvtWorkerThread);
    connect(&m_pvtWorkerThread, &QThread::finished, m_ptrPVTWorker, &QObject::deleteLater);

    // init the signal/slot connections
    init_connections();

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
}

void pvtapp::init_connections()
{
    connect(ui.h5_treeWidget, &QTreeWidget::itemExpanded, this, &pvtapp::on_itemExpanded);
    connect(ui.h5_treeWidget, &QTreeWidget::itemCollapsed, this, &pvtapp::on_itemCollapsed);
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

    // traverse the h5_file
    for (int i = 0; i < h5_file.getNumObjs(); i++) {
        auto obj_name = h5_file.getObjnameByIdx(i);
        QTreeWidgetItem* root_item = add_tree_root(QString::fromStdString(obj_name), tree_widget);
        
        //// set the current item to the first column
        //if (0 == i) {
        //    tree_widget->setCurrentItem(root_item);
        //}

        // traverse the sub-groups, if any
        if (h5_file.getObjTypeByIdx(i) == H5G_obj_t::H5G_GROUP) {
            root_item->setIcon(0, QIcon(":/pvtapp/images/folder.svg"));
            traverse_child(h5_file.openGroup(obj_name), root_item);
        }
        if (h5_file.getObjTypeByIdx(i) == H5G_obj_t::H5G_DATASET) {
            root_item->setIcon(0, QIcon(":/pvtapp/images/dataset.svg"));
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