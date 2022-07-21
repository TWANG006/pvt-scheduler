#include "pvtapp.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QCloseEvent>

pvtapp::pvtapp(QWidget *parent)
    : QMainWindow(parent)
{
    ui.setupUi(this);

    init_connections();
}

pvtapp::~pvtapp()
{}

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
}

void pvtapp::open_h5file(const QString& file_name)
{
    //m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);

    try
    {
        H5::Exception::dontPrint();

        // try to open the file
        m_h5.openFile(file_name.toStdString(), H5F_ACC_RDONLY);
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
    traverse_h5_file(ui.h5_treeWidget, m_h5);
}

void pvtapp::traverse_h5_file(QTreeWidget* tree_widget, const H5::H5File& h5_file)
{
    // clear the current content
    tree_widget->clear();

    // traverse the h5_file
    for (int i = 0; i < h5_file.getNumObjs(); i++) {
        auto obj_name = h5_file.getObjnameByIdx(i);
        QTreeWidgetItem* root_item = add_tree_root(QString::fromStdString(group_name), tree_widget);
        
        // set the current item to the first column
        if (0 == i) {
            tree_widget->setCurrentItem(root_item);
        }

        // get the data set names in a group
        auto group = h5_file.openGroup(group_name);
        for (int j = 0; j < group.getNumObjs(); j++) {
            add_tree_child(QString::fromStdString(group.getObjnameByIdx(j)), root_item);
        }

        root_item = nullptr;
    }
    m_h5.close();
}

QTreeWidgetItem* pvtapp::add_tree_root(const QString& name, QTreeWidget* tree_widget)
{
    QTreeWidgetItem* root_item = new QTreeWidgetItem(tree_widget);
    root_item->setText(0, name);
    return root_item;
}

void pvtapp::add_tree_child(const QString& name, QTreeWidgetItem* parent)
{
    QTreeWidgetItem* child_item = new QTreeWidgetItem();
    child_item->setText(0, name);
    parent->addChild(child_item);
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
