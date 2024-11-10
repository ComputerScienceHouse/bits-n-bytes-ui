# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'cart_screen.ui'
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
from PySide6.QtWidgets import (QApplication, QFrame, QGroupBox, QLabel,
    QListView, QMainWindow, QPushButton, QSizePolicy,
    QWidget)

class Ui_Cart(object):
    def setupUi(self, Cart):
        if not Cart.objectName():
            Cart.setObjectName(u"Cart")
        Cart.resize(1024, 600)
        self.centralwidget = QWidget(Cart)
        self.centralwidget.setObjectName(u"centralwidget")
        self.itemList = QListView(self.centralwidget)
        self.itemList.setObjectName(u"itemList")
        self.itemList.setGeometry(QRect(10, 130, 621, 451))
        self.itemList.setUniformItemSizes(False)
        self.subtotalLabel = QLabel(self.centralwidget)
        self.subtotalLabel.setObjectName(u"subtotalLabel")
        self.subtotalLabel.setGeometry(QRect(490, 80, 141, 61))
        self.subtotalLabel.setStyleSheet(u"")
        self.subtotalLabel.setAlignment(Qt.AlignmentFlag.AlignLeading|Qt.AlignmentFlag.AlignLeft|Qt.AlignmentFlag.AlignVCenter)
        self.navButton = QPushButton(self.centralwidget)
        self.navButton.setObjectName(u"navButton")
        self.navButton.setGeometry(QRect(440, 0, 151, 51))
        self.navButton.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px; font-family: Roboto;}\n"
"")
        self.nutritionBox = QGroupBox(self.centralwidget)
        self.nutritionBox.setObjectName(u"nutritionBox")
        self.nutritionBox.setGeometry(QRect(650, 10, 361, 571))
        self.nutritionLabel = QLabel(self.nutritionBox)
        self.nutritionLabel.setObjectName(u"nutritionLabel")
        self.nutritionLabel.setGeometry(QRect(10, 10, 341, 31))
        font = QFont()
        font.setFamilies([u".AppleSystemUIFont"])
        self.nutritionLabel.setFont(font)
        self.ingredientsLabel = QLabel(self.nutritionBox)
        self.ingredientsLabel.setObjectName(u"ingredientsLabel")
        self.ingredientsLabel.setGeometry(QRect(10, 210, 341, 51))
        self.nutritionLine = QFrame(self.nutritionBox)
        self.nutritionLine.setObjectName(u"nutritionLine")
        self.nutritionLine.setGeometry(QRect(10, 40, 341, 16))
        self.nutritionLine.setFrameShape(QFrame.Shape.HLine)
        self.nutritionLine.setFrameShadow(QFrame.Shadow.Sunken)
        self.ingredientsLine = QFrame(self.nutritionBox)
        self.ingredientsLine.setObjectName(u"ingredientsLine")
        self.ingredientsLine.setGeometry(QRect(10, 250, 341, 16))
        self.ingredientsLine.setFrameShape(QFrame.Shape.HLine)
        self.ingredientsLine.setFrameShadow(QFrame.Shadow.Sunken)
        self.cancelButton = QPushButton(self.nutritionBox)
        self.cancelButton.setObjectName(u"cancelButton")
        self.cancelButton.setGeometry(QRect(20, 480, 331, 81))
        self.cancelButton.setStyleSheet(u"")
        self.nameLabel = QLabel(self.centralwidget)
        self.nameLabel.setObjectName(u"nameLabel")
        self.nameLabel.setGeometry(QRect(20, 10, 241, 31))
        self.navRecieptButton = QPushButton(self.centralwidget)
        self.navRecieptButton.setObjectName(u"navRecieptButton")
        self.navRecieptButton.setGeometry(QRect(280, 0, 151, 51))
        self.navRecieptButton.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px; font-family: Roboto;}\n"
"")
        self.addButton = QPushButton(self.centralwidget)
        self.addButton.setObjectName(u"addButton")
        self.addButton.setGeometry(QRect(20, 60, 101, 51))
        self.addButton.setStyleSheet(u"QPushButton{border: 2px solid grey; border-radius: 10px; padding: 5px; font-family: Roboto;}\n"
"")
        Cart.setCentralWidget(self.centralwidget)

        self.retranslateUi(Cart)

        QMetaObject.connectSlotsByName(Cart)
    # setupUi

    def retranslateUi(self, Cart):
        Cart.setWindowTitle(QCoreApplication.translate("Cart", u"MainWindow", None))
        self.subtotalLabel.setText(QCoreApplication.translate("Cart", u"<html><head/><body><p><span style=\" font-size:18pt;\">Subtotal:</span></p></body></html>", None))
        self.subtotalLabel.setProperty(u"class", QCoreApplication.translate("Cart", u"heading", None))
        self.navButton.setText(QCoreApplication.translate("Cart", u"Go to Welcome Screen", None))
        self.nutritionBox.setTitle("")
        self.nutritionLabel.setText(QCoreApplication.translate("Cart", u"<html><head/><body><p><span style=\" font-size:18pt;\">Nutrition:</span></p></body></html>", None))
        self.nutritionLabel.setProperty(u"class", QCoreApplication.translate("Cart", u"text", None))
        self.ingredientsLabel.setText(QCoreApplication.translate("Cart", u"<html><head/><body><p><span style=\" font-size:18pt;\">Ingredients:</span></p></body></html>", None))
        self.ingredientsLabel.setProperty(u"class", QCoreApplication.translate("Cart", u"text", None))
        self.cancelButton.setText(QCoreApplication.translate("Cart", u"Cancel Transaction", None))
        self.cancelButton.setProperty(u"type", QCoreApplication.translate("Cart", u"secondary", None))
        self.nameLabel.setText(QCoreApplication.translate("Cart", u"<html><head/><body><p><span style=\" font-size:18pt;\">Cart</span></p></body></html>", None))
        self.nameLabel.setProperty(u"class", QCoreApplication.translate("Cart", u"heading", None))
        self.navRecieptButton.setText(QCoreApplication.translate("Cart", u"Go To Reciept", None))
        self.addButton.setText(QCoreApplication.translate("Cart", u"Add Item", None))
    # retranslateUi

