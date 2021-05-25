import sys
from PyQt5.QtWidgets import *
from PyQt5 import uic
from naver_google_crawling import naver,google
# form_class = uic.loadUiType(r"D:\crawling\crawling.ui")[0]
form_class = uic.loadUiType("crawling.ui")[0]
class WindowClass(QMainWindow, form_class) :
    def __init__(self):
    
        super().__init__()
        self.setupUi(self)

        self.check = ''
        self.keyword = ''''''
        self.op = ''
        self.checkBox.clicked.connect(self.check_naver)
        self.checkBox2.clicked.connect(self.check_google)
        self.radioButton3.clicked.connect(self.AND_check)
        self.radioButton4.clicked.connect(self.OR_check)
        self.radioButton5.clicked.connect(self.None_check)
        self.Search.clicked.connect(self.crawling)

    def check_naver(self):
        self.check += 'naver'
    def check_google(self):
        self.check += 'google'
    def AND_check(self):
        self.op = 'AND'
    def None_check(self):
        self.op = 'None'
    def OR_check(self):
        self.op = 'OR'
    def crawling(self):
        self.keyword = self.textEdit.toPlainText()
        if self.check == 'naver':
            naver(self.keyword,self.op)
        elif self.check == 'google':
            google(self.keyword,self.op)
        else:
            naver(self.keyword,self.op)
            google(self.keyword,self.op)
if __name__ == "__main__" :
    app = QApplication(sys.argv)
    myWindow = WindowClass()
    myWindow.show()
    app.exec_()
    app.exec_()
