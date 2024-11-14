# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'admin_screen.ui'
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

class Ui_Admin(object):
    def setupUi(self, Admin):
        if not Admin.objectName():
            Admin.setObjectName(u"Admin")
        Admin.resize(1024, 600)
        Admin.setStyleSheet(u"")
        self.centralwidget = QWidget(Admin)
        self.centralwidget.setObjectName(u"centralwidget")
        self.label = QLabel(self.centralwidget)
        self.label.setObjectName(u"label")
        self.label.setGeometry(QRect(20, 10, 101, 51))
        self.label.setStyleSheet(u"")
        self.openDoorButton = QPushButton(self.centralwidget)
        self.openDoorButton.setObjectName(u"openDoorButton")
        self.openDoorButton.setGeometry(QRect(230, 180, 211, 71))
        self.openHatchButton = QPushButton(self.centralwidget)
        self.openHatchButton.setObjectName(u"openHatchButton")
        self.openHatchButton.setGeometry(QRect(610, 180, 211, 71))
        self.exitAppButton = QPushButton(self.centralwidget)
        self.exitAppButton.setObjectName(u"exitAppButton")
        self.exitAppButton.setGeometry(QRect(230, 340, 211, 71))
        self.exitButton = QPushButton(self.centralwidget)
        self.exitButton.setObjectName(u"exitButton")
        self.exitButton.setGeometry(QRect(800, 0, 211, 71))
        self.tareButton = QPushButton(self.centralwidget)
        self.tareButton.setObjectName(u"tareButton")
        self.tareButton.setGeometry(QRect(610, 340, 211, 71))
        Admin.setCentralWidget(self.centralwidget)

        self.retranslateUi(Admin)

        QMetaObject.connectSlotsByName(Admin)
    # setupUi

    def retranslateUi(self, Admin):
        Admin.setWindowTitle(QCoreApplication.translate("Admin", u"MainWindow", None))
        self.label.setText(QCoreApplication.translate("Admin", u"<html><head/><body><p><span style=\" font-size:24pt;\">Admin</span></p></body></html>", None))
        self.openDoorButton.setText(QCoreApplication.translate("Admin", u"Open Doors", None))
        self.openDoorButton.setProperty(u"type", QCoreApplication.translate("Admin", u"normal", None))
        self.openHatchButton.setText(QCoreApplication.translate("Admin", u"Open Hatch", None))
        self.openHatchButton.setProperty(u"type", QCoreApplication.translate("Admin", u"normal", None))
        self.exitAppButton.setText(QCoreApplication.translate("Admin", u"Exit App", None))
        self.exitAppButton.setProperty(u"type", QCoreApplication.translate("Admin", u"normal", None))
        self.exitButton.setText(QCoreApplication.translate("Admin", u"Exit Admin", None))
        self.exitButton.setProperty(u"type", QCoreApplication.translate("Admin", u"normal", None))
        self.tareButton.setText(QCoreApplication.translate("Admin", u"Tare", None))
        self.tareButton.setProperty(u"type", QCoreApplication.translate("Admin", u"normal", None))
    # retranslateUi

