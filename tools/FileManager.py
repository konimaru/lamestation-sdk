import wx, os
import logging

class File(object):
    def __init__(self):
        self.filename = ""
        self.shortname = ""
        self.ext = ""

    def Load(self, filename):
        self.filename = filename
        self.shortname = os.path.splitext(os.path.basename(self.filename))[0]
        self.ext = self.filename.split('.')[-1].lower()

    def Print(self):
        print self.filename
        print self.shortname
        print self.ext

    def Save(self):
        self.SaveAs(self.filename)

    def SaveAs(self, filename):
        print


class Image(File):
    def __init__(self):
        File.__init__(self)

    def Load(self, filename):
        File.Load(self, filename=filename)
        self.bitmap = wx.Bitmap(self.filename, wx.BITMAP_TYPE_ANY)

    def Save(self):
        self.SaveAs(self.filename)

    def SaveAs(self, filename):
        self.bitmap.SaveFile(filename, wx.BITMAP_TYPE_PNG)
        

class FileManager(object):
    index = 0
    filetype = ''
    filetypearray = {'image':[],'map':[]}
    typetable = {'image':{'png':wx.BITMAP_TYPE_PNG,'bmp':wx.BITMAP_TYPE_BMP}}

    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(FileManager, cls).__new__(
                                cls, *args, **kwargs)
        return cls._instance

    def CurrentType(self):
        return self.filetype

    def CurrentIndex(self):
        return self.index

    def CurrentFile(self):
        return self.filetypearray[self.filetype][self.index]

    def New(self, filetype):
        self.filetypearray[self.filetype].append(Image())
        logging.info("FileManager.%i.New('%s', '%s')" % (self.index, self.filetype))


    def Load(self, filetype, filename):
        if not os.path.isfile(filename):
            raise
        self.filetype = filetype

        image = Image()
        image.Load(filename)
        self.filetypearray[self.filetype].append(image)
        logging.info("FileManager.%i.Load('%s', '%s')" % (self.index, self.filetype, filename))

    def Save(self):
        self.CurrentFile().Save()
        logging.info("FileManager.%i.Save()" % (self.index))

    def SaveAs(self, filename):
        self.CurrentFile().SaveAs(filename)
        logging.info("FileManager.%i.SaveAs('%s')" % (self.index, filename))

    def Close(self):
        del self.filetypearray[self.filetype][self.index]

        logging.info("FileManager.%i.Close()" % (self.index))


#    def OnExport(self, event):
#        wildcard = "Spin files (*.spin)|*.spin"
#        dialog = wx.FileDialog(None, "Choose a file",
#                defaultDir=os.path.dirname(self.parent.filename),
#                defaultFile=os.path.splitext(os.path.basename(self.parent.filename))[0]+".spin",
#                wildcard=wildcard,
#                style=wx.FD_SAVE|wx.OVERWRITE_PROMPT)
#        if dialog.ShowModal() == wx.ID_OK:
#            pass
##            f = open(dialog.GetPath(),"w")
##            f.write(self.spin.encode('utf8'))
##            f.close()
#
#            self.statusbar.SetStatusText("Wrote to "+dialog.GetPath())
#        dialog.Destroy()

        #self.imgdata = ImageData.ImageData()

        #try:
        #    self.imgdata.openImage(self.filename)
        #except:
        #    wx.MessageBox('That is not a valid image file', 'Info', 
        #        wx.OK | wx.ICON_EXCLAMATION)
