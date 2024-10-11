# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'welcome_screen.ui'
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
from PySide6.QtWidgets import (QApplication, QLabel, QListWidget, QListWidgetItem,
    QMainWindow, QPushButton, QSizePolicy, QWidget)

class Ui_Welcome(object):
    def setupUi(self, Welcome):
        if not Welcome.objectName():
            Welcome.setObjectName(u"Welcome")
        Welcome.resize(800, 600)
        Welcome.setMinimumSize(QSize(800, 0))
        self.centralwidget = QWidget(Welcome)
        self.centralwidget.setObjectName(u"centralwidget")
        self.cartLabel = QLabel(self.centralwidget)
        self.cartLabel.setObjectName(u"cartLabel")
        self.cartLabel.setGeometry(QRect(20, 10, 58, 16))
        self.subtotalLabel = QLabel(self.centralwidget)
        self.subtotalLabel.setObjectName(u"subtotalLabel")
        self.subtotalLabel.setGeometry(QRect(460, 100, 61, 16))
        self.itemList = QListWidget(self.centralwidget)
        self.itemList.setObjectName(u"itemList")
        self.itemList.setGeometry(QRect(20, 100, 411, 371))
        self.pushButton = QPushButton(self.centralwidget)
        self.pushButton.setObjectName(u"pushButton")
        self.pushButton.setGeometry(QRect(320, 0, 161, 32))
        Welcome.setCentralWidget(self.centralwidget)

        self.retranslateUi(Welcome)

        QMetaObject.connectSlotsByName(Welcome)
    # setupUi

    def retranslateUi(self, Welcome):
        Welcome.setWindowTitle(QCoreApplication.translate("Welcome", u"MainWindow", None))
        self.cartLabel.setText(QCoreApplication.translate("Welcome", u"Cart", None))
        self.subtotalLabel.setText(QCoreApplication.translate("Welcome", u"Subtotal:", None))
        self.pushButton.setText(QCoreApplication.translate("Welcome", u"Go to Welcome Screen", None))
    # retranslateUi

