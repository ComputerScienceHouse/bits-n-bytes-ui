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
    QListView, QMainWindow, QPushButton, QSizePolicy,
    QStackedWidget, QWidget)

class Ui_Reciept(object):
    def setupUi(self, Reciept):
        if not Reciept.objectName():
            Reciept.setObjectName(u"Reciept")
        Reciept.resize(1024, 600)
        self.centralwidget = QWidget(Reciept)
        self.centralwidget.setObjectName(u"centralwidget")
        self.itemList = QListView(self.centralwidget)
        self.itemList.setObjectName(u"itemList")
        self.itemList.setGeometry(QRect(10, 10, 621, 571))
        self.stackedWidget = QStackedWidget(self.centralwidget)
        self.stackedWidget.setObjectName(u"stackedWidget")
        self.stackedWidget.setGeometry(QRect(640, 0, 371, 591))
        self.page = QWidget()
        self.page.setObjectName(u"page")
        self.taxLabel = QLabel(self.page)
        self.taxLabel.setObjectName(u"taxLabel")
        self.taxLabel.setGeometry(QRect(50, 500, 271, 31))
        self.taxLabel.setStyleSheet(u"")
        self.taxLabel.setAlignment(Qt.AlignmentFlag.AlignLeading|Qt.AlignmentFlag.AlignLeft|Qt.AlignmentFlag.AlignVCenter)
        self.emailButton = QPushButton(self.page)
        self.emailButton.setObjectName(u"emailButton")
        self.emailButton.setGeometry(QRect(70, 270, 251, 61))
        self.emailButton.setStyleSheet(u"")
        self.textButton = QPushButton(self.page)
        self.textButton.setObjectName(u"textButton")
        self.textButton.setGeometry(QRect(70, 200, 251, 61))
        self.textButton.setStyleSheet(u"")
        self.timeoutLabel = QLabel(self.page)
        self.timeoutLabel.setObjectName(u"timeoutLabel")
        self.timeoutLabel.setGeometry(QRect(210, 0, 171, 31))
        font = QFont()
        font.setFamilies([u".AppleSystemUIFont"])
        self.timeoutLabel.setFont(font)
        self.timeoutLabel.setAlignment(Qt.AlignmentFlag.AlignLeading|Qt.AlignmentFlag.AlignLeft|Qt.AlignmentFlag.AlignVCenter)
        self.recieptLabel = QLabel(self.page)
        self.recieptLabel.setObjectName(u"recieptLabel")
        self.recieptLabel.setGeometry(QRect(0, 140, 381, 31))
        self.recieptLabel.setStyleSheet(u"")
        self.recieptLabel.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)
        self.line = QFrame(self.page)
        self.line.setObjectName(u"line")
        self.line.setGeometry(QRect(50, 530, 271, 21))
        self.line.setFrameShape(QFrame.Shape.HLine)
        self.line.setFrameShadow(QFrame.Shadow.Sunken)
        self.noRecieptButton = QPushButton(self.page)
        self.noRecieptButton.setObjectName(u"noRecieptButton")
        self.noRecieptButton.setGeometry(QRect(70, 340, 251, 61))
        self.noRecieptButton.setStyleSheet(u"")
        self.subtotalLabel = QLabel(self.page)
        self.subtotalLabel.setObjectName(u"subtotalLabel")
        self.subtotalLabel.setGeometry(QRect(50, 470, 271, 31))
        self.subtotalLabel.setStyleSheet(u"")
        self.subtotalLabel.setAlignment(Qt.AlignmentFlag.AlignLeading|Qt.AlignmentFlag.AlignLeft|Qt.AlignmentFlag.AlignVCenter)
        self.totalLabel = QLabel(self.page)
        self.totalLabel.setObjectName(u"totalLabel")
        self.totalLabel.setGeometry(QRect(50, 540, 271, 31))
        self.totalLabel.setStyleSheet(u"")
        self.totalLabel.setAlignment(Qt.AlignmentFlag.AlignLeading|Qt.AlignmentFlag.AlignLeft|Qt.AlignmentFlag.AlignVCenter)
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

        self.stackedWidget.setCurrentIndex(0)


        QMetaObject.connectSlotsByName(Reciept)
    # setupUi

    def retranslateUi(self, Reciept):
        self.taxLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:14pt;\">Tax:</span></p></body></html>", None))
        self.taxLabel.setProperty(u"type", QCoreApplication.translate("Reciept", u"normal", None))
        self.emailButton.setText(QCoreApplication.translate("Reciept", u"Email", None))
        self.emailButton.setProperty(u"type", QCoreApplication.translate("Reciept", u"normal", None))
        self.textButton.setText(QCoreApplication.translate("Reciept", u"Text", None))
        self.textButton.setProperty(u"type", QCoreApplication.translate("Reciept", u"normal", None))
        self.timeoutLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:14pt;\">Timeout In: 10</span></p></body></html>", None))
        self.timeoutLabel.setProperty(u"type", QCoreApplication.translate("Reciept", u"normal", None))
        self.recieptLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p align=\"center\"><span style=\" font-size:18pt;\">Would You Like A Reciept?</span></p></body></html>", None))
        self.recieptLabel.setProperty(u"type", QCoreApplication.translate("Reciept", u"big", None))
        self.noRecieptButton.setText(QCoreApplication.translate("Reciept", u"No Reciept", None))
        self.noRecieptButton.setProperty(u"type", QCoreApplication.translate("Reciept", u"normal", None))
        self.subtotalLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:14pt;\">Subtotal:</span></p></body></html>", None))
        self.subtotalLabel.setProperty(u"type", QCoreApplication.translate("Reciept", u"normal", None))
        self.totalLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p><span style=\" font-size:14pt;\">Total:</span></p></body></html>", None))
        self.totalLabel.setProperty(u"type", QCoreApplication.translate("Reciept", u"normal", None))
        self.phoneNumberLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p align=\"center\"><span style=\" font-size:18pt;\">Enter Your Phone Number:</span></p></body></html>", None))
        self.phoneNumberLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        self.emailLabel.setText(QCoreApplication.translate("Reciept", u"<html><head/><body><p align=\"center\"><span style=\" font-size:18pt;\">Enter Your Email:</span></p></body></html>", None))
        self.emailLabel.setProperty(u"class", QCoreApplication.translate("Reciept", u"heading", None))
        pass
    # retranslateUi

