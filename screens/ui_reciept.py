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
from PySide6.QtWidgets import (QApplication, QFrame, QLabel, QListWidget,
    QListWidgetItem, QMainWindow, QPushButton, QSizePolicy,
    QWidget)

class Ui_Reciept(object):
    def setupUi(self, Reciept):
        if not Reciept.objectName():
            Reciept.setObjectName(u"Reciept")
        Reciept.resize(1024, 600)
        self.centralwidget = QWidget(Reciept)
        self.centralwidget.setObjectName(u"centralwidget")
        self.pushButton = QPushButton(self.centralwidget)
        self.pushButton.setObjectName(u"pushButton")
        self.pushButton.setGeometry(QRect(710, 180, 251, 61))
        self.pushButton.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px}\n"
"")
        self.pushButton_2 = QPushButton(self.centralwidget)
        self.pushButton_2.setObjectName(u"pushButton_2")
        self.pushButton_2.setGeometry(QRect(710, 250, 251, 61))
        self.pushButton_2.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px}")
        self.itemList = QListWidget(self.centralwidget)
        self.itemList.setObjectName(u"itemList")
        self.itemList.setGeometry(QRect(10, 10, 621, 571))
        self.pushButton_3 = QPushButton(self.centralwidget)
        self.pushButton_3.setObjectName(u"pushButton_3")
        self.pushButton_3.setGeometry(QRect(710, 320, 251, 61))
        self.pushButton_3.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px}")
        self.nutritionLabel = QLabel(self.centralwidget)
        self.nutritionLabel.setObjectName(u"nutritionLabel")
        self.nutritionLabel.setGeometry(QRect(820, 0, 141, 31))
        font = QFont()
        font.setFamilies([u".AppleSystemUIFont"])
        self.nutritionLabel.setFont(font)
        self.subtotalLabel = QLabel(self.centralwidget)
        self.subtotalLabel.setObjectName(u"subtotalLabel")
        self.subtotalLabel.setGeometry(QRect(690, 470, 141, 31))
        self.subtotalLabel.setStyleSheet(u"")
        self.subtotalLabel.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.subtotalLabel_2 = QLabel(self.centralwidget)
        self.subtotalLabel_2.setObjectName(u"subtotalLabel_2")
        self.subtotalLabel_2.setGeometry(QRect(690, 500, 141, 31))
        self.subtotalLabel_2.setStyleSheet(u"")
        self.subtotalLabel_2.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.subtotalLabel_3 = QLabel(self.centralwidget)
        self.subtotalLabel_3.setObjectName(u"subtotalLabel_3")
        self.subtotalLabel_3.setGeometry(QRect(690, 550, 141, 31))
        self.subtotalLabel_3.setStyleSheet(u"")
        self.subtotalLabel_3.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.line = QFrame(self.centralwidget)
        self.line.setObjectName(u"line")
        self.line.setGeometry(QRect(730, 530, 271, 21))
        self.line.setFrameShape(QFrame.Shape.HLine)
        self.line.setFrameShadow(QFrame.Shadow.Sunken)
        self.subtotalLabel_4 = QLabel(self.centralwidget)
        self.subtotalLabel_4.setObjectName(u"subtotalLabel_4")
        self.subtotalLabel_4.setGeometry(QRect(700, 140, 271, 31))
        self.subtotalLabel_4.setStyleSheet(u"")
        self.subtotalLabel_4.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        Reciept.setCentralWidget(self.centralwidget)

        self.retranslateUi(Reciept)

        QMetaObject.connectSlotsByName(Reciept)
    # setupUi

    def retranslateUi(self, Reciept):
        self.pushButton.setText(QCoreApplication.translate("Reciept", u"Text", None))
        self.pushButton_2.setText(QCoreApplication.translate("Reciept", u"Email", None))
        self.pushButton_3.setText(QCoreApplication.translate("Reciept", u"No Reciept", None))
        self.nutritionLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Timeout In:</span></p></body></html>", None))
        self.nutritionLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"text", None))
        self.subtotalLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Subtotal:</span></p></body></html>", None))
        self.subtotalLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.subtotalLabel_2.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Tax:</span></p></body></html>", None))
        self.subtotalLabel_2.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.subtotalLabel_3.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Total:</span></p></body></html>", None))
        self.subtotalLabel_3.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.subtotalLabel_4.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p align=\"center\"><span style=\" font-size:18pt;\">Would You Like A Reciept?</span></p></body></html>", None))
        self.subtotalLabel_4.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        pass
    # retranslateUi

