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
from PySide6.QtWidgets import (QApplication, QFrame, QLabel, QLineEdit,
    QListWidget, QListWidgetItem, QMainWindow, QPushButton,
    QSizePolicy, QStackedWidget, QWidget)

class Ui_Reciept(object):
    def setupUi(self, Reciept):
        if not Reciept.objectName():
            Reciept.setObjectName(u"Reciept")
        Reciept.resize(1024, 600)
        self.centralwidget = QWidget(Reciept)
        self.centralwidget.setObjectName(u"centralwidget")
        self.itemList = QListWidget(self.centralwidget)
        self.itemList.setObjectName(u"itemList")
        self.itemList.setGeometry(QRect(10, 10, 621, 571))
        self.stackedWidget = QStackedWidget(self.centralwidget)
        self.stackedWidget.setObjectName(u"stackedWidget")
        self.stackedWidget.setGeometry(QRect(640, 0, 371, 591))
        self.page = QWidget()
        self.page.setObjectName(u"page")
        self.subtotalLabel_2 = QLabel(self.page)
        self.subtotalLabel_2.setObjectName(u"subtotalLabel_2")
        self.subtotalLabel_2.setGeometry(QRect(10, 500, 141, 31))
        self.subtotalLabel_2.setStyleSheet(u"")
        self.subtotalLabel_2.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.pushButton_2 = QPushButton(self.page)
        self.pushButton_2.setObjectName(u"pushButton_2")
        self.pushButton_2.setGeometry(QRect(70, 250, 251, 61))
        self.pushButton_2.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px}")
        self.pushButton = QPushButton(self.page)
        self.pushButton.setObjectName(u"pushButton")
        self.pushButton.setGeometry(QRect(70, 180, 251, 61))
        self.pushButton.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px}\n"
"")
        self.timeoutLabel = QLabel(self.page)
        self.timeoutLabel.setObjectName(u"timeoutLabel")
        self.timeoutLabel.setGeometry(QRect(190, 10, 141, 31))
        font = QFont()
        font.setFamilies([u".AppleSystemUIFont"])
        self.timeoutLabel.setFont(font)
        self.subtotalLabel_4 = QLabel(self.page)
        self.subtotalLabel_4.setObjectName(u"subtotalLabel_4")
        self.subtotalLabel_4.setGeometry(QRect(60, 140, 271, 31))
        self.subtotalLabel_4.setStyleSheet(u"")
        self.subtotalLabel_4.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.line = QFrame(self.page)
        self.line.setObjectName(u"line")
        self.line.setGeometry(QRect(50, 530, 271, 21))
        self.line.setFrameShape(QFrame.Shape.HLine)
        self.line.setFrameShadow(QFrame.Shadow.Sunken)
        self.pushButton_3 = QPushButton(self.page)
        self.pushButton_3.setObjectName(u"pushButton_3")
        self.pushButton_3.setGeometry(QRect(70, 320, 251, 61))
        self.pushButton_3.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px}")
        self.subtotalLabel = QLabel(self.page)
        self.subtotalLabel.setObjectName(u"subtotalLabel")
        self.subtotalLabel.setGeometry(QRect(10, 470, 141, 31))
        self.subtotalLabel.setStyleSheet(u"")
        self.subtotalLabel.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.subtotalLabel_3 = QLabel(self.page)
        self.subtotalLabel_3.setObjectName(u"subtotalLabel_3")
        self.subtotalLabel_3.setGeometry(QRect(10, 550, 141, 31))
        self.subtotalLabel_3.setStyleSheet(u"")
        self.subtotalLabel_3.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.stackedWidget.addWidget(self.page)
        self.page_2 = QWidget()
        self.page_2.setObjectName(u"page_2")
        self.textLineEdit = QLineEdit(self.page_2)
        self.textLineEdit.setObjectName(u"textLineEdit")
        self.textLineEdit.setGeometry(QRect(80, 230, 221, 41))
        self.phoneNumberLabel = QLabel(self.page_2)
        self.phoneNumberLabel.setObjectName(u"phoneNumberLabel")
        self.phoneNumberLabel.setGeometry(QRect(60, 200, 271, 31))
        self.phoneNumberLabel.setStyleSheet(u"")
        self.phoneNumberLabel.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.stackedWidget.addWidget(self.page_2)
        self.page_3 = QWidget()
        self.page_3.setObjectName(u"page_3")
        self.emailLineEdit = QLineEdit(self.page_3)
        self.emailLineEdit.setObjectName(u"emailLineEdit")
        self.emailLineEdit.setGeometry(QRect(80, 230, 221, 41))
        self.emailLabel = QLabel(self.page_3)
        self.emailLabel.setObjectName(u"emailLabel")
        self.emailLabel.setGeometry(QRect(60, 200, 271, 31))
        self.emailLabel.setStyleSheet(u"")
        self.emailLabel.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.stackedWidget.addWidget(self.page_3)
        Reciept.setCentralWidget(self.centralwidget)

        self.retranslateUi(Reciept)

        QMetaObject.connectSlotsByName(Reciept)
    # setupUi

    def retranslateUi(self, Reciept):
        self.subtotalLabel_2.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Tax:</span></p></body></html>", None))
        self.subtotalLabel_2.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.pushButton_2.setText(QCoreApplication.translate("Reciept", u"Email", None))
        self.pushButton.setText(QCoreApplication.translate("Reciept", u"Text", None))
        self.timeoutLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Timeout In:</span></p></body></html>", None))
        self.timeoutLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"text", None))
        self.subtotalLabel_4.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p align=\"center\"><span style=\" font-size:18pt;\">Would You Like A Reciept?</span></p></body></html>", None))
        self.subtotalLabel_4.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.pushButton_3.setText(QCoreApplication.translate("Reciept", u"No Reciept", None))
        self.subtotalLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Subtotal:</span></p></body></html>", None))
        self.subtotalLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.subtotalLabel_3.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:24pt;\">Total:</span></p></body></html>", None))
        self.subtotalLabel_3.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.phoneNumberLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p align=\"center\"><span style=\" font-size:18pt;\">Enter Your Phone Number:</span></p></body></html>", None))
        self.phoneNumberLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.emailLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p align=\"center\"><span style=\" font-size:18pt;\">Enter Your Email:</span></p></body></html>", None))
        self.emailLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        pass
    # retranslateUi

