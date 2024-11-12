# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'welcome_screen.ui'
##
## Created by: Qt User Interface Compiler version 6.8.0
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
        Welcome.setStyleSheet(u"")
        self.centralwidget = QWidget(Welcome)
        self.centralwidget.setObjectName(u"centralwidget")
        self.bitsnbyteslogo = QLabel(self.centralwidget)
        self.bitsnbyteslogo.setObjectName(u"bitsnbyteslogo")
        self.bitsnbyteslogo.setGeometry(QRect(350, 110, 311, 271))
        self.bitsnbyteslogo.setStyleSheet(u"")
        self.tapButton = QPushButton(self.centralwidget)
        self.tapButton.setObjectName(u"tapButton")
        self.tapButton.setGeometry(QRect(230, 440, 531, 91))
        self.tapButton.setStyleSheet(u"font-size: 30px;")
        self.label = QLabel(self.centralwidget)
        self.label.setObjectName(u"label")
        self.label.setGeometry(QRect(20, 10, 201, 51))
        self.label.setStyleSheet(u"")
        self.infoButton = QPushButton(self.centralwidget)
        self.infoButton.setObjectName(u"infoButton")
        self.infoButton.setGeometry(QRect(950, 10, 61, 61))
        self.infoButton.setStyleSheet(u"")
        Welcome.setCentralWidget(self.centralwidget)

        self.retranslateUi(Welcome)

        QMetaObject.connectSlotsByName(Welcome)
    # setupUi

    def retranslateUi(self, Welcome):
        Welcome.setWindowTitle(QCoreApplication.translate("Welcome", u"MainWindow", None))
        self.bitsnbyteslogo.setText("")
        self.bitsnbyteslogo.setProperty(u"type", QCoreApplication.translate("Welcome", u"logo", None))
        self.tapButton.setText(QCoreApplication.translate("Welcome", u"Tap Card to Start", None))
        self.tapButton.setProperty(u"type", QCoreApplication.translate("Welcome", u"primary", None))
        self.label.setText(QCoreApplication.translate("Welcome", u"<html><head/><body><p><span style=\" font-size:24pt;\">Welcome</span></p></body></html>", None))
        self.infoButton.setText("")
        self.infoButton.setProperty(u"type", QCoreApplication.translate("Welcome", u"info", None))
    # retranslateUi

