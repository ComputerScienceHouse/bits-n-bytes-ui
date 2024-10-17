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
from PySide6.QtWidgets import (QApplication, QLabel, QMainWindow, QPushButton,
    QSizePolicy, QWidget)

class Ui_Welcome(object):
    def setupUi(self, Welcome):
        if not Welcome.objectName():
            Welcome.setObjectName(u"Welcome")
        Welcome.resize(1024, 600)
        self.centralwidget = QWidget(Welcome)
        self.centralwidget.setObjectName(u"centralwidget")
        self.navButton = QPushButton(self.centralwidget)
        self.navButton.setObjectName(u"navButton")
        self.navButton.setGeometry(QRect(370, 0, 271, 81))
        self.navButton.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 5px; padding: 5px}")
        self.bitsnbyteslogo = QLabel(self.centralwidget)
        self.bitsnbyteslogo.setObjectName(u"bitsnbyteslogo")
        self.bitsnbyteslogo.setGeometry(QRect(80, 0, 831, 601))
        self.bitsnbyteslogo.setStyleSheet(u"QLabel {\n"
"    border: 2px solid black;\n"
"    border-radius: 5px;  /* Optional for rounded corners */\n"
"    padding: 5px;        /* Optional for spacing */\n"
"	qproperty-alignment: 'AlignCenter';\n"
"}")
        self.bitsnbyteslogo.setPixmap(QPixmap(u"../resources/images/BnBLogo.png"))
        self.tapButton = QPushButton(self.centralwidget)
        self.tapButton.setObjectName(u"tapButton")
        self.tapButton.setGeometry(QRect(230, 430, 531, 121))
        self.tapButton.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 50px; padding: 5px}")
        self.infoButton = QLabel(self.centralwidget)
        self.infoButton.setObjectName(u"infoButton")
        self.infoButton.setGeometry(QRect(860, 10, 151, 141))
        self.infoButton.setStyleSheet(u"QLabel {\n"
"    border: 2px solid black;\n"
"    border-radius: 5px;  /* Optional for rounded corners */\n"
"    padding: 5px;        /* Optional for spacing */\n"
"    qproperty-alignment: 'AlignCenter';\n"
"}")
        self.label = QLabel(self.centralwidget)
        self.label.setObjectName(u"label")
        self.label.setGeometry(QRect(20, 10, 101, 51))
        Welcome.setCentralWidget(self.centralwidget)

        self.retranslateUi(Welcome)

        QMetaObject.connectSlotsByName(Welcome)
    # setupUi

    def retranslateUi(self, Welcome):
        Welcome.setWindowTitle(QCoreApplication.translate("Welcome", u"MainWindow", None))
        self.navButton.setText(QCoreApplication.translate("Welcome", u"Go To Cart Screen", None))
        self.bitsnbyteslogo.setText("")
        self.tapButton.setText(QCoreApplication.translate("Welcome", u"Tap Card to Start", None))
        self.infoButton.setText(QCoreApplication.translate("Welcome", u"Image Button (Info Icon)", None))
        self.label.setText(QCoreApplication.translate("Welcome", u"<html><head/><body><p><span style=\" font-size:24pt;\">Welcome</span></p></body></html>", None))
    # retranslateUi

