# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'cart_screen.ui'
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
from PySide6.QtWidgets import (QApplication, QMainWindow, QPushButton, QSizePolicy,
    QWidget)

class Ui_Cart(object):
    def setupUi(self, Cart):
        if not Cart.objectName():
            Cart.setObjectName(u"Cart")
        Cart.resize(800, 600)
        self.centralwidget = QWidget(Cart)
        self.centralwidget.setObjectName(u"centralwidget")
        self.pushButton = QPushButton(self.centralwidget)
        self.pushButton.setObjectName(u"pushButton")
        self.pushButton.setGeometry(QRect(320, 0, 131, 32))
        Cart.setCentralWidget(self.centralwidget)

        self.retranslateUi(Cart)

        QMetaObject.connectSlotsByName(Cart)
    # setupUi

    def retranslateUi(self, Cart):
        Cart.setWindowTitle(QCoreApplication.translate("Cart", u"MainWindow", None))
        self.pushButton.setText(QCoreApplication.translate("Cart", u"Go to Cart Screen", None))
    # retranslateUi

