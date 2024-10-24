from PySide6.QtWidgets import QMainWindow
from .ui_reciept import Ui_Reciept

class RecieptScreen(QMainWindow):
    def __init__(self, parent=None):
        super(RecieptScreen, self).__init__(parent)
        self.ui = Ui_Reciept()
        self.ui.setupUi(self)
        
        self.ui.pushButton.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(1))
        self.ui.pushButton_2.clicked.connect(lambda: self.ui.stackedWidget.setCurrentIndex(2))