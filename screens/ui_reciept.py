# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'reciept_screen.ui'
##
## Created by: Qt User Interface Compiler version 6.7.3
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide6.QtCore import (QCoreApplication, QDate, QDateTime, QLocale,
    QMetaObject, QObject, QPoint, QRect,
    QSize, QTime, QUrl, Qt)
from PySide6.QtGui import (QBrush, QColor, QConicalGradient, QCursor,
    QFont, QFontDatabase, QGradient, QIcon,
    QImage, QKeySequence, QLinearGradient, QPainter,
    QPalette, QPixmap, QRadialGradient, QTransform)
from PySide6.QtWidgets import (QApplication, QListView, QMainWindow, QSizePolicy,
    QWidget)

class Ui_Reciept(object):
    def setupUi(self, Reciept):
        if not Reciept.objectName():
            Reciept.setObjectName(u"Reciept")
        Reciept.resize(1024, 600)
        self.centralwidget = QWidget(Reciept)
        self.centralwidget.setObjectName(u"centralwidget")
        self.listView = QListView(self.centralwidget)
        self.listView.setObjectName(u"listView")
        self.listView.setGeometry(QRect(10, 150, 601, 401))
        Reciept.setCentralWidget(self.centralwidget)

        self.retranslateUi(Reciept)

        QMetaObject.connectSlotsByName(Reciept)
    # setupUi

    def retranslateUi(self, Reciept):
        pass
    # retranslateUi

