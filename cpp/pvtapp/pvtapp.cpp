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
