#ifndef H5_TREE_MODEL_H
#define H5_TREE_MODEL_H

#include <QStandardItemModel>
#include "H5Cpp.h"
#include "H5public.h"

class H5TreeModel : public QStandardItemModel
{
	Q_OBJECT

public:
	H5TreeModel();
	~H5TreeModel();

private:
	H5::H5File m_h5;
};


#endif // !H5_TREE_MODEL_H


